-- Ensure users created before the auth.users -> public.users trigger exist in
-- public.users. Hosts reference public.users(id), so missing profile rows make
-- host inserts fail with a foreign-key violation.

insert into public.users (id, email, created_at, updated_at)
select
  id,
  coalesce(email, ''),
  coalesce(created_at, now()),
  now()
from auth.users
on conflict (id) do update
set
  email = excluded.email,
  updated_at = now();

grant select, insert, update on public.users to authenticated;
