---
name: ios-security
description: Apply secure iOS practices for SSH credentials, Keychain, Secure Enclave, biometrics, host-key verification, APNs, and private infrastructure access.
---

# Security Rules

- Never store secrets in UserDefaults or SwiftData.
- Use Keychain for credentials and tokens.
- Prefer SSH key authentication.
- Verify SSH host keys.
- Never silently accept changed fingerprints.
- Use LocalAuthentication for protected actions.
- Do not log passwords, tokens, private keys, or sensitive command output.
- Never execute destructive actions directly from a notification payload.
