# CLAUDE.md

# SkyUI

## Project Overview

SkyUI is a custom automotive infotainment system developed for the Veltron ecosystem.

The objective is to create a production-ready, modular, modern, responsive and scalable infotainment interface.

This project is NOT a mobile application.
It is an automotive operating system interface.

---

# Vision

The long-term goal is to build a complete automotive operating system including:

- Home
- Navigation
- Media
- Phone
- Vehicle
- Climate
- Settings
- OTA Updates
- Diagnostics
- AI Assistant
- User Profiles

The project should remain highly modular.

---

# Tech Stack

Framework:
- Flutter

Language:
- Dart

Architecture:
- Modular UI

---

# Current Project Structure

lib/

core/
- animations/
- constants/
- icons/
- theme/
- utils/

models/

screens/
- home/

services/

widgets/
- header/
- sidebar/

main.dart

---

# Current Features

Implemented:

- Header
- Sidebar
- Home Screen
- Responsive Layout
- Theme System
- Status Icons
- Navigation Layout

---

# Design Language

SkyUI follows these principles:

- Minimal
- Premium
- Automotive
- Dark UI
- Clean
- Responsive
- Modern
- Performance First

Avoid clutter.

Avoid unnecessary colors.

Every screen should feel like it belongs inside a premium vehicle.

---

# UI Rules

Always:

- Reuse widgets.
- Keep widgets small.
- Split large files.
- Prefer composition over duplication.
- Maintain spacing consistency.

Never:

- Put business logic inside widgets.
- Create giant files.
- Duplicate code.

---

# Folder Responsibilities

core/
Global utilities.

models/
Data models.

services/
Business logic and external integrations.

screens/
Entire application pages.

widgets/
Reusable UI components.

---

# Coding Style

Use readable code.

Prefer descriptive variable names.

Keep functions short.

Extract reusable widgets whenever possible.

Avoid unnecessary comments.

Write self-documenting code.

---

# Architecture Rules

Before modifying existing code:

1. Understand the current implementation.
2. Reuse existing widgets.
3. Preserve architecture.
4. Keep consistency.

Never rewrite working code without reason.

---

# Before Every Task

Always:

1. Read relevant files.
2. Explain the plan.
3. Implement.
4. Verify.
5. Suggest improvements.

---

# Refactoring Policy

If a better architecture exists:

DO NOT immediately rewrite the project.

Instead:

- explain the issue
- explain advantages
- explain disadvantages
- wait for approval

---

# Error Handling

When fixing bugs:

Do not only patch the issue.

Find the root cause.

Explain why it happened.

Prevent it from happening again.

---

# Performance

Prefer efficient widgets.

Minimize rebuilds.

Avoid unnecessary state updates.

Think about scalability.

---

# Communication

When unsure:

Ask.

Never invent project requirements.

Never remove functionality unless explicitly requested.

---

# Development Workflow

Priority:

1. Correctness
2. Architecture
3. Readability
4. Performance
5. Optimization

---

# Future Documentation

Detailed documentation will be located inside:

docs/

Examples:

docs/architecture.md

docs/design_system.md

docs/modules.md

docs/roadmap.md

docs/changelog.md

CLAUDE.md should remain concise and should only contain project-wide rules.