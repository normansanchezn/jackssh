---
title: Successful Connection Best Practices
tags:
  - jackssh
  - setup
  - ssh
  - connection-flow
  - best-practices
  - troubleshooting
---

# Successful Connection Best Practices

This guide defines the expected checklist for a reliable JackSSH connection. Use it before changing connection code, debugging Citadel, or assuming Supabase persistence is broken.

Related notes:

- [[../01-product/Real-Host-Connection-Flow|Real Host Connection Flow]]
- [[../01-product/Product-and-Architecture|Product and Architecture]]
- [[Supabase-Remote-Setup|Supabase Remote Setup]]
- [[Permissions-and-Privacy|Permissions and Privacy]]

## Success Definition

A connection is successful when JackSSH can:

1. Load the authenticated Supabase session.
2. Fetch the user's host metadata from `public.hosts`.
3. Resolve the configured hostname or private address.
4. Open TCP to the configured SSH port.
5. Verify the server identity.
6. Load the required credential from Keychain.
7. Authenticate over SSH.
8. Create an active in-app session.
9. Open the requested workspace: terminal, files, dashboard, or diagnostics.

If any step fails, the UI should surface the failed stage instead of falling back to a generic error.

## Host Configuration Checklist

Each host should have:

- A human-readable name.
- A reachable hostname, IP address, or private network address.
- A raw SSH port number with no locale formatting.
- A valid SSH username.
- An authentication method: password or public key.
- A Keychain credential saved on the current device.
- Optional OpenClaw fields only when the dashboard is intentionally configured.
- Optional favorite remote path when the file browser should open a specific directory.

Do not store passwords or private key material in Supabase. Supabase stores host metadata only; Keychain stores device-local secrets.

## Network Checklist

Before blaming the app, verify the route:

- The device is on the expected network.
- VPN or private network access is active when required.
- The host allows inbound SSH from the device route.
- The configured port is open.
- DNS resolves to the expected address.
- The server is not blocking repeated authentication attempts.

For private hosts, prefer a private address field or a clearly documented hostname. Avoid mixing public DNS, Tailscale names, and LAN IPs without noting which network path is expected.

## Credential Checklist

Credentials are per device.

This is intentional:

- iPhone Keychain data does not automatically become iPad Keychain data through Supabase.
- Supabase syncs host metadata, not SSH secrets.
- A host synced from Supabase may still require credential setup on a new device.

When a synced host fails on a second device:

1. Confirm the host appears in the list.
2. Edit or reconnect the host on that device.
3. Save the password or private key into the local Keychain.
4. Retry the connection.

## Expected UI State Flow

The connection flow should move through explicit states:

```text
idle
  -> resolving
  -> verifyingHostKey
  -> authenticating
  -> openingSession
  -> preparingWorkspace
  -> connected
```

Failure states should map to actionable causes:

- `missing credentials`: credential is not present on this device.
- `authentication failed`: username or secret is wrong.
- `host unreachable`: network, DNS, firewall, or port issue.
- `timeout`: remote host did not respond in time.
- `host key changed`: possible server rebuild or security risk.
- `invalid configuration`: required host fields are missing or malformed.

## Supabase Persistence Checklist

For cross-device host persistence:

- The user must be signed in.
- `public.hosts` must have RLS enabled.
- Policies must restrict rows by `auth.uid() = user_id`.
- The app must call Supabase with both `apikey` and `Authorization: Bearer <access_token>`.
- The current remote migrations must be applied.

Required migration for current host metadata:

```bash
SUPABASE_DB_PASSWORD='...' supabase db push --linked
```

Then verify:

```bash
supabase migration list --linked
```

The latest host metadata migration should appear on both local and remote.

## Debugging Order

Use this order to avoid chasing the wrong layer:

1. Confirm sign-in state.
2. Confirm host row exists in Supabase.
3. Confirm host row is visible only to the owning user.
4. Confirm host metadata is cached locally after load.
5. Confirm credentials exist in Keychain on the current device.
6. Confirm network reachability.
7. Confirm SSH authentication.
8. Confirm workspace-specific behavior.

## Common Failures

### Host Appears On iPhone But Not iPad

Cause: host metadata was local-only or remote migration is missing.

Fix:

- Ensure the app uses `SyncingHostRepository`.
- Apply pending Supabase migrations.
- Open the app on the original device once so local hosts migrate to Supabase.

### Host Appears On iPad But Cannot Connect

Cause: metadata synced, but credentials are not in the iPad Keychain.

Fix:

- Re-enter the password or private key on the iPad.
- Save the host.
- Retry connection.

### OpenClaw Does Not Open

Cause: OpenClaw may be bound to `127.0.0.1` on the remote host and not reachable directly from iOS.

Fix:

- Use SSH tunneling when OpenClaw is remote-local only.
- Do not assume iOS can open the remote server's localhost.

### Port Displays As `22,022`

Cause: numeric UI formatting applied locale grouping to the SSH port.

Fix:

- Render ports as raw integer strings.
- Avoid localized number formatting for connection ports.

## Release Discipline

Any change that affects connection behavior must update:

- [[../01-product/Real-Host-Connection-Flow|Real Host Connection Flow]]
- this guide
- root `CHANGELOG.md`

Connection changes should include at least one of:

- package tests
- app build verification
- manual device verification notes
