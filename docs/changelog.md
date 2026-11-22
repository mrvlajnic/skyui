# Changelog

All notable changes to the Veltron Auto SkyUI HMI concept are documented here. The format follows Keep a Changelog, and package versioning follows Semantic Versioning where applicable.

## Unreleased — HMI audit hardening

Status: prototype-only; no signed or approved vehicle release artifact.

### Added

- Automotive HMI audit covering UX, architecture, performance, security, release blockers, and unverified target-platform checks.
- Unified expanded-module transition coordinator with latest-request-wins behavior.
- System Back handling for expanded prototype modules.
- Active demo-call navigation guard, including a race-safe Phone reopen during module exit.
- Synthetic Phone fixtures and explicit demo-call confirmation.
- Semantics labels, enabled/disabled states, unavailable reasons, and 48 dp hit areas for key controls.
- Disabled Vehicle/Settings destinations, Vehicle quick actions, and unsupported map camera controls.
- CSP-compatible web bootstrap with local CanvasKit and a hash-based launcher build stamp.
- Regression tests for rapid navigation, system Back, call locking, call-exit races, unavailable destinations, and media timer behavior.

### Changed

- Header connectivity and clock values are explicitly simulated.
- Vehicle card exposes a `DEMO DATA` label.
- Phone tabs now show only implemented Dialer and Recent Calls content.
- Recent-call selection fills a number and requires a separate Call action.
- Navigation no longer accepts free map taps that changed only a hidden fixture target.
- Navigation route/status UI is marked simulated; unsupported camera controls are disabled.
- Media playback timer stops while paused and waveform rendering uses a CustomPainter.
- `AppTheme` is connected to the application and base dark color tokens are aligned.
- Android backup is disabled for the prototype.
- The climate bar is taller (104 dp) and the dashboard cards take the reclaimed height; sidebar destinations, Settings included, are vertically centered so the rail has no empty bottom shelf.
- Navigation basemaps use MapTiler `basic-v2` light cartography, with the API key injected at build time; a missing key or unreachable host falls back to the painted fixture. The painted fallback and map puck share the same light palette.
- Local launcher binds only to loopback, validates Host headers, adds security headers, and always runs the documented CSP-compatible build command.

### Fixed

- The compact Navigation panel rendered `TargetPlatform.windows is not yet supported by the maps plugin`, because `maplibre_gl` has no Windows or web platform view. The panel now shows a real map on every target: `maplibre_gl` on Android/iOS, `flutter_map` with OSM tiles on desktop and web, and the painted fixture only when tiles are unreachable (offline, or the launcher CSP that blocks external imagery).
- The Vehicle card shows the exterior design render again; map presentation belongs to Navigation.
- The Vehicle render was hugging the left edge because the card `Column` uses start alignment; it is now centered, with a regression test.
- Map credit is now a 7 px chip naming the basemap provider; the `flutter_map |` package branding that `SimpleAttributionWidget` prepends is gone. The OSM and provider credits stay because their terms require them.

### Verification

- `flutter analyze` passes.
- Thirteen Flutter tests pass.
- `python -m py_compile run_app.py` passes.
- CSP-compatible web release build passes.
- Loopback Host validation and security-header smoke test pass.
- Headless Chrome renders the 1680×720 dashboard under the configured CSP.

### Open blockers

- Placeholder application identity and Android debug signing.
- No approved driver interaction policy for connected-vehicle use.
- No durable media, call, navigation, or climate session services.
- No signal provenance, freshness, validity, or fault contract.
- No target-display, physical touch, accessibility, performance, lifecycle, or thermal validation.
- No backend, CAN/HAL, OTA, TARA/HARA, or production compliance integration.
- Web fallback fonts may still use `fonts.gstatic.com`; fully offline operation is not claimed.

## v0.3.0-alpha — 2026-09-07

Historical alpha UI milestone. This section describes the prototype presentation direction, not current integrations or release readiness.

### Added

- Expanded Navigation, Media, and Phone cockpit presentation surfaces.
- Custom-painted map and local destination animation.
- Local media queue, playback, volume, and visualizer state.
- Local numeric phone keypad, synthetic recents, and simulated call presentation.
- Dual-zone climate presentation and simulated trip summary.
- Fixed 1680×720 dashboard baseline and local browser launcher.

### Limitations recorded by the current audit

- Media and Phone state is widget-local and not a persistent service.
- Phone has no telephony, DTMF, contacts provider, carrier, or Bluetooth integration.
- Navigation has no GPS, map provider, routing engine, or live traffic.
- Climate has no HVAC integration or automatic regulation.
- Vehicle, route, speed, climate, connectivity, and diagnostic values are fixtures.
- The alpha artifact is not production-signed or vehicle-approved.

## v0.2.0-alpha — 2026-09-07

Historical UI milestone.

- Added 21:9 layout exploration and overlay transitions.
- Added custom map, climate, vehicle-card, media-card, and phone-card presentation prototypes.
- Added a local Python web launcher.
- Added initial alpha prototype notice; it was not a complete legal or release agreement.

## v0.1.0-alpha — 2026-09-01

- Initial Flutter project scaffolding and dark theme foundation.
- Initial dashboard shell, header, sidebar, and desktop preview capability.
