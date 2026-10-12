-- An owner must be able to read a newly inserted trip immediately, including
-- the row returned by INSERT ... RETURNING before membership-based reads run.
create policy "Owners can read trips"
on public.trips for select
to authenticated
using (owner_id = auth.uid());
