import http.server
import hashlib
import os
import shutil
import subprocess
import sys
import threading
import webbrowser
from pathlib import Path

HOST = "127.0.0.1"
DIRECTORY = Path(__file__).resolve().parent / "build" / "web"
BUILD_STAMP = DIRECTORY / ".skyui-launcher-build"
EXPECTED_PORT = None

CONTENT_SECURITY_POLICY = (
    "default-src 'self'; "
    "base-uri 'self'; "
    "object-src 'none'; "
    "frame-ancestors 'none'; "
    "form-action 'none'; "
    "script-src 'self' 'wasm-unsafe-eval' blob:; "
    "style-src 'self' 'unsafe-inline'; "
    "img-src 'self' data: blob:; "
    "font-src 'self' data: https://fonts.gstatic.com; "
    "connect-src 'self' blob: https://fonts.gstatic.com; "
    "worker-src 'self' blob:; "
    "child-src 'self' blob:;"
)


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(DIRECTORY), **kwargs)

    def log_message(self, format, *args):
        pass

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Security-Policy", CONTENT_SECURITY_POLICY)
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Resource-Policy", "same-origin")
        self.send_header("Referrer-Policy", "no-referrer")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("X-Frame-Options", "DENY")
        super().end_headers()

    def _host_is_allowed(self):
        if EXPECTED_PORT is None:
            return False
        return self.headers.get("Host", "") in {
            f"127.0.0.1:{EXPECTED_PORT}",
            f"localhost:{EXPECTED_PORT}",
        }

    def do_GET(self):
        if not self._host_is_allowed():
            self.send_error(403, "Forbidden Host header")
            return
        super().do_GET()

    def do_HEAD(self):
        if not self._host_is_allowed():
            self.send_error(403, "Forbidden Host header")
            return
        super().do_HEAD()


class LocalHTTPServer(http.server.ThreadingHTTPServer):
    allow_reuse_address = False
    daemon_threads = True


def bundle_digest():
    digest = hashlib.sha256()
    for path in (DIRECTORY / "flutter_bootstrap.js", DIRECTORY / "main.dart.js"):
        digest.update(path.read_bytes())
    return digest.hexdigest()


def build_is_launcher_compatible():
    bootstrap_path = DIRECTORY / "flutter_bootstrap.js"
    entrypoint_path = DIRECTORY / "main.dart.js"
    canvaskit_path = DIRECTORY / "canvaskit" / "canvaskit.wasm"
    if not bootstrap_path.is_file() or not entrypoint_path.is_file():
        return False
    if not canvaskit_path.is_file() or not BUILD_STAMP.is_file():
        return False
    bootstrap = bootstrap_path.read_text(encoding="utf-8")
    if 'canvasKitBaseUrl: "canvaskit/"' not in bootstrap:
        return False
    if '"useLocalCanvasKit":true' not in bootstrap:
        return False
    entrypoint = entrypoint_path.read_text(encoding="utf-8")
    if "eval(" in entrypoint or "new Function" in entrypoint:
        return False
    return BUILD_STAMP.read_text(encoding="utf-8").strip() == bundle_digest()


def build_web():
    flutter = shutil.which("flutter")
    if flutter is None:
        print("[!] Error: Flutter SDK was not found in PATH.")
        return 1
    command = [
        flutter,
        "build",
        "web",
        "--release",
        "--no-web-resources-cdn",
        "--csp",
    ]
    if sys.platform == "win32" and Path(flutter).suffix.lower() in {".bat", ".cmd"}:
        command = [os.environ.get("COMSPEC", "cmd.exe"), "/d", "/c", *command]
    result = subprocess.run(command, cwd=Path(__file__).resolve().parent)
    if result.returncode != 0:
        return result.returncode
    try:
        BUILD_STAMP.write_text(bundle_digest(), encoding="utf-8")
    except OSError as error:
        print(f"[!] Error: Unable to write launcher build stamp: {error}")
        return 1
    return 0 if build_is_launcher_compatible() else 1


def browser_candidates():
    roots = [
        os.environ.get("PROGRAMFILES"),
        os.environ.get("PROGRAMFILES(X86)"),
        os.environ.get("LOCALAPPDATA"),
    ]
    relative_paths = [
        Path("Google/Chrome/Application/chrome.exe"),
        Path("Microsoft/Edge/Application/msedge.exe"),
    ]
    candidates = []
    seen = set()
    for root in filter(None, roots):
        for relative_path in relative_paths:
            candidate = Path(root) / relative_path
            key = str(candidate).casefold()
            if key not in seen and candidate.is_file():
                seen.add(key)
                candidates.append(candidate)
    return candidates


def launch_browser(port):
    app_url = f"http://{HOST}:{port}"
    app_flags = [
        f"--app={app_url}",
        "--window-size=1680,720",
        "--window-position=50,50",
    ]

    for browser in browser_candidates():
        try:
            process = subprocess.Popen([str(browser), *app_flags])
            print(f"[+] Launched Veltron OS in {browser.stem} App Mode.")
            print("[+] Close the window when you are done.")
            return process
        except OSError:
            continue

    print("[!] Chrome or Edge was not found in standard locations.")
    if not webbrowser.open_new_tab(app_url):
        print("[!] No browser could be opened automatically.")
        print(f"[+] Open {app_url} manually. Press Ctrl+C to stop.")
    return None


def wait_for_shutdown():
    try:
        threading.Event().wait()
    except KeyboardInterrupt:
        pass


def main():
    global EXPECTED_PORT

    print("[*] Building a CSP-compatible local web bundle...")
    if build_web() != 0:
        print("[!] Error: Launcher-compatible web build failed.")
        return 1

    if not build_is_launcher_compatible():
        print("[!] Error: Web build failed launcher compatibility checks.")
        return 1

    with LocalHTTPServer((HOST, 0), QuietHandler) as server:
        EXPECTED_PORT = server.server_address[1]
        server_thread = threading.Thread(
            target=server.serve_forever,
            name="skyui-local-server",
            daemon=True,
        )
        server_thread.start()
        print(f"[*] Starting Veltron OS server on http://{HOST}:{EXPECTED_PORT}...")

        process = None
        try:
            print("[*] Launching 21:9 borderless app window (1680x720)...")
            process = launch_browser(EXPECTED_PORT)
            if process is None:
                wait_for_shutdown()
            else:
                process.wait()
        except KeyboardInterrupt:
            pass
        finally:
            if process is not None and process.poll() is None:
                process.terminate()
            server.shutdown()
            server_thread.join(timeout=2)

    print("[*] Veltron OS session closed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
