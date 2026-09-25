# SkyUI Architecture

Package version: `0.3.0-alpha+1`

Status: partial prototype architecture with a target layered direction

## Purpose

This document separates the current implementation from the intended architecture. It is a development guide, not evidence that a vehicle operating system or production service architecture exists.

Known gaps and release blockers are tracked in `docs/automotive_hmi_audit.md`.

## What SkyUI is

SkyUI is an automotive-styled Flutter HMI prototype containing a dashboard and local Navigation, Media, Phone, Vehicle, and Climate UI simulations.

It is not:

- a complete vehicle operating system;
- a vehicle controller or actuator gateway;
- a production infotainment platform;
- a certified or safety-qualified HMI;
- a backend or hardware service implementation.

## Architectural principles

### Modular boundaries

Each major feature should eventually have an explicit domain boundary. Current Navigation, Media, Phone, and Climate modules are UI modules with local state, not complete independent applications.

### Reuse and composition

Reusable widgets and design tokens should be preferred over duplication. The current UI still contains known duplication and large screen files.

### Incremental change

Preserve working behavior and improve boundaries when an area is naturally changed. Do not perform an unapproved broad rewrite.

### Evidence before claims

Architecture and design goals are not validation. Frame rate, memory, accessibility, hardware lifecycle, safety, security, and compliance require target-platform evidence.

### Fail closed for safety-relevant data

Mock data must remain identifiable as simulated. A future vehicle build must not present unknown, stale, invalid, or unauthorized values as trusted vehicle state.

## Current implementation

```text
SkyUIApp
├── Header
│   └── DriveModeService debug listener in debug builds
└── HomeScreen
    ├── Sidebar
    ├── VehicleCard
    ├── MediaCard
    ├── NavigationCard
    ├── PhoneCard
    ├── ClimateBar
    └── Coordinated local overlay state
        ├── NavigationScreenContent
        ├── MediaScreenContent
        └── PhoneScreen
```

Current routing is one `MaterialApp` route. There is no named-route graph, independent application process, domain service container, or hardware boundary.

## Current project structure

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
```

Current responsibilities:

- `core/`: shared theme and icon resources; it must not import screens.
- `screens/`: stateful page-level UI and local prototype behavior.
- `services/drive_mode_service.dart`: debug-only parked/driving notifier used by the Media browsing guard.
- `widgets/`: dashboard cards, shell, climate, header, and sidebar components.
- `test/`: widget and state-transition tests.
- `web/flutter_bootstrap.js`: CSP-compatible web bootstrap with local CanvasKit configuration.

There is no current `lib/models/` directory. Media and Navigation value objects remain private to screen files, and Phone uses private local fixtures.

## State ownership

| Concern | Current owner | Lifetime and limitation |
| :--- | :--- | :--- |
| Expanded destination | `HomeScreen` | Root route; coordinated but not a durable router |
| Demo call | `PhoneScreen` | Phone overlay; not a telephony session |
| Media playback and queue | `MediaScreenContent` | Media overlay; reset on teardown |
| Navigation selection and map position | `NavigationScreenContent` | Navigation overlay; reset on teardown |
| Climate values | `ClimateBar` child state | Home widget lifetime |
| Debug parked/driving state | `DriveModeService` | Process lifetime; not a vehicle source |
| Compact media card state | `MediaCard` fixture state | Card lifetime; not synchronized with expanded Media |

This ownership map documents the current prototype. It is not a target domain model.

## Target logical architecture

```text
UI widgets and screens
        ↓
Domain state and services
        ↓
Models and contracts
        ↓
Data sources and external adapters
```

### UI layer

Responsible for:

- rendering;
- animation;
- input handling;
- navigation presentation;
- accessibility semantics;
- visible simulation and unavailable states.

### Domain layer

Responsible for:

- call, media, navigation, climate, and driver-policy state;
- state machines and lifecycle;
- validation and derived values;
- command authorization requests;
- freshness and fault presentation models.

### Contract/model layer

Future contracts should define, as applicable:

- stable identifiers and schema version;
- source and authority;
- value range and unit;
- timestamp, freshness, and validity interval;
- quality, degraded, stale, fault, and simulation states;
- command idempotency and authorization context;
- privacy classification where data is personal or sensitive.

### Data-source layer

Future adapters may include:

- vehicle gateway;
- GPS/map provider;
- Bluetooth/carrier/telephony;
- audio HAL;
- HVAC/charging service;
- diagnostics;
- OTA and backend services.

The UI must never connect directly to raw CAN, LIN, or AVB and must not be the trust boundary for safety-critical commands.

## Dependency direction

Target rule:

```text
Screen → Domain service/state → Model/contract → Data source
```

Target prohibitions:

- models must not import UI;
- services must not render widgets;
- UI must not bypass domain authorization to issue hardware commands;
- data sources must not own presentation state.

Current violations are known:

- Media, Phone, Navigation, and Climate keep domain/session state in widgets.
- Timers and lifecycle transitions are widget-owned.
- Domain-like value classes live inside screen files.
- No shared data-source boundary exists.

## Screen composition

Large screens should be composed from focused widgets. A 48 dp hit area and a small widget file are different concerns.

Current major screen files exceed the preferred approximately 300-line guidance. The HMI audit records this as architectural debt. Split natural sections when those areas are next changed rather than rewriting the complete application.

## Design and asset rules

New and modified shared values should use theme tokens where practical. Existing inline colors, typography, spacing, and radii are known debt; the design system is not yet the sole runtime source of truth.

Assets must be declared through the package configuration. Simulation fixtures must be visibly or semantically identified when they represent vehicle, route, device, climate, or diagnostic state.

## Performance direction

The 60 FPS value is a reference target, not a current guarantee. Release acceptance requires target-device measurements for:

- p50/p95/p99 frame time;
- missed frames and input latency;
- UI and raster/GPU cost;
- memory and image cache;
- thermal and power behavior;
- suspend/resume and long-run stability.

Measure before optimizing. Do not add or remove blur, repaint boundaries, or animation effects speculatively.

## Current and planned modules

Current UI prototypes:

- Home dashboard;
- Navigation;
- Media;
- Phone;
- Vehicle card;
- Climate.

Planned service capabilities:

- driver interaction policy;
- persistent call/media/navigation sessions;
- signal provenance and validity;
- Bluetooth, telephony, audio, HVAC, GPS, and map adapters;
- diagnostics, profiles, AI, charging, and OTA.

## Refactoring and migration policy

Before a structural change:

1. Explain the current problem.
2. Describe the proposed boundary and migration impact.
3. Identify compatibility and test requirements.
4. Obtain approval for broad changes.

For incremental work, extract the domain state or natural widget section being changed and add tests at the smallest useful boundary.

## Stability

This guide defines architectural intent. The current implementation is partial, and `docs/automotive_hmi_audit.md` takes precedence for known gaps and release blockers.
