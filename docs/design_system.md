# SkyUI Design System

Package version: `0.3.0-alpha+1`

Status: prototype visual language and design requirements

## Purpose

This document defines the intended SkyUI visual language, interaction rules, and validation requirements. It is not evidence of physical-display, driver-workload, accessibility, or performance compliance.

The current implementation is partially tokenized. Inline colors, typography, spacing, and radii remain known debt.

## Design philosophy

SkyUI is an automotive-styled HMI prototype with a premium, calm, technical direction. It is intended to feel like a cockpit interface rather than a conventional mobile application, but that intention has not been validated on a vehicle display.

Design qualities:

- calm;
- legible;
- restrained;
- hierarchy-driven;
- consistent;
- explicit about system state.

## Current evidence boundary

The only current layout and browser smoke baseline is 1680×720 landscape. It is not validation of:

- physical panel dimensions or DPI;
- ultrawide or compact vehicle resolutions;
- portrait fallback;
- text scaling;
- RTL or long localized strings;
- sunlight, night mode, viewing angle, or panel gamma;
- driver distraction or workload.

## Color roles

Use semantic roles rather than treating one accent as universally dominant.

- Background: near-black application shell.
- Surface: slightly lighter card surface.
- Primary: blue selection and primary action.
- Secondary: cyan information and active-state emphasis.
- Route/map emphasis: orange.
- Success: green status.
- Warning: yellow or amber status.
- Error/destructive: red status.
- Disabled: low-contrast neutral with an explicit reason.

Status colors must not be the only carrier of meaning. Pair them with text, icon, shape, or state semantics.

The current token palette is represented by `lib/core/theme/colors.dart`, but many screens still use inline values.

## Typography

Typography should be readable, restrained, and hierarchy-driven.

Target roles:

- display: major page or cockpit title;
- headline: important module heading;
- title: section or card heading;
- body: normal information;
- label: concise state or control label.

Current limitations:

- much of the UI uses inline `TextStyle` values;
- several secondary labels are 8–12 logical pixels and are not optically validated;
- Roboto is requested by name, but fallback-font licensing and offline packaging are unresolved;
- text scale, RTL, localization, and screen-reader behavior are not validated.

Do not decrease critical text size to force a fixed layout. Adjust the layout or define a validated responsive profile.

## Layout

At the current 1680×720 baseline, the shell contains:

```text
Header
└── Sidebar + content
    └── Climate bar
```

The fixed 90 dp sidebar and 84 dp header are implementation details, not a responsive guarantee. The 7:4:5 dashboard grid is a prototype baseline for later display validation.

Every modified layout should document its supported viewport and its parked/driving policy.

## Spacing and tokens

Preferred spacing tokens are:

- 4;
- 8;
- 12;
- 16;
- 24;
- 32;
- 48;
- 64.

Existing code contains additional values and should be migrated incrementally rather than mass-rewritten. New and modified shared values should use tokens where practical.

## Radius and elevation

Cards use medium radius, controls use restrained radius, and dialogs may use larger radius. Avoid both sharp and excessively rounded forms.

Prefer soft borders, subtle gradients, and limited highlights over aggressive shadows. Do not add elevation effects without checking contrast and target-GPU cost.

## Motion

Motion should be subtle and purposeful.

Preferred durations:

- fast: 150 ms;
- normal: 250 ms;
- slow: 400 ms;
- current large screen transition: 350 ms.

The current Home transition uses 350 ms. Validate motion on the target display and respect reduced-motion settings when that capability is integrated. Decorative continuous animations must not be assumed safe for a moving vehicle.

## Navigation and information hierarchy

Navigation should prioritize the next critical maneuver, current speed/limit, route context, and critical warnings when real sources exist.

Current screen layout is a design intent, not a validated driver-attention result. Future validation must measure glance time, recognition, workload, and recovery from blocked or unavailable actions.

## Touch and physical ergonomics

- 48 dp is a programmatic minimum, not proof of physical target suitability.
- Touch areas must remain separated and must not overlap.
- Primary controls should be larger where vehicle vibration or gloves require it.
- Disabled controls must expose a reason in Semantics or tooltip text.
- Physical millimeters, gloves, wet fingers, vibration, and target hardware remain unverified.

## Accessibility

Maintain readable contrast, visible focus, keyboard traversal, and clear semantics.

Before release, validate:

- screen readers;
- keyboard and physical buttons;
- rotary and steering-wheel input where applicable;
- text scale 1.3, 1.5, and 2.0;
- RTL and localization;
- reduced motion;
- color contrast and non-color status cues;
- focus visibility and restoration;
- dynamic content announcements.

The current Semantics improvements are a foundation, not an accessibility certification.

## Images and custom painting

Current imagery is primarily a static vehicle PNG and custom-painted maps. There is no live weather, map, album-art, or camera source.

Images should be high quality, appropriately decoded for the target DPR, and labeled as fixtures when they represent vehicle or environmental state.

## Glass, blur, and gradients

Glass effects are allowed when they support hierarchy and do not obscure critical information.

Multiple `BackdropFilter` layers exist in expanded Navigation. GPU and raster cost must be measured on the intended automotive hardware before production approval. Never blur an entire safety-relevant interface.

Gradients are visual styling, not a substitute for contrast or state communication.

## Component rules

Every reusable component belongs under `lib/widgets/`. Reuse should replace duplication when the abstraction has a clear responsibility; do not create a generic abstraction for one-off behavior without justification.

Interactive components should define:

- label;
- enabled/disabled state;
- selected/toggled state where relevant;
- unavailable reason;
- minimum hit target;
- keyboard/focus behavior;
- simulation or source status where relevant.

## Screen rules

Every screen should answer:

- Where am I?
- What is important?
- What can I do?
- What is unavailable?
- Which values are simulated or stale?

The final answer must not be hidden behind a decorative affordance.

## Design don'ts

Never:

- present a fixture as live vehicle data;
- use a control that silently does nothing;
- use status color as the only state signal;
- hardcode a safety-critical limit without an approved source;
- claim responsive coverage from one viewport;
- use blur or motion as a substitute for hierarchy;
- mix icon styles or create visual clutter;
- use a debug mode as a vehicle trust source.

## Design goals

The intended goals are calm, legible, efficient, and low-distraction. Actual driver workload, distraction risk, optical legibility, and physical ergonomics must be validated on the target platform before these are presented as achieved qualities.
