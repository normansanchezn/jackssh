---
title: AGENTS
tags:
  - jackssh
  - agent-instructions
  - codegraph
  - architecture-guardrails
---

# Agent Instructions

These instructions apply to agentic work in JackSSH. Keep the implementation aligned with [[00-meta/CLAUDE]] and the architecture notes in [[03-architecture/Dependency-Injection]] and [[03-architecture/Localization-Architecture]].

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->

## Architecture Guardrails

1. Keep the app target thin. `JackSsh/JackSsh` owns composition and app lifecycle only.
2. Keep business rules in `jackssh-domain`.
3. Keep concrete infrastructure in `jackssh-data`.
4. Keep SwiftUI screens and view models in `jackssh-presentation`.
5. Keep reusable styling and UI primitives in `jackssh-design-system`.
6. Keep cross-cutting utilities in `jackssh-shared`.
7. Do not introduce duplicate localization files in feature folders. `Presentation` owns `Sources/Presentation/Localizable.xcstrings`.
8. Do not move Supabase, SSH, Keychain, SwiftData, or transport logic into `Presentation`.
9. Do not make generated docs inside `Sources`; put documentation in this vault.
10. Keep Presentation screens organized like Welcome: screen folder, optional `Model/` folder, `ScreenView.swift`, and `ScreenViewModel.swift` when the screen owns behavior.
11. Never place Swift Testing files under `Sources`; package tests belong under `Tests`.

## Required Workflow

1. Inspect current code before editing.
2. Preserve user changes and unrelated dirty files.
3. Make changes by feature and module boundary.
4. Run relevant real tests/builds before claiming completion.
5. Report command results accurately.
6. Prefer existing patterns over new abstractions.
