---
title: Welcome Localization Index
tags:
  - jackssh
  - module/presentation
  - auth
  - welcome
  - localization
  - index
---

# Welcome Localization Index

Start here:

- [[03-architecture/Localization-Architecture]]: current global localization architecture.
- [[04-modules/presentation/auth/welcome/Welcome-Localization-Readme]]: Welcome-specific localization flow.
- [[04-modules/presentation/auth/welcome/Welcome-Architecture]]: Welcome MVVM structure.
- [[04-modules/presentation/auth/welcome/Welcome-Localization-Implementation-Summary]]: historical summary of the implementation.

## Source Files

- `jackssh-presentation/Sources/Presentation/Auth/Welcome/Model/LocalizationManager.swift`
- `jackssh-presentation/Sources/Presentation/Auth/Welcome/Model/WelcomeUIState.swift`
- `jackssh-presentation/Sources/Presentation/Auth/Welcome/WelcomeView.swift`
- `jackssh-presentation/Sources/Presentation/Localizable.xcstrings`

## Rules

1. Keep translation keys in `Localizable.xcstrings`.
2. Keep key constants in `LocalizationManager`.
3. Keep resolved display strings in UI state.
4. Keep SwiftUI views focused on rendering and user actions.
