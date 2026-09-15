# TripProject

Flutter prototype for an itinerary-aware travel companion. The current build is
a design gallery with three alternatives for the in-trip home screen:

- **A · Next move** — emphasizes the next destination and departure time.
- **B · Day timeline** — emphasizes the itinerary and current progress.
- **C · Live map** — emphasizes location and route comparison.

## Run the design gallery

```sh
flutter run -d chrome
```

On a wide browser window, all three mobile frames appear side by side. On a
narrow window or device, use the A/B/C selector in the header.

Use the **Flow map** tab to see which button connects each internal screen or
external app. The same map is documented in [`docs/screen-flow.md`](docs/screen-flow.md).
The flow board can also be opened directly with `/?view=flow`.
