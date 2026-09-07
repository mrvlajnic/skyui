# SkyUI Architecture

Version: 0.3 Alpha

---

# Purpose

This document describes the architecture of the SkyUI project.

It explains:

- project structure
- responsibilities
- module separation
- design philosophy
- coding rules
- scalability strategy

This document is intended for both developers and AI assistants.

---

# What is SkyUI?

SkyUI is a modern automotive infotainment operating system built for the Veltron ecosystem.

SkyUI is not designed as a traditional mobile application.

Instead, it is built as a complete vehicle operating system capable of running multiple independent automotive applications inside a unified interface.

---

# Architectural Philosophy

The architecture follows five principles.

## 1. Modular

Every major feature must exist as an independent module.

Examples:

- Navigation
- Vehicle
- Media
- Phone
- Climate
- Settings

Modules should not depend directly on each other.

---

## 2. Scalable

The architecture should support years of future development.

Adding a new module must require minimal changes to existing code.

---

## 3. Reusable

Widgets should be reusable.

Never duplicate UI.

If the same component appears more than once,
extract it into a reusable widget.

---

## 4. Maintainable

Small files.

Small widgets.

Clear folder structure.

Readable code.

---

## 5. Performance First

Smooth animations.

Minimal rebuilds.

Fast startup.

Low memory usage.

---

# High Level Architecture

```
SkyUI

↓

Application

↓

Screens

↓

Widgets

↓

Services

↓

Models

↓

Assets
```

---

# Folder Responsibilities

## core/

Contains global project resources.

Includes:

- animations
- constants
- icons
- theme
- utilities

Nothing inside core should depend on application screens.

---

## models/

Contains application data models.

Examples:

Vehicle

Media

Navigation

Phone

User

Settings

Models should never contain UI.

---

## services/

Contains business logic.

Examples:

Bluetooth

Navigation

Vehicle communication

AI

Media

OTA

Services should never render UI.

---

## screens/

Contains full application pages.

Examples:

Home

Vehicle

Media

Phone

Settings

Navigation

Each screen represents one page.

---

## widgets/

Contains reusable interface components.

Widgets must remain independent.

Examples:

Header

Sidebar

Buttons

Cards

Dialogs

Animations

---

# Screen Composition

Screens should not contain large widget trees.

Instead they compose reusable widgets.

Example:

HomeScreen

↓

VehicleCard

↓

MediaCard

↓

NavigationCard

↓

PhoneCard

↓

QuickActions

↓

ClimateBar

Each widget should have one responsibility.

---

# Layer Responsibilities

UI Layer

Responsible for:

Rendering

Animations

Interaction

Navigation

Business Layer

Responsible for:

Application logic

Communication

State

Data Layer

Responsible for:

Models

Storage

External APIs

---

# Dependency Direction

Allowed

```
Screen

↓

Widget

↓

Service

↓

Model
```

Forbidden

Model → Widget

Widget → Screen

Service → UI

---

# Assets

Images

Icons

Fonts

Logos

Backgrounds

Vehicle renders

must remain inside assets/.

Never hardcode image paths.

---

# UI Philosophy

SkyUI should feel like a premium automotive operating system.

Characteristics:

Minimal

Elegant

Premium

Fast

Driver focused

Modern

Every screen should feel calm.

Avoid visual clutter.

---

# Design Rules

Use spacing consistently.

Reuse colors from theme.

Never hardcode colors.

Never hardcode typography.

Always use design constants.

---

# Widget Rules

One widget.

One responsibility.

Avoid widgets larger than approximately 300 lines.

Extract reusable sections.

Avoid deeply nested widget trees.

---

# Business Logic

Business logic never belongs inside widgets.

Widgets display data.

Services process data.

Models store data.

---

# Naming Convention

Folders

snake_case

Files

snake_case

Classes

PascalCase

Variables

camelCase

Constants

UPPER_CASE when global

---

# Performance Goals

Target:

60 FPS

Avoid unnecessary rebuilds.

Prefer const constructors.

Reuse widgets.

Cache expensive operations.

Optimize image sizes.

---

# Future Modules

Vehicle

Navigation

Media

Phone

Bluetooth

Climate

Charging

Garage

AI Assistant

Diagnostics

Developer Mode

OTA Updates

Camera

Dashboard

Profiles

Cloud Sync

---

# AI Development Rules

Before modifying code:

Understand existing implementation.

Reuse current architecture.

Avoid rewriting working code.

Explain architectural changes before implementing.

Never invent project requirements.

Ask when requirements are unclear.

---

# Long Term Vision

SkyUI should eventually evolve into a complete automotive operating system.

The architecture must support future hardware integration including:

CAN Bus

OBD

Bluetooth

WiFi

LTE

GPS

Vehicle Sensors

Voice Assistant

AI

Cloud Services

without requiring major architectural redesign.

---

# Architecture Stability

The architecture is considered a long-term contract.

Implementation details may change.

Architecture should remain stable.

Breaking architectural rules requires explicit approval.

End of document.