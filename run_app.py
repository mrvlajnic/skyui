import http.server
import socketserver
import subprocess
import threading
import webbrowser
import os
import sys

PORT = 8080
DIRECTORY = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'build', 'web')

class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def log_message(self, format, *args):
        # Suppress log output for a clean terminal
        pass

def start_server():
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), QuietHandler) as httpd:
        httpd.serve_forever()

def main():
    if not os.path.exists(DIRECTORY):
        print(f"[!] Error: Web build directory not found at {DIRECTORY}")
        print("Please run 'flutter build web' first.")
        sys.exit(1)

    print(f"[*] Starting Veltron OS server on http://localhost:{PORT}...")
    server_thread = threading.Thread(target=start_server, daemon=True)
    server_thread.start()

    print("[*] Launching 21:9 borderless app window (1680x720)...")
    app_flags = [
        f"--app=http://localhost:{PORT}",
        "--window-size=1680,720",
        "--window-position=50,50",
    ]

    # Try launching Chrome first, fallback to Edge
    launched = False
    for browser in ["chrome.exe", "msedge.exe"]:
        try:
            # Check if browser can be called
            proc = subprocess.Popen([browser] + app_flags)
            launched = True
            print(f"[+] Launched Veltron OS in {browser.replace('.exe', '')} App Mode.")
            print("[+] Zero browser borders, no URL bar, no tabs.")
            print("[+] Close the window when you are done.")
            proc.wait()
            break
        except FileNotFoundError:
            continue

    if not launched:
        print("[!] Neither Chrome nor Edge found in PATH, opening default browser...")
        webbrowser.open(f"http://localhost:{PORT}")
        print("[+] Press Ctrl+C to stop.")
        try:
            while True:
                pass
        except KeyboardInterrupt:
            pass

    print("[*] Veltron OS session closed.")

if __name__ == '__main__':
    main()
