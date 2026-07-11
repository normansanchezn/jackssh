---
name: swift-testing
description: Create and validate JackSsh unit and integration tests using Swift Testing, with XCTest reserved for UI automation or unsupported APIs.
---

# Testing Rules

Use:

- `import Testing`
- `@Suite`
- `@Test`
- `#expect`
- async tests
- deterministic fakes
- in-memory repositories

Test:

- Domain use cases
- ViewModel states
- error mapping
- deep-link parsing
- host validation
- repository behavior

Run actual tests before claiming success.
