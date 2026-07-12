# JackSsh Development Setup

## Local Supabase Configuration

### Requirements
- Docker & Docker Compose (or Supabase CLI)
- Xcode 15+
- Swift 6

### Supabase CLI Setup

```bash
# Install Supabase CLI
brew install supabase/tap/supabase

# Start local Supabase
cd /Users/normansanchez/ios/jackssh
supabase start
```

### Credentials (Local)

From `supabase status` output:

```
API_URL: http://127.0.0.1:54321
ANON_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
SERVICE_ROLE_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
JWT_SECRET: super-secret-jwt-token-with-at-least-32-characters-long
DB_URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
```

### Configuration in Code

**File:** `JackSsh/JackSsh/CompositionRoot.swift` (lines 43-48)

```swift
// Supabase Auth — Local Dev (change to prod URL/key as needed)
let supabaseURL = URL(string: "http://127.0.0.1:54321")!
let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
```

### Supabase Studio (Admin Panel)

- URL: http://127.0.0.1:54323
- Access: Auth → Users (view created accounts)
- Create test accounts for development

### Switching to Production

Update `CompositionRoot.swift` with prod credentials:

```swift
let supabaseURL = URL(string: "https://qaqotvrvqglmgjlyesnf.supabase.co")!
let supabaseKey = "[prod-anon-key]"
```

### Database Setup

For local development, Supabase CLI auto-initializes schema. To reset:

```bash
supabase db reset
```

### Troubleshooting

**Port conflicts:**
```bash
# If 54321/54322 in use, stop Supabase and restart
supabase stop
supabase start
```

**Credentials expired:**
- Run `supabase status` to refresh
- Update CompositionRoot accordingly

**SignUp/Login fails:**
- Check Supabase Studio → Auth → Users panel
- Verify credentials in CompositionRoot match `supabase status`

### Build & Run

```bash
# Build
xcodebuild build -scheme JackSsh -destination "generic/platform=iOS"

# Run on simulator
xcodebuild -scheme JackSsh -destination "generic/platform=iOS Simulator" run
```

### SSH Configuration (VPS Testing)

For SSH terminal testing, configure hosts via app:
1. Create host in Hosts tab
2. Add hostname, username, password
3. Test connection → Terminal tab

### Related Files

- `CompositionRoot.swift` — Auth config (lines 43-48)
- `SupabaseAuthRepository.swift` — HTTP request handling
- `AuthViewModel.swift` — Auth state management
- `.env.local` — Prod credentials (DO NOT commit to git)

---

Last Updated: 2026-07-12
