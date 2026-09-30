begin;

create extension if not exists pgtap with schema extensions;
set search_path = public, extensions;

select plan(20);

select has_table('public', 'profiles', 'profiles table exists');
select has_table('public', 'user_preferences', 'user_preferences table exists');
select has_table('public', 'trips', 'trips table exists');
select has_table('public', 'trip_members', 'trip_members table exists');
select has_table('public', 'stays', 'stays table exists');
select has_table('public', 'places', 'places table exists');
select has_table('public', 'itinerary_items', 'itinerary_items table exists');

select ok(
  (select relrowsecurity from pg_class where oid = 'public.profiles'::regclass),
  'profiles has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.user_preferences'::regclass),
  'user_preferences has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.trips'::regclass),
  'trips has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.trip_members'::regclass),
  'trip_members has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.stays'::regclass),
  'stays has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.places'::regclass),
  'places has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.itinerary_items'::regclass),
  'itinerary_items has RLS enabled'
);

insert into auth.users (id, email)
values
  ('10000000-0000-0000-0000-000000000001', 'owner@nextmate.test'),
  ('10000000-0000-0000-0000-000000000002', 'traveler@nextmate.test');

select is(
  (select count(*) from public.profiles where id in (
    '10000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000002'
  )),
  2::bigint,
  'creating auth users creates profiles'
);

select is(
  (select count(*) from public.user_preferences where user_id in (
    '10000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000002'
  )),
  2::bigint,
  'creating auth users creates preferences'
);

set local role authenticated;
select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000001',
  true
);

insert into public.trips (
  id,
  owner_id,
  title,
  destination_name,
  start_date,
  end_date,
  time_zone_id
)
values (
  '20000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000001',
  'Seoul test trip',
  'Seoul',
  '2026-10-01',
  '2026-10-05',
  'Asia/Seoul'
);

select is(
  (select count(*) from public.trip_members where trip_id = '20000000-0000-0000-0000-000000000001'),
  1::bigint,
  'creating a trip creates its owner membership'
);

select is(
  (select count(*) from public.trips where id = '20000000-0000-0000-0000-000000000001'),
  1::bigint,
  'the owner can read the trip'
);

reset role;
set local role authenticated;
select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000002',
  true
);

select is(
  (select count(*) from public.trips where id = '20000000-0000-0000-0000-000000000001'),
  0::bigint,
  'a non-member cannot read the trip'
);

reset role;
set local role authenticated;
select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000001',
  true
);

insert into public.trip_members (trip_id, user_id, role)
values (
  '20000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000002',
  'viewer'
);

reset role;
set local role authenticated;
select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000002',
  true
);

select is(
  (select count(*) from public.trips where id = '20000000-0000-0000-0000-000000000001'),
  1::bigint,
  'an invited viewer can read the trip'
);

select * from finish();
rollback;
