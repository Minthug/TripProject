-- Keep the source and language alongside a resolved TourAPI location.
alter table public.places
  add column tour_api_content_id text,
  add column tour_api_language text;

alter table public.places drop constraint places_location_source_valid;
alter table public.places add constraint places_location_source_valid
  check (location_source in ('google_places', 'manual_pin', 'manual_entry', 'tour_api'));

alter table public.places add constraint places_tour_api_source_complete
  check (
    (location_source = 'tour_api' and tour_api_content_id is not null
      and tour_api_content_id ~ '^[0-9]{1,30}$'
      and tour_api_language is not null and tour_api_language in ('en', 'ja'))
    or (location_source <> 'tour_api' and tour_api_content_id is null
      and tour_api_language is null)
  );

create function public.add_tour_itinerary_item(
  p_trip_id uuid,
  p_scheduled_date date,
  p_content_id text,
  p_language text,
  p_display_name text,
  p_address text,
  p_latitude double precision,
  p_longitude double precision
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
  if p_content_id is null or p_content_id !~ '^[0-9]{1,30}$'
    or p_language is null or p_language not in ('en', 'ja')
    or p_display_name is null or pg_catalog.btrim(p_display_name) = ''
    or pg_catalog.length(p_display_name) > 120
    or p_address is null or pg_catalog.btrim(p_address) = ''
    or p_latitude is null or p_latitude not between -90 and 90
    or p_longitude is null or p_longitude not between -180 and 180 then
    raise check_violation using message = 'invalid TourAPI place';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(p_trip_id::text || p_scheduled_date::text, 0)
  );
  select coalesce(max(position) + 1, 0) into next_position
  from public.itinerary_items
  where trip_id = p_trip_id and scheduled_date = p_scheduled_date;

  insert into public.places (
    trip_id, display_name, formatted_address, latitude, longitude,
    location_source, tour_api_content_id, tour_api_language
  ) values (
    p_trip_id, pg_catalog.btrim(p_display_name), pg_catalog.btrim(p_address),
    p_latitude, p_longitude, 'tour_api', p_content_id, p_language
  ) returning id into new_place_id;

  insert into public.itinerary_items
    (trip_id, place_id, scheduled_date, position)
  values (p_trip_id, new_place_id, p_scheduled_date, next_position)
  returning * into new_item;
  return new_item;
end;
$$;

revoke all on function public.add_tour_itinerary_item(
  uuid, date, text, text, text, text, double precision, double precision
) from public, anon;
grant execute on function public.add_tour_itinerary_item(
  uuid, date, text, text, text, text, double precision, double precision
) to authenticated;
