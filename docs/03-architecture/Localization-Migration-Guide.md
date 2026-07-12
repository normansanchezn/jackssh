---
title: Localization Migration Guide
tags:
  - jackssh
  - architecture
  - localization
  - migration
---

# Localization Migration Guide

This note records the cleanup from feature-local `.strings` files to the current module-owned string catalog.

## Final State

- Source of truth: `jackssh-presentation/Sources/Presentation/Localizable.xcstrings`
- Runtime bundle: `Bundle.module`
- Access point: `LocalizationManager`
- SwiftPM resource declaration: `jackssh-presentation/Package.swift`

## Migration Steps

1. Move any feature-local localizations into `Localizable.xcstrings`.
2. Delete duplicated `Localizable.strings` or `Localizable-*.strings` files from feature folders.
3. Ensure the `Presentation` target processes `Localizable.xcstrings`.
4. Ensure `LocalizationManager()` defaults to `Bundle.module`.
5. Run `swift test` from `jackssh-presentation`.

## Adding a New Screen

1. Add keys to `Localizable.xcstrings`, scoped by screen:

```text
login.title
login.email.placeholder
login.password.placeholder
```

2. Add a namespace in `LocalizationManager`:

```swift
extension LocalizationManager {
    public enum Login {
        public static let title = "login.title"
    }
}
```

3. Resolve strings in the UI state or view model, not scattered across the view.

## Related Notes

- [[03-architecture/Localization-Architecture]]
- [[04-modules/presentation/auth/welcome/Welcome-Localization-Readme]]
