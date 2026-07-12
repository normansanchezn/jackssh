---
title: CLAUDE
tags:
  - jackssh
  - agent-instructions
  - architecture-guardrails
---

# JackSSH Project Instructions

JackSSH is a native iOS app organized as Swift Package modules plus a thin app target.

## Stack

- Swift
- SwiftUI
- MVVM
- Swift Package Manager
- Swift Testing
- SwiftData
- Keychain
- LocalAuthentication
- Supabase
- Citadel / SSH transport

## Modules

- `JackSsh`: app lifecycle, composition root, environment wiring.
- `jackssh-presentation`: SwiftUI views, view models, navigation, UI state, presentation resources.
- `jackssh-domain`: entities, repositories, validation, use cases, domain errors.
- `jackssh-data`: concrete repositories, Supabase, SwiftData, Keychain, SSH implementations.
- `jackssh-design-system`: tokens, themes, atoms, molecules, reusable UI.
- `jackssh-shared`: logging, configuration, redaction, clocks, shared utilities.

## Mandatory Architecture

1. The app target stays thin. Do not add business logic there.
2. `Presentation` depends on `Domain`, `DesignSystem`, `Shared`, and UI-only packages. It must not depend on `Data`.
3. `Domain` must not import SwiftUI, Supabase, SwiftData, Keychain, or concrete networking libraries.
4. `Data` implements domain protocols and owns infrastructure details.
5. `DesignSystem` must not depend on app features.
6. `Localizable.xcstrings` lives at `jackssh-presentation/Sources/Presentation/Localizable.xcstrings`.
7. `LocalizationManager` defaults to `Bundle.module`; do not create per-feature `Localizable.strings` files.
8. Documentation belongs in `docs` as Obsidian notes, not inside `Sources`.

## Mandatory Workflow

1. Inspect the repository before modifying files.
2. Preserve existing changes.
3. Work by feature and respect module boundaries.
4. Run relevant tests and builds.
5. Never claim success without command output.
6. Do not invent APIs, services, migrations, or infrastructure.
7. Update docs when architecture changes.

## Current Architecture Notes

- Localization: [[03-architecture/Localization-Architecture]]
- Dependency injection: [[03-architecture/Dependency-Injection]]
- Product architecture: [[01-product/Product-and-Architecture]]
- Host connection flow: [[01-product/Real-Host-Connection-Flow]]
