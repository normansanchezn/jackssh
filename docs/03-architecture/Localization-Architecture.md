---
title: Localization Architecture
tags:
  - jackssh
  - architecture
  - localization
  - presentation
---

# Localization Architecture

JackSSH localizes presentation strings from one catalog owned by the `Presentation` module:

```text
jackssh-presentation/
└── Sources/
    └── Presentation/
        └── Localizable.xcstrings
```

The package declares that catalog as a processed resource, so SwiftPM exposes it through `Bundle.module`.

## Runtime Flow

```text
WelcomeUIState
  ↓
LocalizationManager.shared
  ↓
Bundle.module
  ↓
Localizable.xcstrings
```

`LocalizationManager` is the typed access point for string keys. Feature UI state objects ask it for strings and expose resolved `String` values to SwiftUI views.

## Rules

1. Do not add `Localizable.strings` files inside feature folders.
2. Do not put localization resources in the app target unless the string belongs only to app lifecycle code.
3. Add new presentation strings to `jackssh-presentation/Sources/Presentation/Localizable.xcstrings`.
4. Add new key namespaces to `LocalizationManager` when a screen needs stable typed keys.
5. Keep views free of hardcoded user-facing strings when those strings need localization.

## Current Welcome Keys

- `welcome.title`
- `welcome.subtitle`
- `welcome.signIn`
- `welcome.signUp`

## Related Notes

- [[04-modules/presentation/auth/welcome/Welcome-Architecture]]
- [[04-modules/presentation/auth/welcome/Welcome-Localization-Readme]]
- [[00-meta/CLAUDE]]
