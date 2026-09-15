# Travel Home screen flow

The labels on each arrow are the button or tappable UI that triggers the
transition.

```mermaid
flowchart LR
    Home[01 Travel Home]
    Compare[02 Route Comparison]
    Taxi[03 Uber Confirmation]
    Uber[External: Uber App]
    Driver[04 Driver Card]
    Transit[05 Transit Routes]
    Guide[06 Live Transit Guide]
    Itinerary[07 Itinerary]
    Place[08 Place Detail]
    Profile[09 Profile & Setup]

    Home -->|Plan next move / route card| Compare
    Home -->|Prepare an Uber| Taxi
    Home -->|View itinerary| Itinerary
    Home -->|Profile icon| Profile
    Compare -->|Uber Taxi| Taxi
    Compare -->|Public transit| Transit
    Taxi -->|Open Uber| Uber
    Taxi -->|Show to driver| Driver
    Transit -->|Start guidance| Guide
    Itinerary -->|Select place| Place
```

## Navigation rules

| Source | Button | Destination | Type |
|---|---|---|---|
| Travel Home | Plan next move / route card | Route Comparison | Internal |
| Travel Home | Prepare an Uber | Uber Confirmation | Internal |
| Travel Home | View itinerary | Itinerary | Internal |
| Travel Home | Profile icon | Profile & Setup | Internal |
| Route Comparison | Uber Taxi | Uber Confirmation | Internal |
| Route Comparison | Public transit | Transit Routes | Internal |
| Uber Confirmation | Open Uber | Uber App | External deep link |
| Uber Confirmation | Show to driver | Driver Card | Internal |
| Transit Routes | Start guidance | Live Transit Guide | Internal |
| Itinerary | Select place | Place Detail | Internal |
