# Supabase Integration Guide for JackSsh

## Architecture: Offline-First with Remote Sync

```
Local SwiftData (always current)
        ↓
Sync Queue (pending changes)
        ↓
Supabase Backend (source of truth)
        ↓
Realtime Sync (via Supabase)
        ↓
Update Local (merge strategy)
```

## Phase 1: Auth Onboarding (Minimal Supabase)

### Files Already Created
- `User.swift` - Domain entity
- `SyncState.swift` - Sync tracking
- `AuthViewModel.swift` - Auth state management
- `SplashView.swift`, `WelcomeView.swift`, `LoginView.swift`
- `docker-compose.yml` - Local Supabase

### Next Steps

1. **Set up Supabase Client (Stubbed)**
   Create `jackssh-data/Sources/Data/Supabase/SupabaseClient.swift`:
   ```swift
   public protocol SupabaseClientProtocol {
       func auth() -> AuthClient
       func db() -> DatabaseClient
   }
   
   public class SupabaseClient: SupabaseClientProtocol {
       // Stub implementation
       public func auth() -> AuthClient { ... }
       public func db() -> DatabaseClient { ... }
   }
   ```

2. **Implement Auth Repository**
   Create `jackssh-data/Sources/Data/Auth/SupabaseAuthRepository.swift`:
   ```swift
   public actor SupabaseAuthRepository: AuthRepository {
       private let client: SupabaseClientProtocol
       
       public func signUp(email: String, password: String) async throws -> User {
           // Use supabase-swift Auth API
       }
       
       public func signIn(email: String, password: String) async throws -> User {
           // Use supabase-swift Auth API
       }
       
       // ... other methods
   }
   ```

3. **Add Auth to Composition Root**
   Update `JackSsh/CompositionRoot.swift`:
   ```swift
   let authRepository: AuthRepository = SupabaseAuthRepository(client: supabaseClient)
   let authViewModel = AuthViewModel(
       signIn: SignIn(authRepository: authRepository),
       signUp: SignUp(authRepository: authRepository),
       signOut: SignOut(authRepository: authRepository),
       getCurrentUser: GetCurrentUser(authRepository: authRepository)
   )
   ```

4. **Update Root Navigation**
   Modify `RootView.swift` to show auth flow:
   ```swift
   @State private var authState: AuthState = .unauthenticated
   
   var body: some View {
       if case .authenticated = authState {
           HomeView() // Existing app
       } else {
           SplashView() // Shows while checking auth
               .onAppear { checkAuth() }
       }
   }
   ```

## Phase 2: Local Persistence + Sync Queue

1. **Create Sync Repository**
   SwiftData-backed queue for pending changes

2. **Implement Background Sync**
   Monitor network status + sync when online

3. **Conflict Resolution**
   Last-write-wins strategy (configurable)

## Phase 3: Host Data Sync

1. **Extend Host model with sync metadata**
   ```swift
   struct HostRecord {
       // existing fields...
       var syncState: SyncState
       var lastSyncedAt: Date?
   }
   ```

2. **Sync when saving/deleting hosts**

## Security Notes

- Never log credentials (use Redactor)
- Always use HTTPS in production
- Enable RLS on all Supabase tables
- Use service_role key only in backend
- Validate all user input before sync

## Testing Locally

```bash
# Start Supabase
docker-compose up -d

# Check status
curl http://localhost:54321/health

# Access Studio
open http://localhost:3000
```

## Troubleshooting

**SupabaseClient not found**: Ensure supabase-swift dependency is correctly added to jackssh-data/Package.swift

**Auth fails**: Check Supabase URL and anon key in environment

**Sync not working**: Verify network connectivity + RLS policies

## Security Checklist

- [ ] All tables have RLS enabled
- [ ] anon role has explicit GRANT (not `*`)
- [ ] No user_metadata used for auth decisions (use app_metadata)
- [ ] JWT tokens have short expiry (<1 hour)
- [ ] Credentials never logged
- [ ] Offline changes validated before sync

## References

- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [Offline-First Strategy](https://supabase.com/docs/guides/realtime/overview)
- [RLS Security](https://supabase.com/docs/guides/auth/row-level-security)
