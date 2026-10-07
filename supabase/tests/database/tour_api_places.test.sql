begin;

create extension if not exists pgtap with schema extensions;
set search_path = public, extensions;
select plan(6);

insert into auth.users (id, email)
values
  ('80000000-0000-0000-0000-000000000001', 'tour-owner@nextmate.test'),
  ('80000000-0000-0000-0000-000000000002', 'tour-other@nextmate.test');

set local role authenticated;
select set_config('request.jwt.claim.sub', '80000000-0000-0000-0000-000000000001', true);

insert into public.trips (id, owner_id, title, destination_name, start_date, end_date, time_zone_id)
values (
  '81000000-0000-0000-0000-000000000001',
  '80000000-0000-0000-0000-000000000001',
  'Seoul visit', 'Seoul', '2026-10-10', '2026-10-11', 'Asia/Seoul'
);

select lives_ok(
  $$select public.add_tour_itinerary_item(
    '81000000-0000-0000-0000-000000000001', '2026-10-10', '123456',
    'en', 'Gyeongbokgung Palace', '161 Sajik-ro, Jongno-gu, Seoul',
    37.579617, 126.977041)$$,
  'official place and itinerary item are created together'
);

select is(
  (select count(*) from public.places
    where trip_id = '81000000-0000-0000-0000-000000000001'
      and location_source = 'tour_api' and tour_api_content_id = '123456'
      and tour_api_language = 'en' and latitude = 37.579617),
  1::bigint,
  'source, language and real coordinates are stored'
);

select is(
  (select count(*) from public.itinerary_items
    where trip_id = '81000000-0000-0000-0000-000000000001'),
  1::bigint,
  'scheduled item is visible to owner'
);

select throws_ok(
  $$select public.add_tour_itinerary_item(
    '81000000-0000-0000-0000-000000000001', '2026-10-10', '123457',
    'en', 'Bad coordinates', 'Seoul', 200, 126)$$,
  '23514', 'invalid TourAPI place', 'invalid coordinates are rejected'
);

select throws_ok(
  $$insert into public.places
    (trip_id, display_name, formatted_address, latitude, longitude, location_source)
    values ('81000000-0000-0000-0000-000000000001', 'Missing source ID',
      'Seoul', 37.579617, 126.977041, 'tour_api')$$,
  '23514',
  'new row for relation "places" violates check constraint "places_tour_api_source_complete"',
  'TourAPI places cannot omit source identity'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub', '80000000-0000-0000-0000-000000000002', true);

select is(
  (select count(*) from public.places
    where trip_id = '81000000-0000-0000-0000-000000000001'),
  0::bigint,
  'other users cannot read a trip place'
);

select * from finish();
rollback;
