# JackSSH

**A private iOS ops console for secure SSH workflows, host management, remote files, dashboards, and personal infrastructure control.**

JackSSH is built for one clear job: open the app, choose a trusted host, connect, and operate without jumping between terminal apps, VPN dashboards, notes, browsers, and manual commands.

## Why JackSSH Exists

Managing private infrastructure from iPhone or iPad usually means stitching together several tools:

- one app for identity and login
- one app for SSH
- one place for host notes
- another place for dashboard URLs
- another workflow for files and logs

JackSSH turns that into a native, structured flow:

```text
Sign in
  -> Sync hosts from Supabase
  -> Select host
  -> Connect through SSH
  -> Open terminal, files, dashboard, and diagnostics
```

## Current Capabilities

- Supabase Auth for account sessions.
- Remote host metadata persistence in Supabase.
- Local SwiftData cache for fast access and migration of existing device-only hosts.
- Secure local Keychain storage for SSH secrets.
- Host editor with SSH and OpenClaw configuration.
- Connection flow with dedicated connecting and connected states.
- Terminal and remote file workflows backed by Citadel SSH/SFTP.
- Presentation module architecture using `View`, `ViewModel`, `UIState`, and `Effect`.
- Centralized localization through the `Presentation` package.
- Obsidian documentation vault under `docs/`.

## Architecture

JackSSH is split into focused Swift packages:

```text
JackSsh              iOS app target and composition root
jackssh-domain      entities, protocols, use cases, validation
jackssh-data        Supabase, SwiftData, Keychain, SSH/SFTP implementations
jackssh-presentation SwiftUI views, ViewModels, UIState, Effects
jackssh-design-system reusable UI primitives and theme
jackssh-shared      shared configuration and logging
supabase            database migrations and local Supabase config
docs                Obsidian vault and project documentation
```

Concrete dependencies are wired only in `JackSsh/JackSsh/CompositionRoot.swift`. Domain stays independent from Supabase, SwiftData, Keychain, and SwiftUI.

## Data Model

Host metadata is shared across devices through Supabase:

- host name
- hostname
- port
- username
- auth method metadata
- OpenClaw configuration
- favorite remote path
- tags and favorite state

Sensitive SSH material is not uploaded to Supabase. Passwords and private keys remain in the local Keychain on each device.

## Getting Started

Requirements:

- Xcode 15 or newer
- iOS 17 target
- Swift 6
- Supabase CLI for database work
- access to the linked Supabase project for remote migrations

Build the app:

```bash
xcodebuild -project JackSsh/JackSsh.xcodeproj \
  -scheme JackSsh \
  -destination 'generic/platform=iOS' \
  build
```

Run package tests:

```bash
swift test --package-path jackssh-domain
swift test --package-path jackssh-data
swift test --package-path jackssh-presentation
```

Apply pending Supabase migrations:

```bash
SUPABASE_DB_PASSWORD='...' supabase db push --linked
```

## Successful Connection Checklist

Before debugging the app, verify the host itself:

- The iPhone or iPad can reach the private network or public host address.
- SSH is listening on the configured port.
- The configured username is valid.
- The password or private key exists in the device Keychain.
- The host key is expected and has not changed unexpectedly.
- OpenClaw fields are configured only when the dashboard is reachable through the intended path.

Full guide: [`docs/02-setup/Successful-Connection-Best-Practices.md`](docs/02-setup/Successful-Connection-Best-Practices.md)

## Documentation

The documentation lives in the Obsidian vault:

- [`docs/README.md`](docs/README.md) - vault index
- [`docs/01-product/Product-and-Architecture.md`](docs/01-product/Product-and-Architecture.md) - product and architecture
- [`docs/01-product/Real-Host-Connection-Flow.md`](docs/01-product/Real-Host-Connection-Flow.md) - connection flow
- [`docs/02-setup/Supabase-Remote-Setup.md`](docs/02-setup/Supabase-Remote-Setup.md) - remote Supabase setup
- [`docs/02-setup/Successful-Connection-Best-Practices.md`](docs/02-setup/Successful-Connection-Best-Practices.md) - SSH success guide
- [`CHANGELOG.md`](CHANGELOG.md) - release history

## Versioning

Use semantic versioning:

```text
MAJOR.MINOR.PATCH
```

- `MAJOR`: architecture or data model changes that require migration planning.
- `MINOR`: new user-facing workflows or modules.
- `PATCH`: fixes, polish, test coverage, and documentation.

Keep every release note in [`CHANGELOG.md`](CHANGELOG.md).

## Security Posture

JackSSH treats secrets as device-local by default.

- Supabase stores account identity and non-sensitive host metadata.
- Keychain stores SSH passwords and private keys.
- Domain protocols hide storage and transport details from the UI.
- RLS policies protect per-user rows in Supabase.

## Project Status

JackSSH is under active private development. The current focus is making the host connection path reliable across iPhone and iPad while preserving a clean modular architecture.
