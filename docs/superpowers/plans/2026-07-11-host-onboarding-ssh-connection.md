# Host Onboarding & SSH Connection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable users to configure SSH hosts once, securely store credentials, and reconnect with one tap plus optional biometric authentication.

**Architecture:** Extend Domain layer with authentication and connection models → Update Presentation to handle new form fields and connection status → Implement Data layer credential storage and SSH connection logic → Add connection attempt on form save for validation. Layered design keeps SSH logic, validation, and persistence separate.

**Tech Stack:** SwiftUI, SwiftData (host config), Keychain (credentials), Citadel (SSH), LocalAuthentication (biometric), Swift Testing.

## Global Constraints

- Host entity must stay non-sensitive (secrets keyed by host ID in Keychain)
- All form validation happens in Domain layer (HostValidator)
- Credentials stored encrypted in Keychain immediately after form save
- SSH connections validated on form save to catch auth failures early
- Connection status separate from host data (ephemeral state)

---

## Task 1: Extend Host Entity with Authentication & Config Fields

**Files:**
- Modify: `jackssh-domain/Sources/Domain/Entities/Host.swift`
- Create: `jackssh-domain/Sources/Domain/Entities/SSHCredential.swift`
- Create: `jackssh-domain/Sources/Domain/Entities/OpenClawConfiguration.swift`

**Interfaces:**
- Produces: `enum SSHAuthMethod { case password, publicKey }`, `struct OpenClawConfiguration`, extended `struct Host` with new fields

Complete code provided in plan deliverables (see initial plan response).

---

## Task 2: Create ConnectionStatus Entity & Repository Protocol

**Files:**
- Create: `jackssh-domain/Sources/Domain/Entities/ConnectionStatus.swift`
- Modify: `jackssh-domain/Sources/Domain/Repositories/Repositories.swift`

**Interfaces:**
- Produces: `enum ConnectionState`, `struct ConnectionStatus`, `protocol ConnectionStatusRepository`

---

## Task 3: Extend HostValidation to Include Auth Fields

**Files:**
- Modify: `jackssh-domain/Sources/Domain/Validation/HostValidation.swift`

**Interfaces:**
- Consumes: `SSHAuthenticationMethod`, `OpenClawConfiguration`
- Produces: Extended `HostDraft`, extended `ValidationIssue.Field`, extended `HostValidator`

---

## Task 4: Create SSH Connection Use Case

**Files:**
- Create: `jackssh-domain/Sources/Domain/UseCases/AttemptConnection.swift`
- Create: `jackssh-domain/Sources/Domain/UseCases/ValidateSSHConnection.swift`

**Interfaces:**
- Consumes: `Host`, `ConnectionStatus`, `ConnectionStatusRepository`
- Produces: `AttemptConnection` use case, `ValidateSSHConnection` use case

---

## Task 5: Create CredentialStore in Data Layer

**Files:**
- Create: `jackssh-data/Sources/Data/Security/CredentialStore.swift`
- Modify: `jackssh-domain/Sources/Domain/Repositories/Repositories.swift`

**Interfaces:**
- Consumes: `SSHCredential`, `SSHAuthenticationMethod`
- Produces: `CredentialStore` protocol, `KeychainCredentialStore` implementation

---

## Task 6: Create CitadelSSHConnection Implementation

**Files:**
- Create: `jackssh-data/Sources/Data/SSH/CitadelSSHConnection.swift`

**Interfaces:**
- Consumes: `Host`, `SSHConnectionResult`, `SSHConnector`, `CredentialStore`
- Produces: `CitadelSSHConnector` implementation

---

## Task 7: Update SwiftDataHostRepository to Handle New Fields

**Files:**
- Modify: `jackssh-data/Sources/Data/Persistence/Records.swift`
- Modify: `jackssh-data/Sources/Data/Persistence/SwiftDataHostRepository.swift`

**Interfaces:**
- Consumes: `Host`, `SSHAuthenticationMethod`, `OpenClawConfiguration`
- Produces: Extended `HostRecord` with new fields, updated repository save/load logic

---

## Task 8: Create InMemory ConnectionStatusRepository for Development

**Files:**
- Create: `jackssh-data/Sources/Data/Home/InMemoryConnectionStatusRepository.swift`

**Interfaces:**
- Produces: `InMemoryConnectionStatusRepository` implementation

---

## Task 9: Extend HostEditorViewModel to Handle Auth Fields

**Files:**
- Modify: `jackssh-presentation/Sources/Presentation/Hosts/HostEditorViewModel.swift`

**Interfaces:**
- Consumes: `HostDraft`, `SSHAuthenticationMethod`, `ValidateSSHConnection`, `CredentialStore`
- Produces: Extended `HostEditorViewModel` with auth method state, credential input

---

## Task 10: Extend HostEditorView to Show Auth Fields

**Files:**
- Modify: `jackssh-presentation/Sources/Presentation/Hosts/HostEditorView.swift`

**Interfaces:**
- Consumes: `HostEditorViewModel` with new auth properties
- Produces: Extended form with auth method picker, password field, OpenClaw fields

---

## Task 11: Create ConnectionStatusView for Real-Time State Display

**Files:**
- Create: `jackssh-presentation/Sources/Presentation/Connection/ConnectionStatusView.swift`

**Interfaces:**
- Consumes: `ConnectionStatus`, `ConnectionState`
- Produces: `ConnectionStatusView` component

---

## Task 12: Update HostsListView to Show Last Connection & Favorites

**Files:**
- Modify: `jackssh-presentation/Sources/Presentation/Hosts/HostsListView.swift`

**Interfaces:**
- Consumes: Extended `Host` model with `lastSuccessfulConnection` and `isFavorite`
- Produces: Updated list view with star icon and connection info

---

## Task 13: Write Tests for HostEditorViewModelValidation

**Files:**
- Create: `jackssh-presentation/Tests/PresentationTests/HostEditorViewModelAuthTests.swift`

**Interfaces:**
- Consumes: `HostEditorViewModel`, `SSHAuthenticationMethod`
- Produces: Test suite for auth method handling

---

## Task 14: Write Integration Test for Credential Storage

**Files:**
- Create: `jackssh-data/Tests/DataTests/CredentialStoreTests.swift`

**Interfaces:**
- Consumes: `KeychainCredentialStore`
- Produces: Integration tests for Keychain operations

---

## Task 15: Build & Run Full Test Suite

**Files:**
- None (build & test only)

**Interfaces:**
- Consumes: All previous tasks' code
- Produces: Green test suite, successful build
