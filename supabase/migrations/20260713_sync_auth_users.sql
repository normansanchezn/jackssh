-- Sync auth.users → public.users via trigger
-- When a new user signs up, automatically create public.users record

-- Create trigger function
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, email, created_at, updated_at)
  values (new.id, new.email, now(), now())
  on conflict (id) do update set updated_at = now();
  return new;
end;
$$ language plpgsql security definer set search_path = public;

-- Drop existing trigger if any
drop trigger if exists on_auth_user_created on auth.users;

-- Create trigger
create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute procedure public.handle_new_user();

-- Ensure RLS is enabled
alter table public.users enable row level security;

-- Create missing policies if needed
drop policy if exists "Users can view own profile" on public.users;
drop policy if exists "Users can update own profile" on public.users;

create policy "Users can view own profile"
  on public.users for select
  to authenticated
  using ((select auth.uid()) = id);

create policy "Users can update own profile"
  on public.users for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create policy "Users can insert own profile"
  on public.users for insert
  to authenticated
  with check ((select auth.uid()) = id);
