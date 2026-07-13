# Quick Setup for Personal Team

## 3 Steps to Build with Free Account:

### 1️⃣ Add Compiler Flag
In your app target's **Build Settings**:
- Search: "Other Swift Flags"  
- Add under Debug: `-D MOCK_NETWORK_EXTENSIONS`

### 2️⃣ Remove Capabilities
In **Signing & Capabilities**, remove:
- ❌ Network Extensions
- ❌ Push Notifications  
- ❌ iCloud

### 3️⃣ Exclude Packet Tunnel Extension
In **Product > Scheme > Edit Scheme > Build**:
- Uncheck the Packet Tunnel Extension target

---

✅ **You're ready!** Build and run on your device.

⚠️ Network features will be mocked (logs to console).

📖 See `PERSONAL_TEAM_SETUP.md` for detailed instructions.
