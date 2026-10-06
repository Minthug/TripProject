begin;

create extension if not exists pgtap with schema extensions;
set search_path = public, extensions;
select plan(6);

insert into auth.users (id, email)
values
  ('70000000-0000-0000-0000-000000000001', 'draft-owner@nextmate.test'),
  ('70000000-0000-0000-0000-000000000002', 'draft-other@nextmate.test');

set local role authenticated;
select set_config('request.jwt.claim.sub', '70000000-0000-0000-0000-000000000001', true);

insert into public.trips (id, owner_id, title, destination_name, start_date, end_date, time_zone_id)
values (
  '71000000-0000-0000-0000-000000000001',
  '70000000-0000-0000-0000-000000000001',
  '서울 주말 여행', '서울', '2026-10-10', '2026-10-11', 'Asia/Seoul'
);

select lives_ok(
  $$select public.add_draft_itinerary_item(
    '71000000-0000-0000-0000-000000000001', '2026-10-10', '경복궁', '오전 방문')$$,
  'the RPC atomically creates a draft place and schedule item'
);

select is(
  (select count(*) from public.places
    where trip_id = '71000000-0000-0000-0000-000000000001'
      and location_source = 'manual_entry'
      and latitude is null and longitude is null),
  1::bigint,
  'draft place has no fabricated coordinates'
);

select is(
  (select count(*) from public.itinerary_items where trip_id = '71000000-0000-0000-0000-000000000001'),
  1::bigint,
  'the owner can read the saved schedule'
);

select throws_ok(
  $$update public.trips set start_date = '2026-10-11'
    where id = '71000000-0000-0000-0000-000000000001'$$,
  '23514',
  'trip dates exclude scheduled items',
  'trip dates cannot exclude a saved itinerary item'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub', '70000000-0000-0000-0000-000000000002', true);

select is(
  (select count(*) from public.itinerary_items where trip_id = '71000000-0000-0000-0000-000000000001'),
  0::bigint,
  'another user cannot read the schedule'
);

select throws_ok(
  $$select public.add_draft_itinerary_item(
    '71000000-0000-0000-0000-000000000001', '2026-10-11', '비인가 장소')$$,
  '42501',
  'new row violates row-level security policy for table "places"',
  'another user cannot add a draft to the trip'
);

select * from finish();
rollback;
