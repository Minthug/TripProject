# NextMate

**Live UI gallery:** https://minthug.github.io/TripProject/

## Project structure

```text
lib/
  main.dart             App entry point and gallery assembly
  auth/                Session gate and sign-in screens
  trips/               Signed-in trip and itinerary workspace
  ui/
    gallery/            Screen selector and flow map
    screens/            One file per preview screen or home variant
    shared/             Preview colors, widgets, and navigation helpers
  backend/
    backend.dart        Supabase initialization and repository access
    repositories.dart   Auth and database operations
test/
  widget_test.dart      Gallery interaction tests
  auth/                 Sign-in and session-routing tests
  backend/              Repository tests
supabase/
  migrations/           Database schema and policies
  tests/                Database access tests
docs/                   Product and backend notes
```

The preview screens use Dart `part` files so their existing shared private
widgets and test imports continue to work. Open `lib/ui/screens/` to find an
individual screen; `lib/main.dart` now only starts and assembles the gallery.

NextMate is a Flutter prototype for an itinerary-aware travel companion. Without
Supabase build settings it opens a design gallery; with them it opens the login
flow and, after authentication, a database-backed trip planner. The
gallery includes a launch screen, trip setup, and three alternatives for the
in-trip home screen:

- **ON · First-run onboarding** — introduces features and prepares language, location, and Uber.
- **00 · Splash** — introduces the NextMate brand while app state loads.
- **01 · Plan trip** — selects travel dates and the traveler's accommodation.
- **02 · Stay planner** — splits nights across stays and adds nearby landmarks.
- **03 · Add stay** — searches a stay, adjusts the entrance pin, and assigns nights.
- **04 · Trip overview** — summarizes every date, stay, move day, open period, and conflict.
- **05 · Day plan** — keeps a flexible place order while checking opening hours.
- **06 · Add place** — searches a map and checks date-specific opening information.
- **07 · Place detail** — verifies the entrance, reservation, local address, and itinerary state.
- **08 · Transit guide** — gives tourists step-by-step station and boarding help.
- **09 · Route comparison** — compares time and cost while surfacing an unavailable Uber app.
- **10 · Taxi handoff** — confirms the route or offers installation when Uber is missing.
- **11 · Driver card** — shows the verified destination in the driver's language.
- **12 · Departure alert** — manages leave-now, reminder, delay, and skip states.
- **13 · Profile & settings** — configures languages, permissions, Uber, and travel defaults.
- **A · Next move** — provides the four-tab travel app shell and next departure.
- **B · Day timeline** — emphasizes the itinerary and current progress.
- **C · Live map** — emphasizes location and route comparison.
- **ST · Recovery states** — previews loading, offline, permission, service, and stale-data recovery.
- **AU · Sign in** — previews Google, Apple, and email sign-in or registration.

## Run the design gallery

```sh
flutter run -d chrome
```

On a wide browser window, all twenty mobile frames appear side by side. On a
narrow window or device, use the ON/00/01/02/03/04/05/06/07/08/09/10/11/12/13/A/B/C/ST/AU selector in the header.
Use the `A−` and `A+` controls to preview every screen at 100%, 115%, or
130% text size. The gallery starts at the more readable 115% setting.
The Uber screens use the normal installed state by default. Append
`&uber=missing` to the URL to preview the same screens after a failed app check.

Use the **Flow map** tab to see which button connects each internal screen or
external app. The same map is documented in [`docs/screen-flow.md`](docs/screen-flow.md).
The flow board can also be opened directly with `/?view=flow`.

## Product decisions

- **Launch area:** travel within South Korea
- **Place information:** domestic place API (to be connected), with tourism data as enrichment
- **Routes:** domestic transit, walking, and road APIs (to be connected)
- **Mobile framework:** Flutter
- **Backend platform:** Supabase
- **Database:** PostgreSQL + PostGIS
- **Uber:** deferred until the domestic trip basics work

The product baseline, accommodation data model, and multi-stay rules are
documented in [`docs/product-spec.md`](docs/product-spec.md).
The backend structure, initial tables, and access model are documented in
[`docs/backend-architecture.md`](docs/backend-architecture.md).
Google·Apple OAuth and session routing setup is documented in
[`docs/auth-setup.md`](docs/auth-setup.md).
