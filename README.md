# Veltron OS — SkyUI

<p align="center">
  <img src="assets/images/logo.png" alt="SkyUI Logo" width="160"/>
</p>

<p align="center">
  <strong>Next-Generation Automotive Infotainment Operating System</strong><br/>
  Designed for the Veltron Electric Vehicle Ecosystem
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-v0.3.0--alpha-orange.svg?style=for-the-badge&logo=flutter" alt="Version: v0.3.0-alpha"/>
  <img src="https://img.shields.io/badge/stage-Alpha%20Milestone-red.svg?style=for-the-badge" alt="Stage: Alpha Milestone"/>
  <img src="https://img.shields.io/badge/display-21%3A9%20Ultrawide-blue.svg?style=for-the-badge" alt="Display: 21:9 Ultrawide"/>
  <img src="https://img.shields.io/badge/license-Veltron%20Proprietary-darkgreen.svg?style=for-the-badge" alt="License: Proprietary"/>
</p>

---

## 📌 Executive Overview

**SkyUI** is a custom, automotive-grade digital cockpit and infotainment human-machine interface (HMI) built from the ground up for future **Veltron** electric vehicles. 

> [!IMPORTANT]
> **SkyUI is NOT a mobile or tablet application.** It is an in-vehicle automotive digital cockpit interface engineered for low driver distraction, 60 FPS real-time fluid animations, ultrawide aspect ratios, and deep vehicle hardware telemetry.

---

## 🚀 Current Status & Progress Matrix

### Release Tag: `v0.3.0-alpha` (Build 2026.09 — Major Milestone)

We have completed the core triad of automotive applications: **Advanced Navigation & HUD**, **Dedicated Phone & Dialing Suite**, and **Multi-Section Media / Music Player** with anchored navigation UX and smooth cubic transitions.

| Module / System | Status | Version / Details |
| :--- | :---: | :--- |
| **System Architecture & Theme** | ✅ Complete | Modular UI hierarchy, custom Veltron Dark tokens, responsive scale |
| **21:9 Ultrawide Layout Engine** | ✅ Complete | Golden proportion grid (7:4:5 ratio for Vehicle, Media/Phone, Navigation) |
| **Dynamic Sliding Sidebar Indicator** | ✅ Complete | Silky smooth sliding selector animation (`Curves.easeInOutCubic`) tracking active destinations |
| **Vehicle Telemetry Card** | ✅ Complete | Battery state (76%), real-time range estimation (385 km), doors lock indicator, car render, quick actions |
| **Connected Media Card & Studio** | ✅ Complete | Vinyl disc visualizer, compact card & 3-section expanded studio with anchored Section 3 Navigation |
| **Dedicated Phone & Dialing Suite** | ✅ Complete | Dual-pane cockpit: Contact book, category filters, smartphone silhouette frame, DTMF numpad dialer |
| **Interactive Navigation Card & Enhanced HUD** | ✅ Complete | Vector map canvas, speed limit sign HUD, turn-by-turn instruction banner, floating map controls, route options |
| **Aerodynamic Climate Control Bar** | ✅ Complete | Slanted edge automotive silhouette with racing red accent, dual-zone independent temps, 3-stage heated seats, 4-level fan |
| **Status Header & Connectivity** | ✅ Complete | Brand emblem, live system clock, LTE/5G, Wi-Fi, Bluetooth status indicators |
| **Standalone 21:9 App Runner** | ✅ Complete | Borderless browser app launcher (`run_app.bat` / `run_app.py`) for native 1680x720 ultrawide cockpit simulation |
| **CAN Bus / OBD-II Hardware Bridge**| 🔄 In Progress | Virtual telemetry feed mock for testing vehicle signals |
| **Voice / AI Assistant** | ⏳ Planned | Veltron AI contextual voice control |
| **OTA Update Engine** | ⏳ Planned | Cryptographically signed firmware / UI delta updates |

---

