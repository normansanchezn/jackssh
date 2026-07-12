# JackSsh — Implement Real Host Connection Flow

Continue from the current JackSsh implementation.

Do not recreate the Xcode project, workspace, packages, Git repository, architecture, status screen, host form, or host persistence.

The app can already create and save hosts, but the main connection flow is incomplete.

## Current problem

- Saved hosts appear in the Hosts screen.
- Tapping a host does not establish a connection.
- There is no connecting screen.
- There is no connected-host workspace.
- OpenClaw configuration is not sufficient or is not used.
- The saved host does not expose Terminal, Files, Dashboard, or Git Status actions.
- The favorite remote path is saved but is not used to inspect repository changes.
- The SSH port is being rendered with numeric formatting. For example, port `22022` appears as `22,022`. Ports must be displayed as raw integers without locale grouping.

The primary vertical slice to implement is:

```text
Saved Host
→ Tap Host
→ Connect
→ Show connection progress
→ Connected Host screen
→ Dashboard / Terminal / Files / Git Status
```

Do not stop after implementing navigation or mock screens. Implement the real flow through the existing Domain, Data, Presentation, DesignSystem, Shared, and JackSsh modules.

---

# 1. Host configuration

Update the host form so it captures all information required for the complete flow.

## Required SSH fields

- Display name
- Hostname or IP address
- SSH port
- SSH username
- Authentication method
- Password or SSH private key
- Optional private-key passphrase

## Required OpenClaw fields

- OpenClaw host or URL
- OpenClaw port
- OpenClaw base path
- URL scheme: `http` or `https`

## Required project field

- Favorite remote path

Example configuration:

```text
SSH

Host name:
Jack

Hostname:
108.174.154.104

Port:
22022

Username:
root
```

```text
OpenClaw

Host:
127.0.0.1

Port:
18789

Scheme:
http

Base path:
/
```

```text
Favorite remote path:

/root/openclaw/workspace/projects/innovation-n-trends
```

Do not force the user to type a complete OpenClaw URL when structured fields are easier to validate.

The application may construct the final URL internally:

```text
http://127.0.0.1:18789/
```

If OpenClaw is only reachable from the VPS localhost, the app must access it through SSH local port forwarding or another explicitly implemented secure tunnel. It must not assume that the iPhone can directly open VPS localhost.

---

# 2. Saved host interaction

When the user taps a saved host card, navigate to a connection flow.

Do not navigate directly to a static detail page.

Expected flow:

```text
Host card tapped
        ↓
Load secure credentials from Keychain
        ↓
Show Connecting screen
        ↓
Resolve hostname
        ↓
Open SSH connection
        ↓
Verify host key
        ↓
Authenticate
        ↓
Create active session
        ↓
Show Connected Host screen
```

---

# 3. Connecting screen

Create a dedicated connection screen.

Title:

```text
Connecting to {host.name}
```

Display connection stages:

- Resolving host
- Verifying server identity
- Authenticating
- Opening SSH session
- Preparing remote workspace

Example:

```text
Connecting to Jack

✓ Host resolved
✓ Server identity verified
● Authenticating…
○ Opening session
○ Preparing workspace

[ Cancel ]
```

Required states:

```swift
enum HostConnectionState: Equatable {
    case idle
    case resolving
    case verifyingHostKey(fingerprint: String?)
    case awaitingHostTrust(fingerprint: String)
    case authenticating
    case openingSession
    case preparingWorkspace
    case connected(ConnectedHostSession)
    case failed(HostConnectionFailure)
    case cancelled
}
```

Do not model these mutually exclusive stages using several unrelated Boolean properties.

The screen must support:

- Cancel connection
- Retry
- Authentication failure
- Host unreachable
- Timeout
- Unknown host key
- Changed host key
- Invalid configuration
- Missing credentials
- Connection lost

---

# 4. Connected Host screen

After a successful connection, display a screen whose title is the connected host name.

Example:

```text
Jack
Connected as root
108.174.154.104:22022
● Connected
```

Main options:

1. Open Dashboard
2. Open Terminal
3. Browse Files
4. Git Status

Suggested structure:

```text
Jack
● Connected

root@108.174.154.104:22022

Quick actions

[ Open Dashboard ]
[ Open Terminal  ]
[ Browse Files   ]
[ Git Status     ]

Favorite project

innovation-n-trends
/root/openclaw/workspace/projects/innovation-n-trends

Git status
● Clean

Last checked: just now
```

