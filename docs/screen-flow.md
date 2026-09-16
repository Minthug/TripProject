# Travel Home screen flow

The labels on each arrow are the button or tappable UI that triggers the
transition.

```mermaid
flowchart LR
    Splash[00 NextMate Splash]
    Setup[01–02 Stay-based Planner]
    AddStay[03 Add Stay Map]
    Home[01 Travel Home]
    Compare[02 Route Comparison]
    Taxi[03 Uber Handoff Sheet]
    Uber[External: Uber App]
    Driver[04 Driver Card]
    Transit[05 Transit Routes]
    Guide[06 Live Transit Guide]
    Itinerary[07 Itinerary]
    Place[08 Place Detail]
    Profile[09 Profile & Setup]

    Splash -->|Active trip| Home
    Splash -->|New trip| Setup
    Setup -->|Build itinerary| Itinerary
    Setup -->|+ Stay| AddStay
    AddStay -->|Add stay| Setup
    Home -->|Plan next move / route card| Compare
    Home -->|Prepare an Uber| Taxi
    Home -->|View itinerary| Itinerary
    Home -->|Profile icon| Profile
    Compare -->|Uber Taxi| Taxi
    Compare -->|Public transit| Transit
    Taxi -->|Continue in Uber| Uber
    Taxi -->|Show to driver| Driver
    Transit -->|Start guidance| Guide
    Itinerary -->|Select place| Place
```

## Navigation rules

| Source | Button | Destination | Type |
|---|---|---|---|
| NextMate Splash | Active trip detected | Travel Home | Automatic |
| NextMate Splash | New trip | Stay-based Planner | Internal |
| Stay-based Planner | Build itinerary | Itinerary | Internal |
| Stay-based Planner | + Stay | Add Stay Map | Internal |
| Add Stay Map | Add stay | Stay-based Planner | Internal |
| Travel Home | Plan next move / route card | Route Comparison | Internal |
| Travel Home | Prepare an Uber | Uber Handoff Sheet | Bottom sheet |
| Travel Home | View itinerary | Itinerary | Internal |
| Travel Home | Profile icon | Profile & Setup | Internal |
| Route Comparison | Uber Taxi | Uber Handoff Sheet | Bottom sheet |
| Route Comparison | Public transit | Transit Routes | Internal |
| Uber Handoff Sheet | Continue in Uber | Uber App | External deep link |
| Uber Handoff Sheet | Driver card | Driver Card | Internal |
| Transit Routes | Start guidance | Live Transit Guide | Internal |
| Itinerary | Select place | Place Detail | Internal |

The Driver Card prioritizes a large local-language request, official local
address, and entrance name. A smaller back-translation lets the traveler
verify the message before showing it to the driver.

The Stay-based Planner assigns every night to an accommodation, flags move
days, and recommends landmarks using the selected stay as the planning anchor.