## 📸 Cockpit Showcase & Core Features

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
│  VELTRON OS               [ 21:9 Automotive Digital Cockpit ]                       18°C  20:45  │
├────┬─────────────────────────────┬──────────────────────────┬────────────────────────────────────┤
│    │  VEHICLE TELEMETRY          │  CONNECTED MEDIA         │  NAVIGATION SYSTEM                 │
│ [=]│  • Ready to Drive           │  • "Night Drive"         │  • Live Vector Map Canvas          │
│    │  • Battery: 76% (385 km)    │  • Veltron Sounds        │  • Glowing Route Trail             │
│ [N]│  • Doors: Locked            │  • Transport Controls    │  • Expanding Full-Screen Mode      │
│    │  • 3D Vehicle Render        ├──────────────────────────┤  • Speed Limit & Maneuver HUD      │
│ [M]│  • Quick Charging/Profile   │  PHONE & COMMS           │  • Live Speed & ETA Telemetry      │
│    │                             │  • Marko's iPhone (5G)   │                                    │
│ [P]│                             │  • Battery & Signal Bar  │                                    │
├────┴─────────────────────────────┴──────────────────────────┴────────────────────────────────────┤
│  CLIMATE CONTROL BAR: [ 22.0°C | Heated Seats Lvl 3 | Fan Speed 3 ]  [ 14.0% Eff ]  [ 22.0°C ]   │
└──────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 1. 21:9 Ultrawide Golden Layout & Animated Indicator
- Tailored for modern automotive panoramic dash displays.
- Mathematically balanced 7:4:5 column split keeps critical vehicle stats closest to the driver.
- Vertical sidebar includes a dynamic sliding selector indicator that glides fluidly (`Curves.easeInOutCubic`) to highlight the active view.

### 2. Dedicated Music / Media Screen with Anchored Navigation (3-Section Rule)
- Expanding from `MediaCard` or sidebar, the screen divides into 3 ergonomic cockpit zones:
  - **Section 1 (Left - Library & Queue):** Source pills (*Veltron Sounds*, *Spotify*, *Radio DAB+*, *Bluetooth*), search filter, interactive tracklist with **live animated mini equalizer bars** on playing tracks, and system audio telemetry (*Meridian 3D*, *FLAC 96kHz/24-bit*).
  - **Section 2 (Center - Hero Stage):** Spinning vinyl disc record with realistic grooves, 24-band audio spectrum waveform visualizer, sound stage presets (*Meridian 3D*, *Driver Focus*, *All Seats*), timeline scrubber, transport controls (Shuffle, Previous, glowing Play/Pause, Next, Repeat), volume slider, and close button.
  - **Section 3 (Far Right - Navigation Card):** **Crucial Driver UX:** The navigation card remains anchored in its exact dashboard position, fully visible and interactive, ensuring navigation awareness is never lost while managing audio.

### 3. Dedicated Phone & Dialing Cockpit
- Fluid expansion from `PhoneCard` into a comprehensive telephony center:
  - **Contact Directory:** Search contacts, category tabs (*All*, *Favorites*, *Recents*, *Missed*), avatar letter badges, direct dial buttons.
  - **Automotive Smartphone Silhouette Frame:** Realistic handset border showing paired device state ("Connected via Bluetooth 5.3", 5G, 89% battery).
  - **Integrated DTMF Keypad:** Full numeric dialing pad with sub-letters, live number preview with backspace, glowing green Call action, and quick toggles for Voicemail, Mute, and Speaker.

### 4. Advanced Navigation & GPS Suite
- **Speed Limit HUD:** Live speed limit circle (e.g. 80 km/h) paired with current vehicle speed (65 km/h).
- **Turn-by-Turn Guidance:** Next maneuver icon, street name, distance countdown, arrival time, remaining kilometers, and destination battery reserve (68%).
- **Map Tools & Search:** Category quick-chips (*Supercharger*, *Coffee*, *Parking*, *Saved*), floating map controls (Recenter, Layers, 2D/3D tilt, Zoom in/out), and alternative route cards (Fastest vs. Eco).

### 5. Dual-Zone Aerodynamic Climate Panel
- Custom canvas-clipped geometry with aerodynamic 20px slant and signature red accent stripe.
- Independent driver and passenger temperature controls in 0.5° increments.
- 3-level seat heater toggle with animated status LEDs and 4-speed fan control with auto-regulation.

---

## 🛠 Project Architecture

