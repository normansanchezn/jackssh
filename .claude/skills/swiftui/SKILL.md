---
name: swiftui
description: Build native JackSsh interfaces using modern SwiftUI, Observation, NavigationStack, accessibility, previews, and feature-first organization.
---

# SwiftUI Rules

- Use SwiftUI.
- Prefer `@Observable` over `ObservableObject` for new code.
- Use `NavigationStack` with typed routes.
- Keep views declarative.
- Keep business logic in ViewModels and Domain use cases.
- Support Dynamic Type, VoiceOver, dark mode, and Reduce Motion.
- Include previews for reusable components.
- Avoid force unwraps.
- Avoid networking or SSH calls from Views.
