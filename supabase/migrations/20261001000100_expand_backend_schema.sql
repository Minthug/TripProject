alter table public.user_preferences
  drop constraint user_preferences_location_permission_valid,
  drop constraint user_preferences_uber_install_status_valid,
  drop column location_permission_status,
  drop column uber_install_status;

create table public.user_devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  device_identifier text not null,
  platform text not null,
  push_token text,
  location_permission_status text not null default 'unknown',
  uber_install_status text not null default 'unknown',
  notifications_enabled boolean not null default true,
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_devices_user_and_identifier_unique unique (user_id, device_identifier),
  constraint user_devices_user_and_id_unique unique (user_id, id),
  constraint user_devices_identifier_not_blank check (btrim(device_identifier) <> ''),
  constraint user_devices_platform_valid check (platform in ('ios', 'android', 'web')),
  constraint user_devices_location_permission_valid check (
    location_permission_status in ('unknown', 'denied', 'restricted', 'while_in_use', 'always')
  ),
  constraint user_devices_uber_install_status_valid check (
    uber_install_status in ('unknown', 'installed', 'missing', 'unavailable')
  )
);

create unique index user_devices_push_token_unique_idx
  on public.user_devices (push_token)
  where push_token is not null;

create table public.trip_invitations (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips (id) on delete cascade,
  invited_by uuid not null default auth.uid() references public.profiles (id) on delete restrict,
  invitee_email text not null,
  role text not null default 'viewer',
  status text not null default 'pending',
  token_hash text not null unique,
  expires_at timestamptz not null,
  accepted_by uuid references public.profiles (id) on delete set null,
  responded_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint trip_invitations_email_valid check (
    invitee_email = lower(btrim(invitee_email))
    and position('@' in invitee_email) > 1
  ),
  constraint trip_invitations_role_valid check (role in ('editor', 'viewer')),
  constraint trip_invitations_status_valid check (
    status in ('pending', 'accepted', 'declined', 'revoked', 'expired')
  ),
  constraint trip_invitations_expiry_valid check (expires_at > created_at),
  constraint trip_invitations_response_consistent check (
    (status = 'pending' and responded_at is null)
    or (status <> 'pending' and responded_at is not null)
  ),
  constraint trip_invitations_acceptance_consistent check (
    (status = 'accepted' and accepted_by is not null)
    or (status <> 'accepted' and accepted_by is null)
  )
);

create unique index trip_invitations_pending_email_unique_idx
  on public.trip_invitations (trip_id, lower(invitee_email))
  where status = 'pending';

alter table public.itinerary_items
  add constraint itinerary_items_trip_and_id_unique unique (trip_id, id);

