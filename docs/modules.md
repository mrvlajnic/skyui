# SkyUI Module Catalog

Package version: `0.3.0-alpha+1`

Status: current UI prototype inventory

## System overview

SkyUI is a dashboard shell with reusable cards and three large stateful prototype screens. The modules are not yet decoupled domain applications and do not have a shared session/service layer.

```text
Header
└── HomeScreen
    ├── Sidebar
    ├── VehicleCard
    ├── MediaCard
    ├── PhoneCard
    ├── NavigationCard
    ├── ClimateBar
    └── One coordinated expanded module
        ├── NavigationScreenContent
        ├── MediaScreenContent
        └── PhoneScreen
```

All displayed vehicle, device, route, speed, trip, climate, and diagnostic values are local fixtures unless explicitly marked otherwise.

## 1. Header

Path: `lib/widgets/header/`

Current behavior:

- Veltron brand text.
- Fixed demo time `10:42`.
- Simulated Bluetooth, cellular, and Wi-Fi semantics.
- Debug-only parked/driving toggle linked to `DriveModeService`.
- No live clock, network service, vehicle signal, or telemetry source.

## 2. Sidebar

Path: `lib/widgets/sidebar/`

Current destinations:

- Home;
- Navigation;
- Media;
- Phone;
- Vehicle — disabled because the screen does not exist;
- Settings — disabled because the screen does not exist.

The selected item has a local active background, border, icon color, and indicator bar. There is no verified global sliding cursor between items.

The current 90 dp rail and 56 dp item containers are implementation details at the 1680×720 baseline, not physical automotive measurements.

## 3. Vehicle card

Path: `lib/widgets/cards/vehicle_card.dart`

Current behavior:

- Static vehicle render.
- `DEMO DATA` label.
- Simulated greeting, weather, battery, range, and door state.
- Disabled Search, Charging, Climate, and Driver Profile actions with unavailable semantics.
- No CAN/OBD gateway, signal timestamp, freshness, validity, fault, or command authorization.

The values are not a safety assessment or a connected vehicle state.

## 4. Media

Paths:

- `lib/widgets/cards/media_card.dart`
- `lib/screens/media/media_screen_content.dart`

Compact card:

- opens the expanded Media module;
- displays fixture track metadata and transport artwork;
- does not expose independent transport actions;
- progress is local and not synchronized with expanded playback.

Expanded Media:

- source chips update only a local source index;
- queue selection and playback controls update widget state;
- playback position advances only while the local timer is active;
- source names, FLAC/Dolby labels, speaker count, and equalizer visuals are simulated;
- no stream, decoder, audio HAL, source telemetry, or speaker-health service is connected;
- Media state is reset when the overlay is disposed;
- Media browsing is hidden while the debug `driving` state is active.

The Navigation card remains geometrically visible in the current 1680×720 Media layout. Driver-awareness and distraction benefits have not been optically or behaviorally validated.

## 5. Phone

Paths:

- `lib/widgets/cards/phone_card.dart`
- `lib/screens/phone/phone_screen.dart`

Current behavior:

- compact card shows a synthetic prototype handset and no active call;
- Dialer and synthetic Recent Calls tabs render different content;
- selecting a recent fills the number and returns to the Dialer;
- an explicit Call action starts a local demo-call state machine;
- numeric keypad is number entry, not DTMF;
- Mute is local state and enabled only during the active demo call;
- active call blocks sidebar and Back until End is used;
- Contacts, Voicemail, telephony, carrier state, contacts provider, Bluetooth integration, DTMF, Speaker, and in-call keypad are not implemented;
- call state is not persistent across app lifecycle or a future route architecture.

Fixtures use synthetic names and reserved demo numbers.

## 6. Navigation

Paths:

- `lib/widgets/cards/navigation_card.dart`
- `lib/screens/navigation/navigation_screen_content.dart`

Current behavior:

- custom-painted map with fixture destinations;
- destination selection animates the puck toward the selected fixture;
- maneuver, speed, limit, ETA, distance, and arrival values are fixtures;
- Traffic toggles a painted visual layer, not live traffic;
- Recalculate replays the selected fixture destination, not a routing calculation;
- Zoom, Recenter, and 3D controls are disabled because no map-camera model exists;
- free map tap was removed because it changed only a hidden target;
- no GPS, road graph, map provider, route engine, live traffic, or vehicle signal source exists.

The route/status area explicitly labels the route as simulated.

## 7. Climate

Path: `lib/widgets/climate/climate_bar.dart`

Current behavior:

- local temperature, fan, and seat-heat visual state;
- no HVAC command path;
- no validated min/max range or quantization contract;
- no automatic regulation, stale sensor handling, CAN fault, or vehicle safety behavior;
- center trip/efficiency/tire/trip values are fixtures, not diagnostics.

The current `AUTO` presentation is not connected to a climate-control algorithm.

## Current state boundaries

| Concern | Owner | Limitation |
| :--- | :--- | :--- |
| Dashboard expansion | `HomeScreen` | Local overlay state |
| Media playback | `MediaScreenContent` | Lost on overlay teardown |
| Demo call | `PhoneScreen` | Not a durable call session |
| Navigation selection | `NavigationScreenContent` | Local fixture state |
| Climate | `ClimateBar` and child state | No service boundary |
| Drive mode | `DriveModeService` | Debug/demo notifier only |

## Planned capabilities

These are not current modules or integrations:

- central driver interaction policy;
- persistent call, media, navigation, and climate sessions;
- CAN/OBD/LIN/AVB and vehicle gateway;
- GPS and map/traffic provider;
- Bluetooth, telephony, contacts, DTMF, and carrier services;
- audio HAL and stream/decoder services;
- HVAC, charging, and diagnostics;
- AI/voice assistant;
- profiles and cloud sync;
- OTA/update security;
- backend, telemetry, crash reporting, and analytics.

See `docs/roadmap.md` and `docs/automotive_hmi_audit.md` for gates and blockers.
