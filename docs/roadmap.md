# SkyUI Engineering Roadmap

**Version:** `v0.2.0-alpha`  
**Ecosystem:** Veltron Automotive Systems

---

## 🎯 Strategic Milestones

```
  [Phase 1: Foundation]       [Phase 2: Core Apps & HMI]     [Phase 3: Hardware Integration]     [Phase 4: Production]
         ✅ DONE                     🔄 CURRENT                     ⏳ UPCOMING                       ⏳ UPCOMING
   • Project Architecture      • 21:9 Ultrawide Layout        • CAN Bus / OBD-II Bridge         • ISO 26262 Review
   • Veltron Dark Theme        • Animated Nav Expansion       • Live GPS Satellite Feed         • Automotive Hardware Run
   • Basic Shell & Sidebar     • Dual-Zone Aerodynamic HVAC   • Veltron AI Voice Assistant      • Over-The-Air (OTA) Delivery
                               • Connected Media & Phone
```

---

## Phase 1 — UI & Architectural Foundation (Completed ✅)
- [x] Initial project scaffolding and modular Flutter structure.
- [x] Veltron Design System (color tokens, typography, radii, spacing).
- [x] Persistent sidebar navigation rail.
- [x] Universal status header with time and connection icons.

---

## Phase 2 — Digital Cockpit & Interactive HMI (Current: `v0.2.0-alpha` 🔄)
- [x] **21:9 Ultrawide Layout Engine:** Optimized golden proportion grid (7:4:5 ratio).
- [x] **Interactive Vehicle Card:** Battery percentage, calculated driving range, door status, and quick launch triggers.
- [x] **Connected Media Hub:** Vinyl album art visualizer, playback controls, and progress timeline.
- [x] **Connected Phone Card:** Paired device status, signal meter, battery gauge, and call shortcuts.
- [x] **Navigation Subsystem:**
  - [x] Compact card view with vector map canvas.
  - [x] Smooth animated full-screen expansion transition (350ms ease).
  - [x] Turn-by-turn guidance banner and speed/ETA telemetry.
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
