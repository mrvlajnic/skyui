# CLAUDE.md

# SkyUI

## Project status

SkyUI is the HMI and digital-cockpit concept for the Veltron Auto V1 SportLine direction. Veltron Auto is an independent automotive R&D studio in Belgrade, Serbia, led by Boris Vlajnić; SkyUI supports that studio's V1 SportLine concept and its stated focus on driver-centered design, UX, and engineering.

The project has an automotive-grade design and engineering direction. It is not production software, a vehicle controller, a certified automotive HMI, or a security-validated platform. The current evidence boundary is a 1680×720 landscape simulator. Physical display, broader resolution, accessibility, performance, lifecycle, safety, security, hardware, and compliance behavior are unverified.

## Current structure

```text
lib/
├── core/
│   ├── icons/
│   └── theme/
├── screens/
│   ├── home/
│   ├── media/
│   ├── navigation/
│   └── phone/
├── services/
│   └── drive_mode_service.dart
├── widgets/
│   ├── cards/
│   ├── climate/
│   ├── header/
│   └── sidebar/
└── main.dart

test/
└── widget_test.dart

web/
└── flutter_bootstrap.js
```

There is no current `lib/models/` directory or shared media, call, navigation, climate, hardware, or backend service layer. `DriveModeService` is a debug/demo notifier, not a vehicle trust source.

## Implemented prototype surface

- Header, sidebar, Home dashboard, cards, and climate strip.
- Local Navigation, Media, and Phone prototype modules.
- Coordinated single-module transitions and system Back handling.
- Local fixture data and local state.
- Disabled Vehicle and Settings destinations.
- Disabled unavailable vehicle actions and unsupported map camera controls.
- Debug-only parked/driving state that currently affects Media browsing.
- Loopback web-app launcher with an enforced CSP-compatible build.
- Widget, launcher, and headless-browser verification.

Never describe these UI prototypes as integrated automotive applications.

## Evidence and language rules

Always:

- Label vehicle, phone, navigation, media, climate, connectivity, speed, route, trip, and diagnostic values as simulated unless a documented source exists.
- Expose unavailable controls as disabled with a reason in Semantics or tooltip text.
- Distinguish design goals from verified capabilities.
- Use `docs/automotive_hmi_audit.md` as the current readiness and blocker record.

Never:

- Use `automotive-grade` only for the documented design/engineering direction; never present it as certified, production-safe, cyber-secure, 60 FPS validated, or fully offline without target-platform evidence and approval.
- Use a debug widget state as a vehicle, safety, or trust source.
- Claim responsiveness or frame-rate performance without a documented test matrix and target-device measurements.
- Claim offline web operation while external fallback fonts are possible.
- Distribute Android artifacts while placeholder identity or debug signing remains.
- State that telemetry is collected; the current app implements no remote telemetry or backend.

## UI rules

- Reuse widgets and maintain spacing consistency.
- Keep new and modified shared values token-based where practical.
- Give interactive controls explicit enabled/disabled semantics.
- Treat 48 dp as a programmatic minimum, not proof of physical target suitability.
- Keep simulation labels visible or semantically exposed for safety-relevant fixtures.
- State the parked/driving policy for new interactions.
- Split large files at natural boundaries when they are next changed; do not perform an unapproved broad rewrite.
- Prefer composition over duplication.

Current large screen files and inline styles are known debt. Do not describe the design system as the sole runtime source of truth yet.

## State and architecture

The target direction is:

```text
UI → domain service/state → model/contract → data source
```

The current implementation is partial: Media, Phone, Navigation, and Climate keep state and transitions in widget `State` classes. Extract domain state naturally when those areas are modified. Do not add a global state framework or perform a large architectural rewrite without approval.

Treat `docs/architecture.md` as target architecture plus a current-state record, not proof that all layers already exist.

## Coding style

- Use readable Dart and descriptive names.
- Prefer typed callbacks and value types.
- Keep functions short and widgets focused.
- Avoid unnecessary comments.
- Do not duplicate controls when a reusable component is justified.
- Use platform and Flutter APIs already present in the project; do not add dependencies without a documented need.

## Workflow

Before every task:

1. Read relevant source, tests, and documentation.
2. Explain the plan.
3. Preserve existing user changes.
4. Implement the smallest coherent change.
5. Run relevant format, analyze, test, and build checks.
6. Document assumptions and unverified behavior.

For bug fixes, find the root cause and prevent recurrence without broad unrelated refactoring.

## Refactoring policy

If a better architecture exists:

1. Explain the issue, advantages, disadvantages, and migration impact.
2. Do not rewrite working code immediately.
3. Wait for approval for broad structural changes.

## Performance policy

Measure before optimizing. Do not claim 60 FPS, stable input latency, low memory, thermal stability, or long-run behavior without profile traces on the intended automotive SoC.

Prefer local `ValueNotifier` or child state when profiling demonstrates broad rebuilds. Avoid adding `RepaintBoundary` or removing blur effects speculatively; validate on the target GPU.

## Release and security policy

- Keep legal/privacy status synchronized with the draft prototype notice.
- Do not produce a distributable Android release until identity ownership, production signing, artifact verification, and update-path decisions are approved.
- Keep a reproducible clean-build, dependency, secret, license, vulnerability, SBOM, and provenance gate before external distribution.
- Require TARA/HARA and explicit HMI/HAL/CAN trust boundaries before hardware integration.
- Keep the UI out of direct raw CAN or safety-actuator command paths.

## Documentation

Primary documents:

- `docs/automotive_hmi_audit.md`
- `docs/architecture.md`
- `docs/design_system.md`
- `docs/modules.md`
- `docs/roadmap.md`
- `docs/changelog.md`
- `docs/terms_of_service.md`

CLAUDE.md must remain concise and contain only project-wide rules.
