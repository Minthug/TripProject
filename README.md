# NextMate

NextMate is a Flutter prototype for an itinerary-aware travel companion. The
current build is a design gallery with a launch screen, trip setup, and three alternatives
for the in-trip home screen:

- **00 · Splash** — introduces the NextMate brand while app state loads.
- **01 · Plan trip** — selects travel dates and the traveler's accommodation.
- **02 · Taxi handoff** — confirms pickup and destination before opening Uber.
- **A · Next move** — emphasizes the next destination and departure time.
- **B · Day timeline** — emphasizes the itinerary and current progress.
- **C · Live map** — emphasizes location and route comparison.

## Run the design gallery

```sh
flutter run -d chrome
```

On a wide browser window, all six mobile frames appear side by side. On a
narrow window or device, use the 00/01/02/A/B/C selector in the header.

Use the **Flow map** tab to see which button connects each internal screen or
external app. The same map is documented in [`docs/screen-flow.md`](docs/screen-flow.md).
The flow board can also be opened directly with `/?view=flow`.
