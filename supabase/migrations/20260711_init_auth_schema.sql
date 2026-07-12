-- Create users table (extends auth.users)
create table public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

alter table public.users enable row level security;

create policy "Users can view own profile"
  on public.users for select
  to authenticated
  using ((select auth.uid()) = id);

create policy "Users can update own profile"
  on public.users for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- Create hosts table
create table public.hosts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  name text not null,
  hostname text not null,
  port integer not null default 22,
  username text not null,
  auth_method text not null,
  openclaw_host text,
  openclaw_port integer default 18789,
  openclaw_scheme text default 'http',
  openclaw_base_path text default '/',
  favorite_remote_path text,
  is_favorite boolean default false,
  last_sync_at timestamp with time zone,
  sync_state text default 'synced',
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

alter table public.hosts enable row level security;

create policy "Users can view own hosts"
  on public.hosts for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can create hosts"
  on public.hosts for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can update own hosts"
  on public.hosts for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users can delete own hosts"
  on public.hosts for delete
  to authenticated
  using ((select auth.uid()) = user_id);

-- Create sync_queue table (offline-first)
create table public.sync_queue (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  entity_type text not null,
  entity_id uuid not null,
  operation text not null,
  payload jsonb,
  is_synced boolean default false,
  created_at timestamp with time zone default now(),
  synced_at timestamp with time zone
);

alter table public.sync_queue enable row level security;

create policy "Users can view own sync queue"
  on public.sync_queue for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can insert to sync queue"
  on public.sync_queue for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can delete from sync queue"
  on public.sync_queue for delete
  to authenticated
  using ((select auth.uid()) = user_id);

-- Create credentials table (encrypted)
create table public.credentials (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  host_id uuid not null references public.hosts(id) on delete cascade,
  credential_type text not null,
  encrypted_data text not null,
  created_at timestamp with time zone default now()
);

alter table public.credentials enable row level security;

create policy "Users can view own credentials"
  on public.credentials for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can create credentials"
  on public.credentials for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can delete credentials"
  on public.credentials for delete
  to authenticated
  using ((select auth.uid()) = user_id);

-- Indexes
create index idx_hosts_user_id on public.hosts(user_id);
create index idx_sync_queue_user_id on public.sync_queue(user_id);
create index idx_sync_queue_unsynced on public.sync_queue(is_synced);
create index idx_credentials_host_id on public.credentials(host_id);
