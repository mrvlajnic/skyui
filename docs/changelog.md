# Changelog

All notable changes to the **SkyUI** (Veltron OS) project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
