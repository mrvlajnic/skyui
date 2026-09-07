# SkyUI Module Catalog

**Version:** `v0.3.0-alpha`  
**System:** Veltron OS Automotive Cockpit

---

## 1. System Overview

SkyUI is organized into decoupled, highly cohesive modules. Each module is responsible for its own domain, state, and presentation layers without tight coupling to adjacent screens.

```
┌─────────────────────────────────────────────────────────────┐
│                          Header                             │
├───────────┬─────────────────────────────────────────────────┤
│           │                   Home Screen                   │
│           │  ┌──────────────┬──────────────┬─────────────┐  │
│           │  │   Vehicle    │    Media     │ Navigation  │  │
│  Sidebar  │  │     Card     ├──────────────┤    Card     │  │
│ (Sliding) │  │              │    Phone     │  (Expand)   │  │
│           │  └──────────────┴──────────────┴─────────────┘  │
│           ├─────────────────────────────────────────────────┤
│           │                 Climate Bar                     │
│           ├─────────────────────────────────────────────────┤
│           │  Expanded Apps: Media (3-Way) | Phone | Nav     │
└───────────┴─────────────────────────────────────────────────┘
```

---

## 2. Implemented Modules

### 2.1 Sidebar (`lib/widgets/sidebar/`)
- **Purpose:** Primary vertical navigation rail for driver quick-access.
- **Components:**
  - `sidebar.dart`: Main container anchored to the left of the cockpit.
  - `sidebar_logo.dart`: Veltron brand insignia and home anchor.
  - `sidebar_item.dart`: Navigational touch targets with active indicator bars and icon states.
  - **Dynamic Sliding Indicator:** Integrated continuous animated cursor (`Curves.easeInOutCubic`) that glides vertically between buttons on tab selection.

### 2.2 System Header (`lib/widgets/header/`)
- **Purpose:** Always-on status and telemetry strip.
- **Components:**
  - `header.dart`: Top system bar with clock, exterior temperature, and battery levels.
  - `status_icon.dart`: Cellular (LTE/5G), Wi-Fi, and Bluetooth connectivity icons.

### 2.3 Vehicle Card (`lib/widgets/cards/vehicle_card.dart`)
- **Purpose:** Central vehicle telemetry and quick drive modes.
- **Features:**
  - Ambient greeting and driving readiness indicator.
  - 3D vehicle perspective render.
  - Battery capacity gauge (76%) with color-coded safety margins.
  - Calculated driving range in kilometers (385 km).
  - Security status (Door lock / unlock indicator).
  - Quick action buttons: Search, Fast Charging, Climate Shortcuts, Driver Profile.

### 2.4 Media Hub (`lib/widgets/cards/media_card.dart` & `lib/screens/media/`)
- **Purpose:** In-cabin audio and streaming entertainment control.
- **Features:**
  - **Compact State:** Stylized vinyl disc illustration, current track metadata, transport controls, and dual-timestamp progress bar.
  - **Expanded 3-Section Studio:**
    - **Section 1 (Library & Queue):** Source pills (*Veltron Sounds*, *Spotify*, *Radio DAB+*, *Bluetooth*), search filter, interactive track queue with animated mini equalizer bars, and system audio telemetry.
    - **Section 2 (Now Playing Hero Stage):** Continuous spinning vinyl record animation, 24-band audio spectrum waveform visualizer, sound stage presets (*Meridian 3D*, *Driver Focus*, *All Seats*), timeline scrubber, transport controls, and volume slider.
    - **Section 3 (Anchored Navigation):** Preserves the dashboard Navigation Card in its exact right-hand position with zero occlusion, preserving driver road awareness.

### 2.5 Telephony & Communications (`lib/widgets/cards/phone_card.dart` & `lib/screens/phone/`)
- **Purpose:** Hands-free mobile device pairing and communication hub.
- **Features:**
  - **Compact State:** Paired smartphone telemetry, 4-bar cellular connection meter, battery gauge, and call/message triggers.
  - **Expanded Cockpit:**
    - **Left Column:** Searchable contact directory, category tabs (*All*, *Favorites*, *Recents*, *Missed*), alphabet letter avatars, and direct dial buttons.
    - **Right Column:** Stylized automotive smartphone silhouette frame, paired Bluetooth status, 12-key DTMF keypad dialer with live number display, call action trigger, and quick toggles (*Voicemail*, *Mute*, *Speaker*).

### 2.6 Interactive Navigation Engine (`lib/widgets/cards/navigation_card.dart` & `lib/screens/navigation/`)
- **Purpose:** Turn-by-turn guidance, destination search, and live map view.
- **Features:**
  - **Compact State:** Embedded canvas map with glowing cyan route preview, next turn preview, and trip ETA.
  - **Animated Expansion:** Seamless transition scaling the navigation card across the full content deck.
  - **Full-Screen HUD & Tools:**
    - Regulatory speed limit circle (80 km/h) paired with live vehicle speed (65 km/h).
    - Turn-by-turn instruction banner ("Turn right onto Veltron Way in 300m") and destination arrival telemetry.
    - Category search chips (*Supercharger*, *Coffee*, *Parking*, *Saved*).
    - Floating viewport controls: Recenter map, map layers, 2D/3D tilt, zoom in/out.
    - Alternative route waypoints (Fastest Route vs. Eco Route).

### 2.7 Climate Control Panel (`lib/widgets/climate/climate_bar.dart`)
- **Purpose:** Cabin environmental control and thermal management.
- **Features:**
  - Aerodynamic custom-clipped border with signature red racing accent line.
  - Independent dual-zone temperature control for driver and passenger (0.5° increments).
  - 3-stage seat heater levels with active LED indicator dots.
  - 4-speed fan control with automated temperature stabilization mode.
  - Center trip diagnostic summary: trip energy efficiency, tire status, and trip odometer.

---

## 3. Upcoming Modules (Phase 2 & Phase 3)

- **CAN Bus / OBD-II Telemetry Service:** Real-time automotive sensor bridge.
- **AI Voice Assistant:** Voice-activated natural language interface.
- **Driver Profiles & Biometrics:** Cloud sync of seat position, mirrors, and audio preferences.
- **OTA Update Client:** Seamless firmware delta streaming over LTE/Wi-Fi.
