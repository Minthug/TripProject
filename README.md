# NextMate

NextMate is a Flutter prototype for an itinerary-aware travel companion. The
current build is a design gallery with a launch screen, trip setup, and three alternatives
for the in-trip home screen:

- **00 · Splash** — introduces the NextMate brand while app state loads.
- **01 · Plan trip** — selects travel dates and the traveler's accommodation.
- **02 · Stay planner** — splits nights across stays and adds nearby landmarks.
- **03 · Add stay** — searches a stay, adjusts the entrance pin, and assigns nights.
- **04 · Day plan** — keeps a flexible place order while checking opening hours.
- **05 · Transit guide** — gives tourists step-by-step station and boarding help.
- **06 · Taxi handoff** — confirms pickup and destination before opening Uber.
- **07 · Driver card** — shows the verified destination in the driver's language.
- **A · Next move** — emphasizes the next destination and departure time.
- **B · Day timeline** — emphasizes the itinerary and current progress.
- **C · Live map** — emphasizes location and route comparison.

## Run the design gallery

```sh
flutter run -d chrome
```

On a wide browser window, all eleven mobile frames appear side by side. On a
narrow window or device, use the 00/01/02/03/04/05/06/07/A/B/C selector in the header.

Use the **Flow map** tab to see which button connects each internal screen or
external app. The same map is documented in [`docs/screen-flow.md`](docs/screen-flow.md).
The flow board can also be opened directly with `/?view=flow`.

## Product decisions

- **Map platform:** Google Maps Platform
- **Place search:** Google Places API
- **Mobile framework:** Flutter
- **Taxi handoff:** Uber deep link

The product baseline, accommodation data model, and multi-stay rules are
documented in [`docs/product-spec.md`](docs/product-spec.md).
