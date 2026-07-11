---
name: ios-architecture
description: Apply the JackSsh iOS architecture using SwiftUI, MVVM, local Swift packages, feature-first folders, dependency inversion, and strict module boundaries.
---

# JackSsh iOS Architecture

Use this skill whenever creating, moving, reviewing, or refactoring architectural code in JackSsh.

## Required modules

- JackSsh app target
- Presentation package
- Domain package
- Data package
- DesignSystem package
- Shared package

## Dependency rules

- JackSsh composes dependencies.
- Presentation depends on Domain and DesignSystem.
- Data implements Domain repository protocols.
- Domain does not import SwiftUI, UIKit, networking, persistence, or SSH libraries.
- DesignSystem contains reusable visual components only.
- Shared must not become a dumping ground.

## Architecture

Use MVVM:

View → ViewModel → Use Case → Repository protocol → Repository implementation

Use:

- SwiftUI
- `@Observable`
- async/await
- constructor injection
- typed navigation
- feature-first folders
- Swift Testing

Do not put business logic in SwiftUI views.
Do not access Keychain, SSH, SFTP, or networking directly from Presentation.
