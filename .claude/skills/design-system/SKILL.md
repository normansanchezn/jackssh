---
name: design-system
description: Apply JackSsh's Atomic Design system using tokens, atoms, molecules, organisms, templates, accessibility, and reusable SwiftUI components.
---

# Atomic Design

Structure:

- Tokens
- Atoms
- Molecules
- Organisms
- Templates

Rules:

- Atoms must not know domain concepts.
- Feature-specific components remain in Presentation.
- Move components to DesignSystem only when genuinely reusable.
- Support dark mode and Dynamic Type.
- Include previews.
- Do not hardcode colors, spacing, radius, or typography in feature views.
