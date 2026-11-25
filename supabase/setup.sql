-- Places app: tables, security rules and photo storage.
-- Run once in Supabase → SQL Editor → New query → Run.

-- Profiles: one row per user
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  name text,
  bio text,
  avatar_url text,
  instagram text,
  telegram text,
  tiktok text,
  website text,
  created_at timestamptz not null default now()
);

-- Places: what people post
create table if not exists public.places (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  city text,
  note text,
  rating int check (rating between 0 and 5),
  tags text[] not null default '{}',
  photo_url text,
  created_at timestamptz not null default now()
);
create index if not exists places_user_idx on public.places(user_id);
create index if not exists places_created_idx on public.places(created_at desc);

alter table public.profiles enable row level security;
alter table public.places enable row level security;

grant select on public.profiles, public.places to anon, authenticated;
grant insert, update, delete on public.profiles, public.places to authenticated;

-- Everyone can read; you can only change your own rows
drop policy if exists "profiles read" on public.profiles;
create policy "profiles read" on public.profiles for select using (true);
drop policy if exists "profiles insert own" on public.profiles;
create policy "profiles insert own" on public.profiles for insert to authenticated with check (auth.uid() = id);
drop policy if exists "profiles update own" on public.profiles;
create policy "profiles update own" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "places read" on public.places;
create policy "places read" on public.places for select using (true);
drop policy if exists "places insert own" on public.places;
create policy "places insert own" on public.places for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "places update own" on public.places;
create policy "places update own" on public.places for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "places delete own" on public.places;
create policy "places delete own" on public.places for delete to authenticated using (auth.uid() = user_id);

-- Photo storage: public bucket, each user writes only into their own folder
insert into storage.buckets (id, name, public)
values ('photos', 'photos', true)
on conflict (id) do update set public = true;

drop policy if exists "photos read" on storage.objects;
create policy "photos read" on storage.objects for select using (bucket_id = 'photos');
drop policy if exists "photos upload own" on storage.objects;
create policy "photos upload own" on storage.objects for insert to authenticated
  with check (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "photos update own" on storage.objects;
create policy "photos update own" on storage.objects for update to authenticated
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "photos delete own" on storage.objects;
create policy "photos delete own" on storage.objects for delete to authenticated
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
