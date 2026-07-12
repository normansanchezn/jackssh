-- Keep remote host metadata aligned with the Domain.Host model.

alter table public.hosts
  add column if not exists private_address text,
  add column if not exists tags text[] not null default '{}',
  add column if not exists ssh_key_id uuid,
  add column if not exists last_successful_connection timestamp with time zone;

grant select, insert, update, delete on public.hosts to authenticated;
