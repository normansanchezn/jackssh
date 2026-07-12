# Supabase Local Development Setup

## Prerequisites

- Docker & Docker Compose installed
- iOS 17+ for development

## Starting Supabase Local

```bash
cd /Users/normansanchez/ios/jackssh
docker-compose up -d
```

Wait 30-60 seconds for services to start.

## Access Points

- **Supabase Studio**: http://localhost:3000
- **REST API**: http://localhost:54321
- **PostgreSQL**: localhost:5433 (user: postgres, password: postgres)

## Initial Configuration

### 1. Create Auth Schema

```bash
# Open Studio at http://localhost:3000
# Go to SQL Editor
# Run the auth setup script
```

### 2. Get API Keys

```bash
# In Supabase Studio → Project Settings → API
# Copy:
# - anon public key
# - service_role secret key (backend only)
```

### 3. Configure iOS Client

Update `JackSshApp.swift`:

```swift
import Supabase

let supabaseClient = SupabaseClient(
    supabaseURL: URL(string: "http://localhost:54321")!,
    supabaseKey: "YOUR_ANON_KEY"
)
```

## Database Schema

Tables needed:

- `users` - User profiles (extends auth.users)
- `hosts` - SSH hosts with user_id FK
- `credentials` - Encrypted SSH passwords/keys
- `sync_queue` - Local changes waiting to sync

Enable Row-Level Security (RLS) on all tables:

```sql
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hosts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credentials ENABLE ROW LEVEL SECURITY;
```

## Testing Auth Locally

1. Stop the real Supabase and use Docker version
2. Create test account in Studio
3. Test email/password flow in iOS app
4. Verify data syncs to local database

## Troubleshooting

**Port already in use**:
```bash
docker-compose down
docker-compose up -d
```

**Need to reset data**:
```bash
docker-compose down -v
docker-compose up -d
```

**Studio not accessible**:
```bash
docker-compose logs supabase
# Check for startup errors
```

## Switching to Production

Update API URL and key in environment configuration.
