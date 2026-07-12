# Supabase Auth & Data Setup

## Problem Fixed

- Error 422 en SignUp: public.users no se creaba automáticamente
- Login fallaba: RLS policies incorrectas
- Hosts data lost: Permisos insuficientes

## Solution

Dos migraciones SQL crean triggers y arreglan RLS:

1. `20260712_sync_auth_users.sql` — Trigger que crea public.users cuando auth.users se crea
2. `20260712_fix_hosts_rls.sql` — RLS policies para hosts table

## Aplicar Cambios

### Opción 1: Supabase Dashboard (más fácil)

1. Abre https://app.supabase.com/projects
2. Selecciona proyecto `qaqotvrvqglmgjlyesnf`
3. SQL Editor → New query
4. Copia contenido de `supabase/migrations/20260712_sync_auth_users.sql`
5. Run
6. Repite con `20260712_fix_hosts_rls.sql`

### Opción 2: CLI (recomendado)

```bash
cd /Users/normansanchez/ios/jackssh

# Push migrations a Supabase remoto
supabase db push

# O pull schema local primero
supabase db pull

# Luego push
supabase db push
```

## Verifica

Después de aplicar:

1. **SignUp en app:**
   - Email: `hello@normansanchez.dev`
   - Password: `testpass123`
   - Debe crear en auth.users Y public.users

2. **Dashboard check:**
   - Auth → Users → debe existir usuario
   - Database → public.users → debe existir registro

3. **Login:**
   - Welcome → Sign In
   - Email: `hello@normansanchez.dev`
   - Password: `testpass123`
   - Debe entrar a Home

## Troubleshooting

Error 422 persiste → check Dashboard SQL logs para detalles

Error de permisos RLS → rerun `20260712_fix_hosts_rls.sql`

No puedo ver usuarios → Supabase Studio puede ocultar auth.users, usa SQL Editor para verificar