```
lib/
├── core/
│   ├── animations/          # Curve & timing specifications
│   ├── constants/           # Display & layout constants
│   ├── icons/               # Custom automotive vector icon set
│   └── theme/               # Veltron Design System (colors, styles, radii)
├── models/                  # Data contracts (Vehicle, Media, Route, Climate)
├── screens/
│   ├── home/                # Main dashboard coordinator & animation controller
│   ├── media/               # Dedicated 3-section music studio & visualizer
│   ├── navigation/          # Expanded full-screen navigation layout & GPS HUD
│   └── phone/               # Dedicated dialing cockpit & contact directory
├── services/                # Hardware bridges, telemetry, audio session
└── widgets/
    ├── app_card.dart        # Base automotive card surface
    ├── cards/               # Vehicle, Media, Phone, Navigation cards
    ├── climate/             # Aerodynamic bottom dual-zone climate panel
    ├── header/              # System status bar & telemetry indicators
    └── sidebar/             # Automotive quick-access vertical navigation rail with animated indicator
```

---

## ⚡ Getting Started

### Prerequisites
- **Flutter SDK**: `>= 3.12.0 < 4.0.0`
- **Dart SDK**: Compatible with Flutter release
- **Python 3.x** (for the standalone 21:9 ultrawide borderless launcher)
- **Google Chrome** or **Microsoft Edge** (for app-window desktop preview)

### Installation & Launch

1. **Clone the repository:**
   ```bash
   git clone https://github.com/VeltronCars/SkyUI.git
   cd SkyUI
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run via Standalone 21:9 Ultrawide Desktop Simulator (Recommended):**
   ```bash
   # Builds web target and launches borderless 1680x720 ultrawide window
   run_app.bat
   ```
   *Or execute directly with Python:*
   ```bash
   python run_app.py
   ```

4. **Run via native Flutter targets:**
   ```bash
   # Windows Desktop
   flutter run -d windows

   # Chrome Web
   flutter run -d chrome
   ```

---

## 📜 Terms of Service & Alpha Disclaimer

> ### **VELTRON OS / SKYUI ALPHA SOFTWARE DISCLAIMER**
> **Current Release Version:** `v0.3.0-alpha`  
> **Effective Date:** September 2026

PLEASE READ CAREFULLY BEFORE USING, INSTALLING, OR TESTING THIS SOFTWARE.

### 1. Alpha Stage & Experimental Status
SkyUI is distributed as an **Alpha version** for evaluation, testing, and concept prototyping purposes only. Features, architecture, visual interfaces, and APIs are subject to radical change without notice.

### 2. Automotive & Safety Disclaimer
- **NOT CERTIFIED FOR ACTIVE ROAD USE:** SkyUI is currently a prototype HMI. It is **NOT** certified under ISO 26262 (Functional Safety), UNECE, DOT, or automotive regulatory standards for direct vehicle control.
- **NO DRIVER DISTRACTION RESPONSIBILITY:** Under no circumstances should this software be operated on an active vehicle display while driving on public roads without independent secondary safety monitors. The driver bears 100% legal responsibility for vehicle control and traffic compliance at all times.

### 3. "AS-IS" Warranty Disclaimer
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL VELTRON CARS, ITS CONTRIBUTORS, OR DEVELOPERS BE LIABLE FOR ANY CLAIM, DAMAGES, ACCIDENTS, LOSS OF VEHICLE TELEMETRY, OR OTHER LIABILITY.

### 4. Proprietary Intellectual Property & License
SkyUI, the Veltron identity, visual assets, vehicle models, and custom UI components are proprietary intellectual property of **Veltron Cars**. Unauthorized reverse engineering, redistribution, or commercial vehicle deployment without explicit corporate authorization is strictly prohibited.

For the full detailed terms, legal restrictions, and testing agreements, see [docs/terms_of_service.md](docs/terms_of_service.md).

---

## 📚 Documentation Index

Explore the engineering specifications in [`docs/`](docs/):

- 📐 [Architecture Guide](docs/architecture.md) — High-level architecture, module contracts, and layers.
- 🎨 [Design System](docs/design_system.md) — Color tokens, typography, radii, and automotive rules.
- 📦 [Module Catalog](docs/modules.md) — Deep-dive into each component and card.
- 🗺 [Engineering Roadmap](docs/roadmap.md) — From Alpha to Beta and hardware validation.
- 📝 [Changelog](docs/changelog.md) — Version history and release notes.
- ⚖️ [Terms of Service](docs/terms_of_service.md) — Comprehensive legal & Alpha disclaimers.

---

<p align="center">
  <sub>Copyright © 2026 Veltron Cars. All rights reserved.</sub>
</p>