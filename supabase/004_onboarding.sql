-- Onboarding quiz answers on the profile.
-- Run once in Supabase → SQL Editor → New query → Run.

alter table public.profiles add column if not exists interests text[] not null default '{}';
alter table public.profiles add column if not exists home_city text;
alter table public.profiles add column if not exists home_lat double precision;
alter table public.profiles add column if not exists home_lng double precision;
alter table public.profiles add column if not exists taste text;
alter table public.profiles add column if not exists onboarded boolean not null default false;
