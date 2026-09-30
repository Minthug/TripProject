create extension if not exists postgis with schema extensions;

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  avatar_url text,
  user_language text not null default 'en',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_user_language_not_blank check (btrim(user_language) <> '')
);

create table public.user_preferences (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  destination_language text,
  default_transport_mode text not null default 'transit',
  location_permission_status text not null default 'unknown',
  uber_install_status text not null default 'unknown',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_preferences_transport_mode_valid
    check (default_transport_mode in ('transit', 'walking', 'uber')),
  constraint user_preferences_location_permission_valid
    check (location_permission_status in ('unknown', 'denied', 'while_in_use', 'always')),
  constraint user_preferences_uber_install_status_valid
    check (uber_install_status in ('unknown', 'installed', 'missing'))
);

create table public.trips (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete restrict,
  title text not null,
  destination_name text not null,
  start_date date not null,
  end_date date not null,
  time_zone_id text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint trips_title_not_blank check (btrim(title) <> ''),
  constraint trips_destination_not_blank check (btrim(destination_name) <> ''),
  constraint trips_time_zone_not_blank check (btrim(time_zone_id) <> ''),
  constraint trips_date_range_valid check (end_date >= start_date)
);

create table public.trip_members (
  trip_id uuid not null references public.trips (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  role text not null,
  joined_at timestamptz not null default now(),
  primary key (trip_id, user_id),
  constraint trip_members_role_valid check (role in ('owner', 'editor', 'viewer'))
);

create table public.stays (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips (id) on delete cascade,
  google_place_id text,
  display_name text not null,
  local_name text,
  formatted_address text not null,
  latitude double precision not null,
  longitude double precision not null,
  entrance_latitude double precision,
  entrance_longitude double precision,
  location extensions.geography(point, 4326)
    generated always as (
      extensions.st_setsrid(extensions.st_makepoint(longitude, latitude), 4326)::extensions.geography
    ) stored,
  entrance_location extensions.geography(point, 4326)
    generated always as (
      case
        when entrance_latitude is null then null
        else extensions.st_setsrid(
          extensions.st_makepoint(entrance_longitude, entrance_latitude),
          4326
        )::extensions.geography
      end
    ) stored,
  check_in_at timestamptz not null,
  check_out_at timestamptz not null,
  time_zone_id text not null,
  luggage_storage text not null default 'unknown',
  location_source text not null default 'google_places',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint stays_display_name_not_blank check (btrim(display_name) <> ''),
  constraint stays_address_not_blank check (btrim(formatted_address) <> ''),
  constraint stays_latitude_valid check (latitude between -90 and 90),
  constraint stays_longitude_valid check (longitude between -180 and 180),
  constraint stays_entrance_coordinates_complete check (
    (entrance_latitude is null) = (entrance_longitude is null)
  ),
  constraint stays_entrance_latitude_valid check (
    entrance_latitude is null or entrance_latitude between -90 and 90
  ),
  constraint stays_entrance_longitude_valid check (
    entrance_longitude is null or entrance_longitude between -180 and 180
  ),
  constraint stays_date_range_valid check (check_out_at > check_in_at),
  constraint stays_luggage_storage_valid
    check (luggage_storage in ('unknown', 'available', 'unavailable')),
  constraint stays_location_source_valid
    check (location_source in ('google_places', 'manual_pin'))
);

create table public.places (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips (id) on delete cascade,
  google_place_id text,
  display_name text not null,
  local_name text,
  formatted_address text not null,
  visitor_entrance_name text,
  latitude double precision not null,
  longitude double precision not null,
  entrance_latitude double precision,
  entrance_longitude double precision,
  location extensions.geography(point, 4326)
    generated always as (
      extensions.st_setsrid(extensions.st_makepoint(longitude, latitude), 4326)::extensions.geography
    ) stored,
  entrance_location extensions.geography(point, 4326)
    generated always as (
      case
        when entrance_latitude is null then null
        else extensions.st_setsrid(
          extensions.st_makepoint(entrance_longitude, entrance_latitude),
          4326
        )::extensions.geography
      end
    ) stored,
  location_source text not null default 'google_places',
  created_by uuid not null default auth.uid() references public.profiles (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint places_trip_and_id_unique unique (trip_id, id),
  constraint places_display_name_not_blank check (btrim(display_name) <> ''),
  constraint places_address_not_blank check (btrim(formatted_address) <> ''),
  constraint places_latitude_valid check (latitude between -90 and 90),
  constraint places_longitude_valid check (longitude between -180 and 180),
  constraint places_entrance_coordinates_complete check (
    (entrance_latitude is null) = (entrance_longitude is null)
  ),
  constraint places_entrance_latitude_valid check (
    entrance_latitude is null or entrance_latitude between -90 and 90
  ),
  constraint places_entrance_longitude_valid check (
    entrance_longitude is null or entrance_longitude between -180 and 180
  ),
  constraint places_location_source_valid
    check (location_source in ('google_places', 'manual_pin'))
);

create table public.itinerary_items (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips (id) on delete cascade,
  place_id uuid not null,
  scheduled_date date not null,
  position integer not null,
  fixed_start_at timestamptz,
  reservation_status text not null default 'none',
  progress_status text not null default 'planned',
  notes text,
  created_by uuid not null default auth.uid() references public.profiles (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint itinerary_items_place_in_trip
    foreign key (trip_id, place_id)
    references public.places (trip_id, id)
    on delete cascade,
  constraint itinerary_items_position_nonnegative check (position >= 0),
  constraint itinerary_items_reservation_status_valid check (
    reservation_status in ('none', 'required', 'recommended', 'walk_in', 'not_required')
  ),
  constraint itinerary_items_progress_status_valid check (
    progress_status in ('planned', 'in_progress', 'completed', 'skipped')
  ),
  constraint itinerary_items_date_position_unique
    unique (trip_id, scheduled_date, position)
    deferrable initially deferred
);

create index trip_members_user_id_idx on public.trip_members (user_id);
create index stays_trip_id_idx on public.stays (trip_id);
create index stays_location_idx on public.stays using gist (location);
create index places_trip_id_idx on public.places (trip_id);
create index places_google_place_id_idx on public.places (google_place_id)
  where google_place_id is not null;
create index places_location_idx on public.places using gist (location);
create index itinerary_items_trip_date_idx
  on public.itinerary_items (trip_id, scheduled_date, position);

create function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(
      nullif(new.raw_user_meta_data ->> 'display_name', ''),
      nullif(new.raw_user_meta_data ->> 'full_name', '')
    )
  )
  on conflict (id) do nothing;

  insert into public.user_preferences (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

create function public.add_trip_owner_membership()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.trip_members (trip_id, user_id, role)
  values (new.id, new.owner_id, 'owner');
  return new;
end;
$$;

create function public.prevent_trip_owner_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.owner_id <> old.owner_id then
    raise exception 'A trip owner cannot be changed directly';
  end if;
  return new;
end;
$$;

create function public.validate_itinerary_date()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (
    select 1
    from public.trips
    where id = new.trip_id
      and new.scheduled_date between start_date and end_date
  ) then
    raise exception 'The itinerary date must be within the trip dates';
  end if;
  return new;
end;
$$;

create function public.is_trip_member(target_trip_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.trip_members
    where trip_id = target_trip_id
      and user_id = auth.uid()
  );
$$;

create function public.can_edit_trip(target_trip_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.trip_members
    where trip_id = target_trip_id
      and user_id = auth.uid()
      and role in ('owner', 'editor')
  );
$$;

create function public.is_trip_owner(target_trip_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.trips
    where id = target_trip_id
      and owner_id = auth.uid()
  );
$$;

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create trigger user_preferences_set_updated_at
before update on public.user_preferences
for each row execute function public.set_updated_at();

create trigger trips_set_updated_at
before update on public.trips
for each row execute function public.set_updated_at();

create trigger stays_set_updated_at
before update on public.stays
for each row execute function public.set_updated_at();

create trigger places_set_updated_at
before update on public.places
for each row execute function public.set_updated_at();

create trigger itinerary_items_set_updated_at
before update on public.itinerary_items
for each row execute function public.set_updated_at();

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create trigger trips_add_owner_membership
after insert on public.trips
for each row execute function public.add_trip_owner_membership();

create trigger trips_prevent_owner_change
before update of owner_id on public.trips
for each row execute function public.prevent_trip_owner_change();

create trigger itinerary_items_validate_date
before insert or update of trip_id, scheduled_date on public.itinerary_items
for each row execute function public.validate_itinerary_date();

alter table public.profiles enable row level security;
alter table public.user_preferences enable row level security;
alter table public.trips enable row level security;
alter table public.trip_members enable row level security;
alter table public.stays enable row level security;
alter table public.places enable row level security;
alter table public.itinerary_items enable row level security;

create policy "Users can read their profile"
on public.profiles for select
to authenticated
using (id = auth.uid());

create policy "Users can update their profile"
on public.profiles for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

create policy "Users can read their preferences"
on public.user_preferences for select
to authenticated
using (user_id = auth.uid());

create policy "Users can update their preferences"
on public.user_preferences for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "Members can read trips"
on public.trips for select
to authenticated
using (public.is_trip_member(id));

create policy "Users can create trips"
on public.trips for insert
to authenticated
with check (owner_id = auth.uid());

create policy "Editors can update trips"
on public.trips for update
to authenticated
using (public.can_edit_trip(id))
with check (public.can_edit_trip(id));

create policy "Owners can delete trips"
on public.trips for delete
to authenticated
using (public.is_trip_owner(id));

create policy "Members can read memberships"
on public.trip_members for select
to authenticated
using (public.is_trip_member(trip_id));

create policy "Owners can add members"
on public.trip_members for insert
to authenticated
with check (
  public.is_trip_owner(trip_id)
  and role in ('editor', 'viewer')
);

create policy "Owners can update non-owner members"
on public.trip_members for update
to authenticated
using (public.is_trip_owner(trip_id) and role <> 'owner')
with check (public.is_trip_owner(trip_id) and role in ('editor', 'viewer'));

create policy "Owners can remove members or members can leave"
on public.trip_members for delete
to authenticated
using (
  role <> 'owner'
  and (public.is_trip_owner(trip_id) or user_id = auth.uid())
);

create policy "Members can read stays"
on public.stays for select
to authenticated
using (public.is_trip_member(trip_id));

create policy "Editors can create stays"
on public.stays for insert
to authenticated
with check (public.can_edit_trip(trip_id));

create policy "Editors can update stays"
on public.stays for update
to authenticated
using (public.can_edit_trip(trip_id))
with check (public.can_edit_trip(trip_id));

create policy "Editors can delete stays"
on public.stays for delete
to authenticated
using (public.can_edit_trip(trip_id));

create policy "Members can read places"
on public.places for select
to authenticated
using (public.is_trip_member(trip_id));

create policy "Editors can create places"
on public.places for insert
to authenticated
with check (public.can_edit_trip(trip_id) and created_by = auth.uid());

create policy "Editors can update places"
on public.places for update
to authenticated
using (public.can_edit_trip(trip_id))
with check (public.can_edit_trip(trip_id));

create policy "Editors can delete places"
on public.places for delete
to authenticated
using (public.can_edit_trip(trip_id));

create policy "Members can read itinerary items"
on public.itinerary_items for select
to authenticated
using (public.is_trip_member(trip_id));

create policy "Editors can create itinerary items"
on public.itinerary_items for insert
to authenticated
with check (public.can_edit_trip(trip_id) and created_by = auth.uid());

create policy "Editors can update itinerary items"
on public.itinerary_items for update
to authenticated
using (public.can_edit_trip(trip_id))
with check (public.can_edit_trip(trip_id));

create policy "Editors can delete itinerary items"
on public.itinerary_items for delete
to authenticated
using (public.can_edit_trip(trip_id));

revoke all on all tables in schema public from anon;
grant usage on schema public to authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;

revoke all on function public.set_updated_at() from public;
revoke all on function public.handle_new_user() from public;
revoke all on function public.add_trip_owner_membership() from public;
revoke all on function public.prevent_trip_owner_change() from public;
revoke all on function public.validate_itinerary_date() from public;
revoke all on function public.is_trip_member(uuid) from public;
revoke all on function public.can_edit_trip(uuid) from public;
revoke all on function public.is_trip_owner(uuid) from public;

grant execute on function public.is_trip_member(uuid) to authenticated;
grant execute on function public.can_edit_trip(uuid) to authenticated;
grant execute on function public.is_trip_owner(uuid) to authenticated;
