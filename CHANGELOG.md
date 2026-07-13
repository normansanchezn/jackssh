# Changelog

All notable changes to JackSSH should be documented in this file.

The project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html): `MAJOR.MINOR.PATCH`.

## [Unreleased]

### Added

- Adaptive iPadOS authentication layout shared by Welcome, Login, and Sign Up screens.
- Biometric sign-in opt-in after password login, backed by Face ID/Touch ID protected Keychain credentials.
- Login screen biometric sign-in action for devices with an enrolled biometric credential.
- iPadOS adaptive app shell using `NavigationSplitView` with a persistent sidebar and detail navigation.
- Regular-width host grid layout so iPad does not render the iPhone list as an oversized column.
- Remote Supabase-backed host persistence through `SupabaseHostRepository`.
- Local-to-remote host migration bridge through `SyncingHostRepository`.
- Splash screen architecture with `SplashViewModel`, `SplashUIState`, and `SplashEffect`.
- OpenClaw dashboard access through app-scoped SSH local port forwarding.
- OpenClaw auto-authentication bootstrap by resolving a dashboard token over SSH and injecting it into the tunneled WebView session.
- Root `README.md` for GitHub onboarding and project positioning.
- Successful connection best-practices guide under the Obsidian docs vault.

### Changed

- Host editor now shows password fields by default for password-based hosts and requires a password when creating a new password host.
- Welcome, Login, and Sign Up now use constrained form panels and a regular-width product sidebar instead of stretched iPhone layouts on iPad.
- Host persistence is now local-first: SwiftData serves existing device data even when Supabase fails, then syncs remote opportunistically.
- Auth composition now includes biometric login use cases while keeping LocalAuthentication inside the Data layer.
- Home dashboard now adapts to regular-width layouts with constrained task panels.
- `CompositionRoot` now wires hosts through a syncing repository instead of local-only SwiftData persistence.
- Supabase auth repository now exposes a session context for remote data repositories.
- The app startup path now shows the animated splash while bootstrapping authentication.

### Fixed

- SSH connection could fail with "Password not found in Keychain" because password-based hosts could be saved without exposing/capturing a password.
- Keychain host credential keys are now centralized so save/connect/terminal/files/delete use the same password/private-key identifiers.
- Hosts screen could show "Couldn’t load hosts" when remote Supabase sync failed, even though local hosts still existed.
- Hosts created on one device were not available on another device using the same Supabase account.
- Splash screen existed but was not shown during app bootstrap.

### Database

- Added migration `20260715_add_missing_host_metadata.sql` to align `public.hosts` with `Domain.Host` metadata.

### Verification

- `swift test` passed in `jackssh-data`.
- `swift test` passed in `jackssh-presentation`.
- `xcodebuild -project JackSsh/JackSsh.xcodeproj -scheme JackSsh -destination 'generic/platform=iOS' build` passed.

## [0.1.0] - 2026-07-12

### Added

- Initial modular iOS application structure.
- Domain, Data, Presentation, DesignSystem, and Shared packages.
- Supabase authentication flow.
- SwiftData local host persistence.
- Keychain-backed secret storage.
- Host list and host editor flows.
- SSH connection, terminal, and remote file foundations.
- Obsidian documentation vault under `docs/`.

### Notes

- This version represents the private development baseline before formal GitHub release tagging.
