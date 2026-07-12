---
title: Welcome Localization Readme
tags:
  - jackssh
  - module/presentation
  - auth
  - welcome
  - localization
---

# Welcome Localization

Welcome strings are resolved through the shared `Presentation` localization catalog:

```text
jackssh-presentation/Sources/Presentation/Localizable.xcstrings
```

`WelcomeUIState` receives a `LocalizationManager`, resolves the strings once during initialization, and exposes them as plain `String` properties to `WelcomeView`.

## Current Flow

```text
Localizable.xcstrings
  ↓ Bundle.module
LocalizationManager
  ↓ typed keys
WelcomeUIState
  ↓ resolved String values
WelcomeView
```

## Welcome Keys

- `welcome.title`
- `welcome.subtitle`
- `welcome.signIn`
- `welcome.signUp`

## Adding a Welcome String

1. Add the key to `Localizable.xcstrings`.
2. Add the key to `LocalizationManager.Welcome`.
3. Resolve it in `WelcomeUIState`.
4. Use the resolved value in `WelcomeView`.

Do not create `Localizable.strings` files under `Auth/Welcome/Model`.

## Related Notes

- [[03-architecture/Localization-Architecture]]
- [[04-modules/presentation/auth/welcome/Welcome-Architecture]]
