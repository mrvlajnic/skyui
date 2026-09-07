# Veltron OS — SkyUI Terms of Service & Alpha Agreement

**Product:** SkyUI Infotainment System (Veltron OS)  
**Version:** `v0.3.0-alpha`  
**Effective Date:** September 7, 2026  
**Document Status:** Official Alpha Release Terms

---

## 1. Acceptance of Terms

By downloading, installing, launching, compiling, or interacting with the **SkyUI** software repository, binaries, mockups, or source code (collectively, the "Software"), you ("User", "Tester", or "Developer") agree to be bound by the terms and conditions set forth in this Terms of Service & Alpha Agreement ("Agreement"). 

If you do not agree with any part of these terms, do not download, install, build, or operate this Software.

---

## 2. Alpha Stage Evaluation & Scope of License

### 2.1 Experimental Status
SkyUI is currently provided in an **Alpha preview state** (`v0.3.0-alpha`). The software is actively under development, and features, user interfaces, logic controllers, animations, and communication protocols are subject to change, redesign, or discontinuation at any time without notice.

### 2.2 Limited Evaluation License
Veltron Cars grants authorized testers and developers a limited, non-exclusive, non-transferable, revocable license to use the Software solely for:
- Internal evaluation, simulation, and prototyping;
- UI/UX validation on desktop simulators and lab benches;
- Feedback and bug reporting.

Commercial deployment, public distribution, or installation into consumer-delivered production vehicles without explicit written authorization from Veltron Cars is strictly forbidden.

---

## 3. Critical Automotive Safety & In-Vehicle Disclaimer

> [!CAUTION]
> **READ CAREFULLY: AUTOMOTIVE SAFETY WARNING**
>
> SkyUI is an **un-certified experimental software prototype**. It has NOT been certified according to automotive functional safety standards (including ISO 26262, ASIL ratings, UNECE cybersecurity standards, or Federal Motor Vehicle Safety Standards).

### 3.1 Prohibition on Unmonitored Public Road Operation
- Under no circumstances should this software be utilized as the sole or primary driver interface during active vehicle operation on public roads or in hazardous driving environments.
- The interface must never be used in a manner that obstructs primary driving instrumentation, cluster alerts, or safety-critical malfunction indicators (such as ABS, airbags, powertrain faults, or braking systems).

### 3.2 Driver Responsibility & Distraction Mitigation
- The human operator of any vehicle containing this software retains **100% legal, civil, and criminal responsibility** for the safe operation of the vehicle, adherence to traffic laws, and monitoring of physical surroundings.
- Visual elements, dynamic animations, and map interactions must never be operated while driving in any situation where full attention to the road is required.

---

## 4. Vehicle Hardware, CAN Bus & Electrical Testing

### 4.1 Bus Architecture Caution
Any future or experimental integration with vehicle hardware interfaces (including Controller Area Network (CAN Bus), OBD-II diagnostic ports, LIN buses, or Ethernet AVB) carries risk of electrical interference or bus collision.

### 4.2 Safe Test Environment
All hardware-in-the-loop (HIL) or CAN-connected testing must be conducted exclusively:
1. While the vehicle is stationary and parked with the parking brake engaged; or
2. On isolated laboratory test benches and dynamometers under controlled engineering supervision.

Veltron Cars assumes no liability for vehicle battery drain, ECU bricking, or actuator interference caused by test builds.

---

## 5. Intellectual Property Rights

### 5.1 Proprietary Ownership
All rights, title, and interest in and to SkyUI, including but not limited to source code, algorithms, graphical assets, 3D vehicle renders, logo marks, sounds, color system tokens, and design language are the exclusive intellectual property of **Veltron Cars** and its licensors.

### 5.2 Restrictions
Except as expressly authorized under a separate bilateral agreement, you agree not to:
- Reverse engineer, decompile, or disassemble proprietary binary components;
- Remove or alter any copyright notices, watermarks, or version tags (`v0.2.0-alpha`);
- Rebrand, repackage, or distribute modified copies under another commercial name.

---

## 6. Telemetry, Diagnostic Logs & Feedback

### 6.1 Crash Reporting & Metrics
Alpha builds of SkyUI may collect diagnostic telemetry, frame rates, exception traces, and simulated sensor events to assist engineering teams in stability and performance optimization.

### 6.2 Feedback Assignment
Any suggestions, bug reports, pull requests, performance benchmarks, or feature proposals submitted by you regarding the Software become the non-exclusive, royalty-free, perpetual property of Veltron Cars to integrate into future versions without compensation.

---

## 7. Disclaimer of Warranties ("AS-IS")

TO THE MAXIMUM EXTENT PERMITTED UNDER APPLICABLE LAW, THE SOFTWARE IS PROVIDED ON AN **"AS IS"** AND **"AS AVAILABLE"** BASIS, WITH ALL FAULTS AND DEFECTS.

VELTRON CARS EXPRESSLY DISCLAIMS ALL WARRANTIES, WHETHER STATUTORY, EXPRESS, OR IMPLIED, INCLUDING BUT NOT LIMITED TO:
- WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR AUTOMOTIVE PURPOSE;
- UNINTERRUPTED, BUG-FREE, OR LAG-FREE 60 FPS EXECUTION;
- ACCURACY OR TIMELINESS OF NAVIGATION, ROUTE ESTIMATION, OR SENSOR TELEMETRY;
- COMPATIBILITY WITH ALL VEHICLE HARDWARE OR OPERATING PLATFORMS.

---

## 8. Limitation of Liability

IN NO EVENT SHALL VELTRON CARS, ITS AFFILIATES, DIRECTORS, EMPLOYEES, OR CODE CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, PUNITIVE, OR CONSEQUENTIAL DAMAGES (INCLUDING LOSS OF PROFITS, LOSS OF VEHICLE TELEMETRY, HARDWARE DAMAGE, VEHICLE ACCIDENTS, PERSONAL INJURY, OR REPAIR COSTS) ARISING OUT OF OR IN CONNECTION WITH THE USE OR INABILITY TO USE THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

---

## 9. Versioning & Modifications to Terms

- **Current Version Tag:** `v0.2.0-alpha`
- Veltron Cars reserves the right to revise, update, or supersede these Terms of Service as the software advances toward Beta, Release Candidate (RC), and General Availability (GA).
- Continued usage of the repository or compiled artifacts following published updates constitutes acceptance of the modified terms.

---

## 10. Contact & Inquiries

For legal, automotive compliance, licensing, or corporate partnership inquiries regarding Veltron OS and SkyUI:

- **Ecosystem:** Veltron Automotive Systems
- **Repository:** `https://github.com/VeltronCars/SkyUI`
- **Engineering Team:** Infotainment & Digital Cockpit HMI Group

---
*Copyright © 2026 Veltron Cars. All rights reserved.*
