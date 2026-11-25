# SkyUI Module Catalog

Package version: `0.3.0-alpha+1`

Status: Veltron Auto V1 SportLine HMI concept inventory

## System overview

SkyUI is a dashboard shell with reusable cards and five module screens (Navigation, Media, Phone, Vehicle, Settings). The modules are not yet decoupled domain applications and do not have a shared session/service layer beyond the map state.

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
- Vehicle — opens the telemetry module (demo values, no CAN/OBD source);
- Settings — opens the demo configuration panel (route-speed control and build stamp).

The selected item uses a subtle neutral rounded highlight behind a bright icon; there is no edge bar, border, glow, or accent color. There is no verified global sliding cursor between items.

Sidebar icons are custom stroke SVG recreations from `assets/icons/*.svg`, rendered through the `SkyIcons` pack (`lib/core/icons/`) rather than Material or Phosphor glyphs.

The current 108 dp rail and adaptive 56–80 dp item rows are implementation details at the 1680×720 baseline, not physical automotive measurements. Destinations, Settings included, form one vertically centered group so the rail has no empty bottom shelf. Labels are exposed through tooltip and Semantics rather than rendered in the rail.

## 3. Vehicle card

Path: `lib/widgets/cards/vehicle_card.dart`

Current behavior:

- Static V1 exterior render, horizontally centered in the card.
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
- `lib/widgets/map/` (basemap surfaces)

Current behavior:

- real basemap in the compact panel: MapTiler `basic-v2` raster tiles through `flutter_map` on desktop and web, the `maplibre_gl` platform view on Android/iOS, and the painted fixture map when no API key is configured or the tile host is unreachable;
- a short reachability probe chooses the painted fallback instead of a blank surface;
- the basemap key is injected at build time (`--dart-define=MAPTILER_KEY=...`), read from the `MAPTILER_KEY` environment variable on desktop, or read from a git-ignored `maptiler_key.txt` / `.maptiler_key`;
- provider credit (`© MapTiler © OpenStreetMap contributors`) is shown as a small chip because the tile terms require it;
- the vehicle starts parked beside Kula Beograd (Belgrade Waterfront) with no initial route; a destination marker or search starts a trip;
- MapTiler geocoding and directions are used when a key is present; the provider geometry is drawn with distance and ETA;
- on Android/iOS device positioning (`geolocator`) drives the puck and route progress; desktop and web use the simulated drive;
- the compact home card mirrors the navigation route summary: destination, instruction, remaining distance/time, upcoming maneuver and total trip;
- Traffic toggles a painted visual layer, not live traffic;
- Zoom, Recenter and a heading-up chase control the camera; 3D is not implemented;
- no rerouting, voice guidance, live traffic or offline tiles exist; the basemap provider supplies imagery only.

The route/status area explicitly labels the route as simulated.

## 7. Climate

Path: `lib/widgets/climate/climate_bar.dart`

Current behavior:

- local temperature, fan, and seat-heat visual state;
- the bar reserves 104 dp and its contents scale from one ratio derived from the original 56 dp panel, so control sizes follow the bar height while horizontal spacing keeps its rhythm;
- left and right heated-seat glyphs are mirrored so they face each other;
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
| Basemap availability | `DashboardMap` / `NavigationScreenContent` | Per-widget probe; tiles are third-party imagery, not a position source |
| Climate | `ClimateBar` and child state | No service boundary |
| Drive mode | `DriveModeService` | Debug/demo notifier only |

## Planned capabilities

These are not current modules or integrations:

- central driver interaction policy;
- persistent call, media, navigation, and climate sessions;
- CAN/OBD/LIN/AVB and vehicle gateway;
- GPS, routing, and live-traffic services (basemap imagery already comes from MapTiler);
- Bluetooth, telephony, contacts, DTMF, and carrier services;
- audio HAL and stream/decoder services;
- HVAC, charging, and diagnostics;
- AI/voice assistant;
- profiles and cloud sync;
- OTA/update security;
- backend, telemetry, crash reporting, and analytics.

See `docs/roadmap.md` and `docs/automotive_hmi_audit.md` for gates and blockers.
