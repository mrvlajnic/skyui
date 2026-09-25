# SkyUI Engineering Roadmap

Package version: `0.3.0-alpha+1`

Status: prototype hardening before any vehicle connection

## Roadmap policy

Roadmap items distinguish UI implementation from service integration, hardware integration, validation, and release approval. An implemented checkbox means that a UI affordance exists in the alpha prototype; it does not mean a vehicle, backend, or safety integration exists.

The current release gate is defined in `docs/automotive_hmi_audit.md`.

## Phase 1 — UI foundation

Status: partial

- [x] Flutter shell with Header, Sidebar, Home, and Climate.
- [x] Dark theme and connected `AppTheme`.
- [x] Reusable card components.
- [x] Local 1680×720 layout and transition baseline.
- [ ] Complete token migration from inline UI values.
- [ ] Natural section extraction from large screen files.
- [ ] Resolution, text-scale, RTL, and localization layout matrix.

## Phase 2 — Interactive HMI prototype

Status: UI implemented for internal evaluation; integrations incomplete

- [x] Coordinated single-module expansion and system Back.
- [x] Rapid module-request coordination and active-call transition guard.
- [x] Disabled Vehicle and Settings destinations.
- [x] Disabled Vehicle quick actions.
- [x] Local Media queue, playback, volume, and source state.
- [x] Media browsing guard for debug `driving` state.
- [x] Synthetic Phone Dialer and Recent Calls.
- [x] Explicit local demo-call state and in-call navigation lock.
- [x] Custom-painted Navigation map and fixture destinations.
- [x] Disabled unsupported map camera controls.
- [x] Simulated climate controls and fixture trip summary.
- [x] Local CSP-compatible web launcher and build stamp.
- [ ] Central driver interaction policy.
- [ ] Durable media, call, navigation, and climate session contracts.
- [ ] Loading, empty, stale, offline, fault, retry, and unavailable state model.
- [ ] Approved physical touch-target and optical validation plan.

## Phase 2.5 — Internal prototype hardening

Status: required before hardware or external release

1. **Truthful simulation state**
   - Keep visible or semantic `SIMULATED`/`DEMO` labels for fixtures.
   - Define source, timestamp, freshness, range, unit, quality, and fault contracts before vehicle data is displayed.

2. **Driver interaction policy**
   - Classify actions as allowed, locked, deferred, voice-only, or passive.
   - Define parked and driving behavior for every new interaction.
   - Do not use `DriveModeService` as a safety or trust source.

3. **Durable session state**
   - Add an approved `MediaSessionService` and `CallSessionService` boundary.
   - Define route/session ownership and app suspend/resume behavior.
   - Add compact HUD/minimize semantics before allowing module changes during a call.

4. **Accessibility and input matrix**
   - Test 1680×720 plus approved compact/ultrawide/portrait profiles.
   - Test text scale 1.3, 1.5, and 2.0, RTL, long strings, keyboard, focus, screen readers, reduced motion, and contrast.
   - Validate physical target size, gloves, vibration, and wet-finger input on target hardware.

5. **Target-device performance**
   - Profile frame time, UI/raster/GPU cost, input latency, memory, image decode, thermal behavior, background lifecycle, and long-run stability.
   - Do not claim 60 FPS before measured target-platform evidence exists.

6. **Offline web runtime**
   - Bundle an approved local font and configure local fallback behavior.
   - Capture a network trace proving no external fetch.
   - Validate CSP/COOP/COEP behavior on every supported browser.

7. **Release identity and provenance**
   - Replace `com.example.skyui` and other placeholder identities with owner-approved IDs.
   - Configure fail-closed production signing outside the repository.
   - Add reproducible clean builds, lockfile enforcement, dependency/vulnerability/secret/license scans, SBOM, artifact hash, and provenance.

## Phase 3 — Security and safety engineering foundation

Status: not started as a vehicle release program

- [ ] TARA/HARA and deployment-class definition.
- [ ] Data-flow and trust-boundary model for HMI, HAL, gateway, backend, and OTA.
- [ ] HMI/HAL/CAN separation with no raw bus access from Dart UI.
- [ ] Threat model for vehicle commands, diagnostics, identity, privacy, and update paths.
- [ ] Functional-safety and SOTIF evidence plan appropriate to the intended deployment.
- [ ] UNECE/ISO/cybersecurity assurance plan and ownership.

These activities precede any actuator integration or vehicle pilot; they are not a substitute for formal certification.

## Phase 4 — Adapters and controlled lab integration

Status: blocked by Phases 2.5 and 3

- [ ] Vehicle signal adapter with freshness, validity, fault, and provenance.
- [ ] GPS/map/traffic provider and route engine.
- [ ] Audio HAL and media service adapter.
- [ ] Bluetooth, telephony, contacts, and carrier adapter.
- [ ] HVAC, charging, and diagnostics adapter.
- [ ] Profiles, AI/voice, and cloud services after privacy review.

All integration work must begin in simulation or non-actuating lab/HIL conditions.

## Phase 5 — Non-actuating vehicle validation

Status: future gate

- [ ] Signal validity and fault injection.
- [ ] Gateway trust and command authorization tests.
- [ ] Restart, suspend/resume, network loss, and degraded-mode behavior.
- [ ] Target display, input, accessibility, performance, thermal, and long-duration tests.
- [ ] Written rollback, monitoring, incident response, and operational restrictions.

## Phase 6 — Safety-instrumented canary

Status: future and explicitly not authorized by this roadmap

A canary may begin only after legal classification, reproducible provenance, production signing, TARA/HARA, driver policy, session contracts, signal contracts, target-platform validation, and non-actuating vehicle evidence are approved.

No phase in this document authorizes public-road use, safety-critical actuation, or distribution of the current Android debug-signed artifact.