create table public.reservations (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null,
  itinerary_item_id uuid not null,
  status text not null default 'confirmed',
  provider_name text,
  booking_reference text,
  starts_at timestamptz not null,
  ends_at timestamptz,
  time_zone_id text not null,
  attendee_count integer not null default 1,
  notes text,
  created_by uuid not null default auth.uid() references public.profiles (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint reservations_itinerary_item_unique unique (itinerary_item_id),
  constraint reservations_item_in_trip
    foreign key (trip_id, itinerary_item_id)
    references public.itinerary_items (trip_id, id)
    on delete cascade,
  constraint reservations_status_valid check (
    status in ('pending', 'confirmed', 'cancelled')
  ),
  constraint reservations_time_range_valid check (ends_at is null or ends_at > starts_at),
  constraint reservations_time_zone_not_blank check (btrim(time_zone_id) <> ''),
  constraint reservations_attendee_count_positive check (attendee_count > 0)
);

create table public.saved_routes (
  id uuid primary key default gen_random_uuid(),
  route_group_id uuid not null default gen_random_uuid(),
  trip_id uuid not null references public.trips (id) on delete cascade,
  itinerary_item_id uuid,
  provider text not null default 'google_routes',
  travel_mode text not null,
  origin_latitude double precision not null,
  origin_longitude double precision not null,
  destination_latitude double precision not null,
  destination_longitude double precision not null,
  duration_seconds integer not null,
  distance_meters integer not null,
  departure_at timestamptz,
  arrival_at timestamptz,
  estimated_cost_min numeric(12, 2),
  estimated_cost_max numeric(12, 2),
  currency_code text,
  guidance_snapshot jsonb not null default '{}'::jsonb,
  is_selected boolean not null default false,
  expires_at timestamptz,
  created_by uuid not null default auth.uid() references public.profiles (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint saved_routes_trip_and_id_unique unique (trip_id, id),
  constraint saved_routes_item_in_trip
    foreign key (trip_id, itinerary_item_id)
    references public.itinerary_items (trip_id, id)
    on delete cascade,
  constraint saved_routes_provider_valid check (provider in ('google_routes', 'uber_estimate', 'manual')),
  constraint saved_routes_travel_mode_valid check (
    travel_mode in ('transit', 'walking', 'uber', 'driving')
  ),
  constraint saved_routes_origin_latitude_valid check (origin_latitude between -90 and 90),
  constraint saved_routes_origin_longitude_valid check (origin_longitude between -180 and 180),
  constraint saved_routes_destination_latitude_valid check (destination_latitude between -90 and 90),
  constraint saved_routes_destination_longitude_valid check (destination_longitude between -180 and 180),
  constraint saved_routes_duration_nonnegative check (duration_seconds >= 0),
  constraint saved_routes_distance_nonnegative check (distance_meters >= 0),
  constraint saved_routes_arrival_after_departure check (
    departure_at is null or arrival_at is null or arrival_at >= departure_at
  ),
  constraint saved_routes_cost_min_nonnegative check (
    estimated_cost_min is null or estimated_cost_min >= 0
  ),
  constraint saved_routes_cost_max_valid check (
    estimated_cost_max is null
    or (estimated_cost_max >= 0 and (estimated_cost_min is null or estimated_cost_max >= estimated_cost_min))
  ),
  constraint saved_routes_currency_with_cost check (
    (estimated_cost_min is null and estimated_cost_max is null)
    or currency_code ~ '^[A-Z]{3}$'
  )
);

create unique index saved_routes_one_selected_per_group_idx
  on public.saved_routes (route_group_id)
  where is_selected;

create index saved_routes_trip_idx on public.saved_routes (trip_id, created_at desc);
create index saved_routes_expiry_idx on public.saved_routes (expires_at)
  where expires_at is not null;

create table public.transit_sessions (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null,
  saved_route_id uuid not null,
  user_id uuid not null references public.profiles (id) on delete cascade,
  state text not null default 'awaiting_boarding',
  current_step integer not null default 0,
  current_stop_index integer not null default 0,
  remaining_stops integer,
  current_instruction text,
  confirmations jsonb not null default '[]'::jsonb,
  started_at timestamptz not null default now(),
  last_confirmed_at timestamptz,
  ended_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint transit_sessions_route_in_trip
    foreign key (trip_id, saved_route_id)
    references public.saved_routes (trip_id, id)
    on delete cascade,
  constraint transit_sessions_state_valid check (
    state in ('awaiting_boarding', 'on_board', 'transferring', 'arrived', 'cancelled')
  ),
  constraint transit_sessions_current_step_nonnegative check (current_step >= 0),
  constraint transit_sessions_current_stop_nonnegative check (current_stop_index >= 0),
  constraint transit_sessions_remaining_stops_nonnegative check (
    remaining_stops is null or remaining_stops >= 0
  ),
  constraint transit_sessions_end_after_start check (ended_at is null or ended_at >= started_at)
);

create unique index transit_sessions_one_active_route_user_idx
  on public.transit_sessions (saved_route_id, user_id)
  where state not in ('arrived', 'cancelled');

create index transit_sessions_user_idx on public.transit_sessions (user_id, started_at desc);

create table public.departure_alerts (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null,
  itinerary_item_id uuid not null,
  user_id uuid not null references public.profiles (id) on delete cascade,
  status text not null default 'scheduled',
  recommended_departure_at timestamptz not null,
  scheduled_for timestamptz not null,
  snoozed_until timestamptz,
  delay_minutes integer not null default 0,
  transport_mode text not null,
  context_snapshot jsonb not null default '{}'::jsonb,
  acted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint departure_alerts_user_and_id_unique unique (user_id, id),
  constraint departure_alerts_item_in_trip
    foreign key (trip_id, itinerary_item_id)
    references public.itinerary_items (trip_id, id)
    on delete cascade,
  constraint departure_alerts_status_valid check (
    status in ('scheduled', 'leave_now', 'snoozed', 'delayed', 'skipped', 'cancelled')
  ),
  constraint departure_alerts_delay_nonnegative check (delay_minutes >= 0),
  constraint departure_alerts_transport_mode_valid check (
    transport_mode in ('transit', 'walking', 'uber', 'driving')
  ),
  constraint departure_alerts_snooze_consistent check (
    (status = 'snoozed' and snoozed_until is not null)
    or status <> 'snoozed'
  )
);

create unique index departure_alerts_one_active_user_item_idx
  on public.departure_alerts (user_id, itinerary_item_id)
  where status in ('scheduled', 'leave_now', 'snoozed', 'delayed');

create index departure_alerts_due_idx on public.departure_alerts (scheduled_for)
  where status in ('scheduled', 'snoozed', 'delayed');

create table public.notification_deliveries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  departure_alert_id uuid not null,
  user_device_id uuid not null,
  provider text not null,
  status text not null default 'queued',
  provider_message_id text,
  failure_code text,
  attempted_at timestamptz,
  delivered_at timestamptz,
  opened_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint notification_deliveries_alert_owner
    foreign key (user_id, departure_alert_id)
    references public.departure_alerts (user_id, id)
    on delete cascade,
  constraint notification_deliveries_device_owner
    foreign key (user_id, user_device_id)
    references public.user_devices (user_id, id)
    on delete cascade,
  constraint notification_deliveries_provider_valid check (provider in ('fcm', 'apns')),
  constraint notification_deliveries_status_valid check (
    status in ('queued', 'sent', 'delivered', 'failed', 'opened')
  )
);

create index notification_deliveries_alert_idx
  on public.notification_deliveries (departure_alert_id, created_at desc);
create index notification_deliveries_device_idx
  on public.notification_deliveries (user_device_id, created_at desc);

create trigger user_devices_set_updated_at
before update on public.user_devices
for each row execute function public.set_updated_at();

create trigger trip_invitations_set_updated_at
before update on public.trip_invitations
for each row execute function public.set_updated_at();

create trigger reservations_set_updated_at
before update on public.reservations
for each row execute function public.set_updated_at();

create trigger saved_routes_set_updated_at
before update on public.saved_routes
for each row execute function public.set_updated_at();

create trigger transit_sessions_set_updated_at
before update on public.transit_sessions
for each row execute function public.set_updated_at();

create trigger departure_alerts_set_updated_at
before update on public.departure_alerts
for each row execute function public.set_updated_at();

create trigger notification_deliveries_set_updated_at
before update on public.notification_deliveries
for each row execute function public.set_updated_at();

alter table public.user_devices enable row level security;
alter table public.trip_invitations enable row level security;
alter table public.reservations enable row level security;
alter table public.saved_routes enable row level security;
alter table public.transit_sessions enable row level security;
alter table public.departure_alerts enable row level security;
alter table public.notification_deliveries enable row level security;

create policy "Users can read their devices"
on public.user_devices for select
to authenticated
using (user_id = auth.uid());

create policy "Users can register their devices"
on public.user_devices for insert
to authenticated
with check (user_id = auth.uid());

create policy "Users can update their devices"
on public.user_devices for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "Users can delete their devices"
on public.user_devices for delete
to authenticated
using (user_id = auth.uid());

create policy "Owners and invitees can read invitations"
on public.trip_invitations for select
to authenticated
using (
  public.is_trip_owner(trip_id)
  or lower(invitee_email) = lower(coalesce(auth.jwt() ->> 'email', ''))
);

create policy "Owners can create invitations"
on public.trip_invitations for insert
to authenticated
with check (public.is_trip_owner(trip_id) and invited_by = auth.uid());

create policy "Owners can update invitations"
on public.trip_invitations for update
to authenticated
using (public.is_trip_owner(trip_id))
with check (public.is_trip_owner(trip_id));

create policy "Owners can delete invitations"
on public.trip_invitations for delete
to authenticated
using (public.is_trip_owner(trip_id));

create policy "Members can read reservations"
on public.reservations for select
to authenticated
using (public.is_trip_member(trip_id));

create policy "Editors can create reservations"
on public.reservations for insert
to authenticated
with check (public.can_edit_trip(trip_id) and created_by = auth.uid());

create policy "Editors can update reservations"
on public.reservations for update
to authenticated
using (public.can_edit_trip(trip_id))
with check (public.can_edit_trip(trip_id));

create policy "Editors can delete reservations"
on public.reservations for delete
to authenticated
using (public.can_edit_trip(trip_id));

create policy "Members can read saved routes"
on public.saved_routes for select
to authenticated
using (public.is_trip_member(trip_id));

create policy "Editors can create saved routes"
on public.saved_routes for insert
to authenticated
with check (public.can_edit_trip(trip_id) and created_by = auth.uid());

create policy "Editors can update saved routes"
on public.saved_routes for update
to authenticated
using (public.can_edit_trip(trip_id))
with check (public.can_edit_trip(trip_id));

create policy "Editors can delete saved routes"
on public.saved_routes for delete
to authenticated
using (public.can_edit_trip(trip_id));

create policy "Members can read transit sessions"
on public.transit_sessions for select
to authenticated
using (public.is_trip_member(trip_id));

create policy "Members can create their transit sessions"
on public.transit_sessions for insert
to authenticated
with check (public.is_trip_member(trip_id) and user_id = auth.uid());

create policy "Users can update their transit sessions"
on public.transit_sessions for update
to authenticated
using (public.is_trip_member(trip_id) and user_id = auth.uid())
with check (public.is_trip_member(trip_id) and user_id = auth.uid());

create policy "Users can delete their transit sessions"
on public.transit_sessions for delete
to authenticated
using (public.is_trip_member(trip_id) and user_id = auth.uid());

create policy "Users can read their departure alerts"
on public.departure_alerts for select
to authenticated
using (user_id = auth.uid() and public.is_trip_member(trip_id));

create policy "Users can create their departure alerts"
on public.departure_alerts for insert
to authenticated
with check (user_id = auth.uid() and public.is_trip_member(trip_id));

create policy "Users can update their departure alerts"
on public.departure_alerts for update
to authenticated
using (user_id = auth.uid() and public.is_trip_member(trip_id))
with check (user_id = auth.uid() and public.is_trip_member(trip_id));

create policy "Users can delete their departure alerts"
on public.departure_alerts for delete
to authenticated
using (user_id = auth.uid() and public.is_trip_member(trip_id));

create policy "Users can read their notification deliveries"
on public.notification_deliveries for select
to authenticated
using (
  user_id = auth.uid()
);

revoke all on public.notification_deliveries from anon, authenticated;
grant usage on schema public to authenticated;
grant select, insert, update, delete
  on public.user_devices,
     public.trip_invitations,
     public.reservations,
     public.saved_routes,
     public.transit_sessions,
     public.departure_alerts
  to authenticated;
grant select on public.notification_deliveries to authenticated;
