-- Ensure hosts table RLS is properly configured

-- Enable RLS
alter table public.hosts enable row level security;

-- Drop existing policies
drop policy if exists "Users can view own hosts" on public.hosts;
drop policy if exists "Users can create hosts" on public.hosts;
drop policy if exists "Users can update own hosts" on public.hosts;
drop policy if exists "Users can delete own hosts" on public.hosts;

-- View policy
create policy "Users can view own hosts"
  on public.hosts for select
  to authenticated
  using ((select auth.uid()) = user_id);

-- Create policy
create policy "Users can insert own hosts"
  on public.hosts for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

-- Update policy (needs both USING and WITH CHECK)
create policy "Users can update own hosts"
  on public.hosts for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- Delete policy
create policy "Users can delete own hosts"
  on public.hosts for delete
  to authenticated
  using ((select auth.uid()) = user_id);

-- Grant permissions to authenticated users
grant select, insert, update, delete on public.hosts to authenticated;
grant usage on schema public to authenticated;