The Connected Host screen must use the active SSH session instead of reconnecting independently for every action when session reuse is safe.

Include:

- Disconnect action
- Connection state
- Automatic recovery when the connection drops
- Clear navigation back to Hosts
- Confirmation before disconnecting if an operation is active

---

# 5. Open Dashboard

The Open Dashboard action must use the OpenClaw configuration saved for that host.

There are two possible cases.

## Directly reachable OpenClaw

If the configured OpenClaw host is reachable from the iPhone, load:

```text
scheme://host:port/basePath
```

inside JackSsh using a SwiftUI wrapper around `WKWebView`.

## OpenClaw bound to VPS localhost

If the OpenClaw dashboard is bound to:

```text
127.0.0.1:18789
```

on the VPS, the iPhone cannot access that address directly.

Implement SSH local port forwarding through the active SSH connection:

```text
iPhone local endpoint
        ↓
SSH tunnel
        ↓
VPS 127.0.0.1:18789
```

The app must then load the tunneled local endpoint inside `WKWebView`.

Do not open Safari.

Dashboard states:

- Preparing tunnel
- Loading dashboard
- Connected
- Dashboard unavailable
- Unauthorized
- Tunnel failed
- Retry

The user must configure OpenClaw once and later open it with one tap.

---

# 6. Terminal

Open Terminal must use the active host session or create a dedicated SSH channel through the same connection.

Required minimum behavior:

- Interactive shell
- PTY allocation
- Command input
- Streaming output
- Copy output
- Clear local terminal view
- Reconnect when possible
- Show disconnected state

Do not implement a fake terminal or static command examples.

---

# 7. Browse Files

Browse Files must open an SFTP browser.

Initial directory:

- Use `favoriteRemotePath` when configured.
- Otherwise use the remote user home directory.

Required behavior:

- List folders and files
- Navigate into folders
- Navigate back
- Preview text files
- Show file size and modification date
- Download
- Upload
- Rename
- Delete with confirmation
- Copy remote path
- Handle permission errors

---

# 8. Git Status

Git Status must operate on the configured favorite remote path.

If no favorite remote path exists:

```text
No favorite project configured.

Add a remote project path in Host Settings to inspect Git status.
```

Before executing Git commands, validate:

```bash
test -d "$FAVORITE_PATH"
git -C "$FAVORITE_PATH" rev-parse --is-inside-work-tree
```

Use safe, fixed commands. Do not concatenate untrusted input into a shell command.

Required commands:

```bash
git -C "$FAVORITE_PATH" status --short
git -C "$FAVORITE_PATH" branch --show-current
git -C "$FAVORITE_PATH" rev-parse --show-toplevel
git -C "$FAVORITE_PATH" log -1 --pretty=format:%h%x09%s
```

Present the result in a simple native interface.

## Clean state

```text
innovation-n-trends

Branch
main

Status
● Working tree clean

Last commit
a1b2c3d Fix host connection flow
```

## Changed state

```text
innovation-n-trends

Branch
feature/host-connection

Status
● 4 changed files

Modified
M source/app/page.tsx
M source/components/Header.tsx

Untracked
?? source/domain/Host.ts
?? source/data/SSHRepository.ts

[ Refresh ]
[ Open Files ]
[ Open Terminal Here ]
```

Also distinguish:

- Clean
- Modified
- Staged
- Untracked
- Conflicted
- Not a Git repository
- Directory unavailable
- Permission denied
- Git command failed

Create a typed domain model instead of passing raw command text directly to SwiftUI.

Example:

```swift
struct GitRepositoryStatus: Equatable, Sendable {
    let repositoryRoot: String
    let branch: String?
    let lastCommit: GitCommitSummary?
    let entries: [GitStatusEntry]
    let checkedAt: Date

    var isClean: Bool {
        entries.isEmpty
    }
}
```

---

# 9. Home screen

The current Home screen shows global statuses as Unknown.

Update it so the saved favorite host influences the dashboard.

## When no host is configured

```text
No host configured

Add your VPS to start using JackSsh.

[ Add Host ]
```

## When a host exists but is disconnected

```text
Jack
● Disconnected

[ Connect ]
```

## When connected

```text
Jack
● Connected

OpenClaw     ● Available
Repository   ● 2 changes

[ Dashboard ] [ Terminal ]
```

“Private network: Down” must not be hardcoded.

It must be based on actual reachability or network state.

---

# 10. Architecture

Use the existing modular architecture.

