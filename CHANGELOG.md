# Changelog

All notable changes to JackSSH should be documented in this file.

The project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html): `MAJOR.MINOR.PATCH`.

## [Unreleased]

### Added

- Remote Supabase-backed host persistence through `SupabaseHostRepository`.
- Local-to-remote host migration bridge through `SyncingHostRepository`.
- Splash screen architecture with `SplashViewModel`, `SplashUIState`, and `SplashEffect`.
- Root `README.md` for GitHub onboarding and project positioning.
- Successful connection best-practices guide under the Obsidian docs vault.

### Changed

- `CompositionRoot` now wires hosts through a syncing repository instead of local-only SwiftData persistence.
- Supabase auth repository now exposes a session context for remote data repositories.
- The app startup path now shows the animated splash while bootstrapping authentication.

### Fixed

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
