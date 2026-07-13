# Personal Development Team Setup Guide

This guide helps you build JackSSH with a personal/free Apple Developer account.

## The Problem

Personal Apple Developer accounts do not support:
- ❌ Network Extensions (VPN, Packet Tunnel)
- ❌ Push Notifications  
- ❌ iCloud

## Solution: Conditional Compilation

We've added conditional compilation flags that allow you to build without these capabilities.

---

## Setup Instructions

### Step 1: Add Compiler Flag

1. Open your project in Xcode
2. Select the **JackSsh** project in the navigator
3. Select your **app target** (not the packet tunnel extension)
4. Go to **Build Settings** tab
5. Search for "Swift Compiler - Custom Flags"
6. Under **Other Swift Flags**, find the **Debug** configuration
7. Add: `-D MOCK_NETWORK_EXTENSIONS`

   It should look like:
   ```
   Debug: -D MOCK_NETWORK_EXTENSIONS
   ```

### Step 2: Disable Capabilities in Xcode

1. Select your **app target**
2. Go to **Signing & Capabilities** tab
3. Remove these capabilities by clicking the ❌ next to each:
   - **Network Extensions** (or Personal VPN)
   - **Push Notifications** (if present)
   - **iCloud** (if present)

### Step 3: Disable or Exclude Packet Tunnel Extension Target

Since the PacketTunnelProvider target requires Network Extensions entitlement:

**Option A - Exclude from scheme:**
1. Go to **Product > Scheme > Edit Scheme**
2. Under **Build**, uncheck the Packet Tunnel Extension target

**Option B - Remove target from project (temporary):**
1. Select the Packet Tunnel Extension target
2. Right-click and choose "Delete" (choose "Remove Reference" not "Move to Trash")
3. You can re-add it later when you have a paid account

### Step 4: Build and Run

Now you should be able to build and run on device with your personal team!

⚠️ **Note:** Network features (port forwarding, VPN tunnels) will not work. Mock implementations will log warnings to the console.

---

## What Works in Mock Mode

✅ Authentication and UI
✅ Host management (viewing, editing)
✅ SSH connection attempts (may fail without proper tunneling)
✅ Terminal UI
✅ File browser UI
✅ All SwiftUI layouts and navigation

## What Doesn't Work in Mock Mode

❌ Actual VPN/packet tunnel functionality
❌ Port forwarding through Network Extensions
❌ Features requiring iCloud sync (local-only works)
❌ Push notifications

---

## When You Get a Paid Account

1. Remove the `-D MOCK_NETWORK_EXTENSIONS` flag
2. Re-enable capabilities in Signing & Capabilities
3. Re-add the Packet Tunnel Extension target to your scheme
4. Build normally — everything will work!

---

## Troubleshooting

### "Module 'NetworkExtension' not found"
- Make sure you added the `-D MOCK_NETWORK_EXTENSIONS` flag to **Debug** configuration only
- Clean build folder (⌘ + Shift + K)

### Still getting provisioning errors
- Double-check all capabilities are removed in **Signing & Capabilities**
- Check both Debug and Release configurations
- Try removing and re-adding your Apple ID in Xcode Preferences

### Can't find the compiler flags setting
- Make sure you're in **Build Settings** not Build Phases
- Search for "Other Swift Flags"
- Make sure you're editing the target, not the project

---

## Alternative: Simulator Only

If you just want to test UI/UX, you can:
- Build for Simulator (no device provisioning needed)
- Keep all code as-is
- Mock the network layer manually in your view models

The Network Extensions don't work in Simulator anyway, so it's a good development environment.
