-- Let travelers plan an itinerary before a place-data provider is connected.
-- A draft has a name but no fabricated address or coordinates; routing stays
-- unavailable until it is resolved to a real location.
alter table public.places
  alter column formatted_address drop not null,
  alter column latitude drop not null,
  alter column longitude drop not null;

alter table public.places drop constraint places_address_not_blank;
alter table public.places add constraint places_address_not_blank
  check (formatted_address is null or btrim(formatted_address) <> '');

alter table public.places add constraint places_coordinates_complete
  check ((latitude is null) = (longitude is null));

alter table public.places drop constraint places_location_source_valid;
alter table public.places add constraint places_location_source_valid
  check (location_source in ('google_places', 'manual_pin', 'manual_entry'));

alter table public.places add constraint places_resolved_location_complete
  check (
    location_source = 'manual_entry'
    or (formatted_address is not null and latitude is not null and longitude is not null)
  );

-- The place and its first itinerary item must succeed or fail together.
create function public.add_draft_itinerary_item(
  p_trip_id uuid,
  p_scheduled_date date,
  p_display_name text,
  p_notes text default null
)
returns public.itinerary_items
language plpgsql
security invoker
set search_path = ''
as $$
declare
  new_place_id uuid;
  next_position integer;
  new_item public.itinerary_items;
begin
  if p_display_name is null or pg_catalog.length(pg_catalog.btrim(p_display_name)) < 1
     or pg_catalog.length(p_display_name) > 120 then
    raise check_violation using message = 'invalid place name';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(p_trip_id::text || p_scheduled_date::text, 0)
  );
  select coalesce(max(position) + 1, 0) into next_position
  from public.itinerary_items
  where trip_id = p_trip_id and scheduled_date = p_scheduled_date;

  insert into public.places (trip_id, display_name, location_source)
  values (p_trip_id, pg_catalog.btrim(p_display_name), 'manual_entry')
  returning id into new_place_id;

  insert into public.itinerary_items
    (trip_id, place_id, scheduled_date, position, notes)
  values (p_trip_id, new_place_id, p_scheduled_date, next_position,
    nullif(pg_catalog.btrim(p_notes), ''))
  returning * into new_item;

  return new_item;
end;
$$;

revoke all on function public.add_draft_itinerary_item(uuid, date, text, text)
  from public, anon;
grant execute on function public.add_draft_itinerary_item(uuid, date, text, text)
  to authenticated;

-- Changing travel dates must not silently strand existing itinerary items.
create function public.keep_itinerary_within_trip_dates()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if exists (
    select 1 from public.itinerary_items
    where trip_id = new.id
      and (scheduled_date < new.start_date or scheduled_date > new.end_date)
  ) then
    raise check_violation using message = 'trip dates exclude scheduled items';
  end if;
  return new;
end;
$$;

create trigger trips_keep_itinerary_within_dates
before update of start_date, end_date on public.trips
for each row execute function public.keep_itinerary_within_trip_dates();
