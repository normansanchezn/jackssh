---
title: Permissions and Privacy
tags:
  - jackssh
  - setup
  - ios-permissions
  - privacy
---

# JackSsh Permissions & Privacy

## Required Permissions

### Local Network Access
- **Key**: `NSLocalNetworkUsageDescription`
- **Purpose**: Connect to SSH hosts on private networks
- **Triggers**: When attempting SSH connection to local IP or private domain
- **Dialog Text**: "JackSsh needs access to your local network to connect to SSH hosts on your private network."

### Bonjour Service Discovery
- **Key**: `NSBonjourServices`
- **Services**: `_ssh._tcp`, `_sftp._tcp`
- **Purpose**: Discover SSH/SFTP services on local network (optional feature)

### Network Extension
- **Key**: `NSNetworkExtensionUsageDescription`
- **Purpose**: SSH port forwarding for dashboard access through VPN tunnels
- **Triggers**: When opening OpenClaw dashboard via SSH tunnel
- **Dialog Text**: "JackSsh uses network extensions to create secure tunnels for accessing remote services through SSH port forwarding."

## Privacy Manifest (iOS 17+)

**File**: `PrivacyInfo.xcprivacy`

Declares API usage for App Store compliance:
- **Networking APIs** (C3092.1) - SSH connections, SFTP transfers
- **SystemBootTime APIs** (35F9.1) - Connection timing
- **FileTimestampApis** (DDA9.1) - File metadata (SFTP)

## Credential Security

- SSH passwords and keys: Stored in Keychain (encrypted)
- Never logged in plaintext (redacted in DEBUG logs)
- Deleted when host deleted
- Face ID/Touch ID not yet implemented (future enhancement)

## No Tracking

- `NSPrivacyTracking`: false
- No analytics or third-party tracking
- No data collection
