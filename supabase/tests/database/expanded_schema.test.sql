begin;

create extension if not exists pgtap with schema extensions;
set search_path = public, extensions;

select plan(25);

select has_table('public', 'user_devices', 'user_devices table exists');
select has_table('public', 'trip_invitations', 'trip_invitations table exists');
select has_table('public', 'reservations', 'reservations table exists');
select has_table('public', 'saved_routes', 'saved_routes table exists');
select has_table('public', 'transit_sessions', 'transit_sessions table exists');
select has_table('public', 'departure_alerts', 'departure_alerts table exists');
select has_table('public', 'notification_deliveries', 'notification_deliveries table exists');

select hasnt_column(
  'public',
  'user_preferences',
  'location_permission_status',
  'location permission is stored per device'
);
select hasnt_column(
  'public',
  'user_preferences',
  'uber_install_status',
  'Uber installation status is stored per device'
);

select ok(
  (select relrowsecurity from pg_class where oid = 'public.user_devices'::regclass),
  'user_devices has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.trip_invitations'::regclass),
  'trip_invitations has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.reservations'::regclass),
  'reservations has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.saved_routes'::regclass),
  'saved_routes has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.transit_sessions'::regclass),
  'transit_sessions has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.departure_alerts'::regclass),
  'departure_alerts has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.notification_deliveries'::regclass),
  'notification_deliveries has RLS enabled'
);

insert into auth.users (id, email)
values
  ('30000000-0000-0000-0000-000000000001', 'owner2@nextmate.test'),
  ('30000000-0000-0000-0000-000000000002', 'traveler2@nextmate.test');

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"30000000-0000-0000-0000-000000000001","email":"owner2@nextmate.test"}',
  true
);
select set_config(
  'request.jwt.claim.sub',
  '30000000-0000-0000-0000-000000000001',
  true
);

insert into public.user_devices (
  id,
  user_id,
  device_identifier,
  platform,
  location_permission_status,
  uber_install_status
)
values (
  '31000000-0000-0000-0000-000000000001',
  '30000000-0000-0000-0000-000000000001',
  'owner-test-device',
  'ios',
  'while_in_use',
  'installed'
);

select is(
  (select count(*) from public.user_devices),
  1::bigint,
  'a user can register and read their device'
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
  '40000000-0000-0000-0000-000000000001',
  '30000000-0000-0000-0000-000000000001',
  'Expanded schema trip',
  'Seoul',
  '2026-10-10',
  '2026-10-12',
  'Asia/Seoul'
);

insert into public.trip_invitations (
  id,
  trip_id,
  invitee_email,
  role,
  token_hash,
  expires_at
)
values (
  '41000000-0000-0000-0000-000000000001',
  '40000000-0000-0000-0000-000000000001',
  'traveler2@nextmate.test',
  'viewer',
  'test-token-hash',
  now() + interval '7 days'
);

select is(
  (select count(*) from public.trip_invitations),
  1::bigint,
  'a trip owner can create and read an invitation'
);

reset role;
set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"30000000-0000-0000-0000-000000000002","email":"traveler2@nextmate.test"}',
  true
);
select set_config(
  'request.jwt.claim.sub',
  '30000000-0000-0000-0000-000000000002',
  true
);

select is(
  (select count(*) from public.user_devices),
  0::bigint,
  'another user cannot read a device they do not own'
);

select is(
  (select count(*) from public.trip_invitations),
  1::bigint,
  'an invitee can read an invitation addressed to their email'
);

reset role;
set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"30000000-0000-0000-0000-000000000001","email":"owner2@nextmate.test"}',
  true
);
select set_config(
  'request.jwt.claim.sub',
  '30000000-0000-0000-0000-000000000001',
  true
);

insert into public.places (
  id,
  trip_id,
  display_name,
  formatted_address,
  latitude,
  longitude
)
values (
  '50000000-0000-0000-0000-000000000001',
  '40000000-0000-0000-0000-000000000001',
  'Myeongdong Cathedral',
  '74 Myeongdong-gil, Seoul',
  37.5633,
  126.9873
);

insert into public.itinerary_items (
  id,
  trip_id,
  place_id,
  scheduled_date,
  position,
  fixed_start_at,
  reservation_status
)
values (
  '60000000-0000-0000-0000-000000000001',
  '40000000-0000-0000-0000-000000000001',
  '50000000-0000-0000-0000-000000000001',
  '2026-10-11',
  0,
  '2026-10-11 10:00:00+09',
  'required'
);

insert into public.reservations (
  trip_id,
  itinerary_item_id,
  provider_name,
  booking_reference,
  starts_at,
  ends_at,
  time_zone_id,
  attendee_count
)
values (
  '40000000-0000-0000-0000-000000000001',
  '60000000-0000-0000-0000-000000000001',
  'NextMate test provider',
  'TEST-001',
  '2026-10-11 10:00:00+09',
  '2026-10-11 11:00:00+09',
  'Asia/Seoul',
  2
);

select is(
  (select count(*) from public.reservations),
  1::bigint,
  'an editor can store a reservation'
);

insert into public.saved_routes (
  id,
  route_group_id,
  trip_id,
  itinerary_item_id,
  travel_mode,
  origin_latitude,
  origin_longitude,
  destination_latitude,
  destination_longitude,
  duration_seconds,
  distance_meters,
  is_selected
)
values (
  '70000000-0000-0000-0000-000000000001',
  '71000000-0000-0000-0000-000000000001',
  '40000000-0000-0000-0000-000000000001',
  '60000000-0000-0000-0000-000000000001',
  'transit',
  37.5665,
  126.9780,
  37.5633,
  126.9873,
  900,
  2400,
  true
);

select is(
  (select count(*) from public.saved_routes),
  1::bigint,
  'an editor can save a selected route'
);

insert into public.transit_sessions (
  trip_id,
  saved_route_id,
  user_id,
  remaining_stops,
  current_instruction
)
values (
  '40000000-0000-0000-0000-000000000001',
  '70000000-0000-0000-0000-000000000001',
  '30000000-0000-0000-0000-000000000001',
  4,
  'Board Line 2'
);

select is(
  (select count(*) from public.transit_sessions),
  1::bigint,
  'a member can create a transit guidance session'
);

insert into public.departure_alerts (
  id,
  trip_id,
  itinerary_item_id,
  user_id,
  recommended_departure_at,
  scheduled_for,
  transport_mode
)
values (
  '80000000-0000-0000-0000-000000000001',
  '40000000-0000-0000-0000-000000000001',
  '60000000-0000-0000-0000-000000000001',
  '30000000-0000-0000-0000-000000000001',
  '2026-10-11 09:30:00+09',
  '2026-10-11 09:30:00+09',
  'transit'
);

select is(
  (select count(*) from public.departure_alerts),
  1::bigint,
  'a user can schedule a departure alert'
);

reset role;

insert into public.notification_deliveries (
  user_id,
  departure_alert_id,
  user_device_id,
  provider,
  status
)
values (
  '30000000-0000-0000-0000-000000000001',
  '80000000-0000-0000-0000-000000000001',
  '31000000-0000-0000-0000-000000000001',
  'apns',
  'sent'
);

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"30000000-0000-0000-0000-000000000001","email":"owner2@nextmate.test"}',
  true
);
select set_config(
  'request.jwt.claim.sub',
  '30000000-0000-0000-0000-000000000001',
  true
);

select is(
  (select count(*) from public.notification_deliveries),
  1::bigint,
  'a user can read delivery records for their alert'
);

select * from finish();
rollback;
