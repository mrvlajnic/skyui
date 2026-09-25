# SkyUI Draft Prototype Notice

**Product:** SkyUI HMI Prototype

**Package version:** `0.3.0-alpha+1`

**Document status:** Draft internal notice; not an official license, production agreement, vehicle approval, or legal certification.

## 1. Purpose and approval status

This document describes the technical and safety boundaries of the current SkyUI repository. It is provided for internal evaluation and requires review by the repository owner, legal counsel, safety engineering, security engineering, and vehicle-platform owners before external distribution.

Repository access, compilation, or use does not by itself establish a commercial license, vehicle authorization, or permission to deploy artifacts.

## 2. Current software status

SkyUI is an automotive-styled Flutter HMI prototype and local cockpit simulator. It is not:

- a vehicle controller;
- a production infotainment platform;
- a certified automotive HMI;
- a safety-critical function;
- a backend or telemetry service;
- a fully offline runtime.

All vehicle, phone, navigation, media, climate, connectivity, speed, route, trip, and diagnostic values are fixtures or local UI state unless explicitly marked otherwise.

## 3. Permitted prototype evaluation

Use is limited to internal development, desktop simulation, parked evaluation, UI review, and controlled non-road laboratory work that has separate owner approval.

The current artifact must not be used as:

- a live driving interface;
- a primary or secondary cluster display;
- a safety control;
- a driver-monitoring aid;
- a vehicle actuator gateway;
- a source of vehicle authorization or trust.

No monitoring arrangement, disclaimer, or independent observer makes live-road operation appropriate.

## 4. Vehicle hardware and CAN testing

No vehicle hardware connection is implemented or authorized by this notice. Any future HIL, CAN, OBD-II, LIN, Ethernet/AVB, or actuator testing requires a separately approved vehicle-specific plan covering electrical isolation, bus access, safety supervision, command authorization, rollback, incident response, and test authorization.

The UI must not be used as a direct raw-bus command path.

## 5. Safety and regulatory boundary

SkyUI has not been assessed or certified for ISO 26262, SOTIF, UNECE R155/R156, FMVSS, or another vehicle safety/cybersecurity regime. Formal compliance requires an approved scope, evidence, owners, and independent review.

The UI must never replace primary driving instrumentation, warnings, braking, steering, airbags, ABS, powertrain-fault, or other safety-critical indications.

## 6. Data, telemetry, and privacy

The current Dart implementation collects and transmits no telemetry, analytics, crash reports, remote logs, vehicle signals, contacts, location, or backend data. Local UI state is not transmitted.

No future telemetry or diagnostic collection is authorized by this notice. Before implementation, the owner must document:

- data inventory and purpose;
- source and permissions;
- consent or opt-in requirements;
- recipients and processors;
- retention and deletion;
- redaction and security controls;
- offline and degraded behavior;
- vehicle and personal-data classification.

Do not submit credentials, personal data, vehicle identifiers, location traces, or confidential information in feedback or source changes.

## 7. Release and signing status

Current development artifacts are not production-signed or approved for vehicle distribution.

Android release configuration currently uses:

- placeholder namespace and application ID `com.example.skyui`;
- debug signing configuration;
- no approved update path or production key-management process.

No APK, AAB, IPA, macOS bundle, Windows installer, Linux package, or web artifact should be represented as a production release until identity ownership, signing, provenance, legal classification, and update-path decisions are approved.

## 8. Local web launcher limitation

The local launcher is a development web-app simulator, not a native embedded runtime. It builds a CSP-compatible local CanvasKit bundle, but Flutter fallback fonts may still use `https://fonts.gstatic.com`. Fully offline operation is not claimed until local fonts are bundled and a network trace confirms no external fetch.

## 9. Warranty and liability boundary

The software is provided for prototype evaluation as-is and without a warranty of fitness, vehicle safety, uninterrupted operation, accuracy, compatibility, or regulatory compliance. No 60 FPS, navigation accuracy, sensor validity, or production reliability claim is made.

The repository owner must obtain legal review before publishing any warranty, liability, indemnity, license, or commercial-use terms. Nothing in this draft notice should be treated as a final legal instrument.

## 10. Intellectual property and repository controls

Repository ownership, third-party asset rights, and restrictions on reverse engineering, redistribution, or commercial use must be confirmed by the owner and legal counsel. This draft does not create or replace a license.

Do not remove copyright, security, provenance, or version notices from approved artifacts.

## 11. Versioning and changes

This notice applies to package version `0.3.0-alpha+1` and the current prototype working tree. It must be updated when the deployment class, data behavior, signing identity, legal approval, or safety boundary changes.

## 12. Contact

No verified legal entity address, privacy contact, security reporting address, or engineering escalation channel is currently documented. The repository owner must publish approved contact channels before external distribution.
