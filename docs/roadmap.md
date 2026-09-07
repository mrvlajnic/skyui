# SkyUI Engineering Roadmap

**Version:** `v0.3.0-alpha`  
**Ecosystem:** Veltron Automotive Systems

---

## 🎯 Strategic Milestones

```
  [Phase 1: Foundation]       [Phase 2: Core Apps & HMI]     [Phase 3: Hardware Integration]     [Phase 4: Production]
         ✅ DONE                     ✅ COMPLETED (Alpha)           ⏳ UPCOMING                       ⏳ UPCOMING
   • Project Architecture      • 21:9 Ultrawide Layout        • CAN Bus / OBD-II Bridge         • ISO 26262 Review
   • Veltron Dark Theme        • Full Phone & Dialing Suite   • Live GPS Satellite Feed         • Automotive Hardware Run
   • Basic Shell & Sidebar     • 3-Section Music Player       • Veltron AI Voice Assistant      • Over-The-Air (OTA) Delivery
                               • Enhanced GPS & Speed HUD
                               • Animated Rail Indicator
```

---

## Phase 1 — UI & Architectural Foundation (Completed ✅)
- [x] Initial project scaffolding and modular Flutter structure.
- [x] Veltron Design System (color tokens, typography, radii, spacing).
- [x] Persistent sidebar navigation rail.
- [x] Universal status header with time and connection icons.

---

## Phase 2 — Digital Cockpit & Interactive HMI (`v0.3.0-alpha` Completed ✅)
- [x] **21:9 Ultrawide Layout Engine:** Optimized golden proportion grid (7:4:5 ratio).
- [x] **Dynamic Sliding Sidebar Indicator:** Seamless vertical glide tracking active destinations (`Curves.easeInOutCubic`).
- [x] **Interactive Vehicle Card:** Battery percentage, calculated driving range, door status, and quick launch triggers.
- [x] **Connected Media Hub & 3-Section Studio:**
  - [x] Vinyl disc visualizer, playback controls, and timeline scrubber.
  - [x] Dedicated 3-section layout preserving **anchored Navigation Card** in Section 3.
  - [x] Dynamic tracklist with live animated equalizer spectrum bars.
  - [x] 24-band spectrum visualizer and sound stage presets (*Meridian 3D*, *Driver Focus*, *All Seats*).
- [x] **Connected Phone & Telephony Cockpit:**
  - [x] Compact card telemetry.
  - [x] Full-screen dialing cockpit with contact book, category filters, and letter avatars.
  - [x] Automotive smartphone silhouette frame with live connectivity and battery gauge.
  - [x] DTMF 12-key numeric keypad dialer with live buffer and quick telephony toggles.
- [x] **Navigation Subsystem & Enhanced HUD:**
  - [x] Compact card view with vector map canvas.
  - [x] Smooth animated full-screen expansion transition (350ms cubic ease).
  - [x] Regulatory speed limit circle (80 km/h) alongside vehicle speed.
  - [x] Turn-by-turn guidance banner and speed/ETA telemetry.
  - [x] Viewport controls (Recenter, Layers, 2D/3D tilt, Zoom) and route waypoints.
- [x] **Aerodynamic Climate Bar:**
  - [x] Custom clipped aerodynamic silhouette with signature red accent stripe.
  - [x] Dual-zone independent temperature regulation (0.5° steps).
  - [x] 3-level seat heater controls and 4-step fan speed with AUTO mode.
  - [x] Center trip efficiency and tire diagnostics display.
- [x] **Standalone Desktop Cockpit Simulator:** Borderless 1680x720 launcher via `run_app.bat` / `run_app.py`.
- [x] **Alpha Terms of Service & Automotive Safety Disclaimer.**

---

## Phase 3 — Hardware Bridges & Automotive Services (Upcoming ⏳)
- [ ] **Hardware Abstraction Layer (HAL):** CAN Bus, OBD-II, and LIN bus bridge.
- [ ] **Live GPS & Map Tile Provider:** Real vector tile rendering engine with real-world turn-by-turn GPS routing.
- [ ] **Veltron AI Voice Assistant:** Wake-word detection and in-vehicle voice commands ("Set temperature to 21 degrees", "Navigate home").
- [ ] **User Profiles & Cloud Sync:** Driver personalization, mirror memory, seat positions, and media playlists.
- [ ] **In-Cabin Diagnostics & Charging Planner:** Real-time supercharger routing and battery thermal conditioning.

---

## Phase 4 — Security, Verification & Release (Upcoming ⏳)
- [ ] Automotive cybersecurity review (UNECE WP.29 compliance).
- [ ] Functional safety verification (ISO 26262 compliance).
- [ ] Over-The-Air (OTA) firmware delta update pipeline.
- [ ] Commercial fleet & consumer vehicle integration.
