-- Postcards (24-hour stories) and Scenes (short videos).
-- Run once in Supabase → SQL Editor → New query → Run (after setup.sql).

create table if not exists public.postcards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  media_url text not null,
  media_type text not null check (media_type in ('image','video')),
  caption text,
  place text,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default now() + interval '24 hours'
);
create index if not exists postcards_live_idx on public.postcards(expires_at);

create table if not exists public.scenes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  video_url text not null,
  caption text,
  place text,
  created_at timestamptz not null default now()
);
create index if not exists scenes_created_idx on public.scenes(created_at desc);

alter table public.postcards enable row level security;
alter table public.scenes enable row level security;

grant select on public.postcards, public.scenes to anon, authenticated;
grant insert, delete on public.postcards, public.scenes to authenticated;

-- Postcards: visible to everyone for 24 hours, then gone
drop policy if exists "postcards read live" on public.postcards;
create policy "postcards read live" on public.postcards for select using (expires_at > now());
drop policy if exists "postcards insert own" on public.postcards;
create policy "postcards insert own" on public.postcards for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "postcards delete own" on public.postcards;
create policy "postcards delete own" on public.postcards for delete to authenticated using (auth.uid() = user_id);

-- Scenes: visible to everyone
drop policy if exists "scenes read" on public.scenes;
create policy "scenes read" on public.scenes for select using (true);
drop policy if exists "scenes insert own" on public.scenes;
create policy "scenes insert own" on public.scenes for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "scenes delete own" on public.scenes;
create policy "scenes delete own" on public.scenes for delete to authenticated using (auth.uid() = user_id);

-- Allow videos up to 50 MB in the photos bucket
update storage.buckets set file_size_limit = 52428800 where id = 'photos';
