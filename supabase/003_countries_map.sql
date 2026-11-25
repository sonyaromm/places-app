-- Countries visited (profile) and coordinates for places (map).
-- Run once in Supabase → SQL Editor → New query → Run.

alter table public.profiles add column if not exists countries text[] not null default '{}';

alter table public.places add column if not exists lat double precision;
alter table public.places add column if not exists lng double precision;
alter table public.places add column if not exists country text;

-- sanity limits
alter table public.places drop constraint if exists places_lat_range;
alter table public.places add constraint places_lat_range check (lat is null or (lat between -90 and 90));
alter table public.places drop constraint if exists places_lng_range;
alter table public.places add constraint places_lng_range check (lng is null or (lng between -180 and 180));
