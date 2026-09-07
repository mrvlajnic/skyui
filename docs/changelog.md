# Changelog

All notable changes to the **SkyUI** (Veltron OS) project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [v0.3.0-alpha] - 2026-09-07

### 🚀 Added
- **Dedicated Music & Media Studio (`lib/screens/media/media_screen_content.dart`):**
  - **Ergonomic 3-Section Ultrawide Architecture:** Screen splits into Section 1 (Library & Queue), Section 2 (Now Playing Hero Stage), and Section 3 (**Anchored Navigation Card** preserved in its exact dashboard position for driver safety).
  - **Multi-Source Audio Selector:** Seamless toggling between *Veltron Sounds*, *Spotify*, *Radio DAB+*, and *Bluetooth*.
  - **Live Dynamic Tracklist & Queue:** Interactive song list with real-time animated equalizer spectrum bars on the active track, durations, and tap-to-play.
  - **Rotating Vinyl Record Visualizer:** 360° rotating disc with realistic light grooves, album art label, and Veltron center badge, synchronized to play/pause state.
  - **24-Band Audio Spectrum Waveform:** Dynamic multi-frequency audio waveform bars responding during playback.
  - **In-Cabin Sound Stage Presets:** Instant acoustic profiling for *Meridian 3D*, *Driver Focus*, and *All Seats*.
  - **High-Res Audio Telemetry:** Real-time format badge (*FLAC 96kHz / 24-bit*) and audio system diagnostics.
  - **Full Audio Transport Controls:** Scrubber slider with elapsed/total timestamps, Shuffle, Previous, glowing Play/Pause button, Next, Repeat, and Volume slider with Mute toggle.
- **Dedicated Phone & Telephony Cockpit (`lib/screens/phone/phone_screen_content.dart`):**
  - **Dual-Pane Cockpit Layout:** Fluid 350ms cubic expansion from `PhoneCard` into a dedicated communications station.
  - **Contact Directory & Filter Matrix:** Search input, category pills (*All*, *Favorites*, *Recents*, *Missed*), alphabet letter avatars, and direct dial buttons.
  - **Automotive Smartphone Silhouette Frame:** Realistic smartphone bezel displaying paired device connectivity ("Connected via Bluetooth 5.3", 5G signal, 89% battery).
  - **DTMF Keypad Dialer:** 12-key automotive touch dialer (1-9, 0, *, # with sub-letters), live number buffer display with backspace, glowing green Call button, and quick toggles (*Voicemail*, *Mute*, *Speaker*).
- **Advanced Navigation & GPS HUD Upgrade (`lib/screens/navigation/navigation_screen_content.dart`):**
  - **Speed Limit Sign HUD:** Prominent regulatory speed sign (80 km/h) beside real-time vehicle speed telemetry (65 km/h).
  - **Destination Category Chips:** Quick search shortcuts (*Supercharger*, *Coffee*, *Parking*, *Saved*).
  - **Floating Viewport Controls:** Recenter map button, layer switcher (Traffic/Satellite/3D), 2D/3D tilt toggle, and Zoom (+/-) buttons.
  - **Multi-Route Waypoint Options:** Toggle between Fastest Route (14.2 km · 24 min) and Eco Route (16.1 km · 28 min).
- **Smooth Animated Sidebar Selector Indicator (`lib/widgets/sidebar/sidebar.dart`, `sidebar_item.dart`):**
  - Upgraded vertical navigation rail with an animated sliding cursor (`Curves.easeInOutCubic`) that glides fluidly to the selected icon.
- **Tri-Directional Expansion Coordinator (`lib/screens/home/home_screen.dart`):**
  - Unified multi-overlay system managing independent transitions for Navigation, Phone, and Media.
  - Specialized partial-width expansion for Media that anchors the Navigation Card without visual obstruction or fading.

---

## [v0.2.0-alpha] - 2026-09-07

### 🚀 Added
- **21:9 Ultrawide Layout Engine:** Configured dynamic proportions (7:4:5 ratio) for ultra-wide panoramic automotive displays.
- **Interactive Navigation Overlay:** Smooth cubic ease transition (350ms) expanding compact navigation into a full-screen view.
- **Turn-by-Turn Guidance Banner:** Visual maneuver arrows, distance-to-turn notifications, and destination ETA card.
- **Full-Screen Map Canvas:** Custom vector painter featuring stylized city blocks, grid matrix, and glowing orange route trail.
- **Aerodynamic Dual-Zone Climate Panel:**
  - Custom canvas clipped chassis with slanted aerodynamic edge and red racing accent line.
  - Independent driver and passenger temperature adjustment in 0.5° increments.
  - 3-stage heated seat controller with active LED indicators.
  - 4-speed fan speed selector with automatic regulation mode.
  - Center trip efficiency telemetry (efficiency percentage, tire pressure, trip miles).
- **Vehicle Telemetry Card:**
  - Real-time battery status bar (76%).
  - Range estimation display (385 km).
  - Power lock status indicator.
  - Direct vehicle quick actions (Search, Charging, Climate, Driver Profile).
- **Connected Media Player:**
  - Vinyl disc visualizer with subtle radial lighting and borders.
  - Playback transport controls (Play/Pause, Skip Next/Previous).
  - Time-remaining progress scrubber.
- **Telephony & Connectivity Card:**
  - Paired smartphone indicator ("Marko's iPhone").
  - Dynamic 4-bar cellular signal strength meter and phone battery level gauge.
  - Quick action dials for phone and messaging.
- **Standalone 21:9 App Launcher (`run_app.bat` / `run_app.py`):**
  - Instant local server with automated borderless Chrome/Edge window launch (1680x720).
  - Zero browser bars or tabs for true embedded cockpit simulation.
- **Official Alpha Terms of Service (`docs/terms_of_service.md`):** Complete automotive and experimental software disclaimers.

### 🔄 Changed
- Refactored `HomeScreen` to coordinate overlay state and simultaneous fade-out of adjacent dashboard cards.
- Polished color palette tokens according to the Veltron Automotive Dark Design System.
- Updated `README.md` with current milestones, feature breakdown, and release badges.

---

## [v0.1.0-alpha] - 2026-09-01

### 🚀 Added
- Initial project architecture and modular Flutter directory structure.
- Veltron Dark theme foundation (`colors.dart`, `spacing.dart`, `radius.dart`, `text_styles.dart`).
- Top system status header bar with clock, weather, and connection icons.
- Persistent left vertical sidebar navigation rail with Veltron brand mark.
- Desktop preview capability.