## Domain

- `HostConfiguration`
- `OpenClawConfiguration`
- `ConnectedHostSession`
- `HostConnectionState`
- `HostConnectionFailure`
- `GitRepositoryStatus`
- `GitStatusEntry`
- `HostRepository` protocol
- `CredentialRepository` protocol
- `SSHRepository` protocol
- `SFTPRepository` protocol
- `GitRepository` protocol
- `DashboardTunnelRepository` protocol
- `ConnectToHost` use case
- `DisconnectHost` use case
- `LoadGitStatus` use case
- `OpenDashboardTunnel` use case

## Data

- `SwiftDataHostRepository`
- `KeychainCredentialRepository`
- `LiveSSHRepository`
- `LiveSFTPRepository`
- `LiveGitRepository`
- `LiveDashboardTunnelRepository`
- SSH host-key store
- Error mapping
- Safe command execution
- Session lifecycle management

## Presentation

- `HostsListView`
- `HostFormView`
- `ConnectingHostView`
- `ConnectedHostView`
- `DashboardView`
- `TerminalView`
- `RemoteFilesView`
- `GitStatusView`
- Their ViewModels and typed routes

## DesignSystem

- `HostCard`
- `ConnectionProgressView`
- `ConnectionStatusBadge`
- `QuickActionCard`
- `GitStatusSummaryCard`
- `GitFileStatusRow`
- `EmptyState`
- `ErrorState`
- `LoadingState`

## JackSsh app target

- Dependency composition
- Root navigation
- App lifecycle
- Session restoration policy

Do not put SSH, Git, SFTP, Keychain, or tunneling code directly in SwiftUI Views.

---

# 11. Security

- Load credentials from Keychain.
- Never store passwords or private keys in SwiftData.
- Never log credentials.
- Verify SSH host keys.
- Never silently accept a changed fingerprint.
- Request Face ID before loading saved credentials when enabled.
- Sanitize and validate the favorite remote path.
- Use fixed Git operations instead of arbitrary shell commands.
- Do not allow remote commands to be supplied through notification payloads.

---

# 12. Existing UI corrections

Preserve the visual direction, but fix these issues:

- Port `22022` must not appear as `22,022`.
- Host cards must clearly indicate that they are tappable.
- Add a visible connection state.
- Add a Connect button or chevron.
- The status dashboard must not remain Unknown after real checks.
- Do not display OpenClaw as Unknown when it has not yet been configured; use `Not configured`.
- Disable Open Dashboard when OpenClaw configuration is missing and offer `Configure`.
- Improve empty, loading, connected, and error states.
- Keep the UI native, simple, polished, and consistent with the existing dark design.

---

# 13. Validation

Inspect the existing project before editing.

Do not recreate existing modules or screens.

Run real validation using the existing project configuration:

```bash
xcodebuild -list
swift test
xcodebuild build
```

Use the real workspace, scheme, and destination already present in the repository.

Add Swift Testing coverage for:

- Host tap starts connection
- Connection state transitions
- Authentication failure
- Unknown host-key flow
- Changed host-key rejection
- Connected Host actions
- OpenClaw URL construction
- Dashboard tunnel creation
- Git status parsing
- Clean repository state
- Modified repository state
- Missing favorite path
- Not-a-Git-repository state
- Port display formatting
- Credential loading
- Connection cancellation

Do not claim that SSH, SFTP, tunneling, or Git operations work based only on mocks.

Clearly report whether each flow was:

- Unit tested
- Integration tested
- Tested against a real configurable VPS
- Not yet verifiable

---

# Acceptance criteria

The implementation is complete only when this flow works:

1. Launch JackSsh.
2. Open Hosts.
3. Tap a saved host.
4. See a real connecting screen.
5. Complete SSH authentication.
6. See a Connected Host screen titled with the host name.
7. Tap Open Dashboard and view OpenClaw inside the app.
8. Return and open an interactive terminal.
9. Browse the configured favorite remote directory.
10. View Git status for that directory.
11. See a clean or changed repository summary.
12. Disconnect safely.

At the end report:

- Files created
- Files modified
- Connection flow implemented
- SSH library used
- SFTP implementation
- Dashboard tunneling implementation
- Git status implementation
- Tests added
- Real VPS tests performed
- Build result
- Test result
- Remaining blockers
- Final Git status

Do not stop at UI scaffolding.

Do not use fake connection success.

Do not claim completion until tapping a saved host produces a real SSH connection flow.
