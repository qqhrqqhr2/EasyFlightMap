# Easy Flight Map User Guide

Version: 0.6.0

## Installation

1. Extract the release ZIP.
2. Place the `EasyFlightMap` folder in your game's `Interface/AddOns` directory.
3. Confirm that `Interface/AddOns/EasyFlightMap/EasyFlightMap.toc` exists. Avoid nesting two `EasyFlightMap` folders inside each other.
4. Restart the game and enable the addon at the character selection screen.

This guide covers the package targeting interface version 16001.

## Language

The addon selects its UI language automatically. Korean clients (`koKR`) use Korean; all other client languages use English. Destination and area names are supplied by the game client; the addon does not independently translate those names. The introduction and user guide are provided in Korean and English.

## Opening the map and flying

Talk to a flight master to open the dedicated map. The conversation dialog is skipped by default. Hold Shift while talking if you want to see the dialog.

Labels show the destination, area, fare, and travel time. Hover over a marker or label to highlight the selected marker, label, and connecting line. Confirmed flight routes are shown with a gold line and moving lights.

## Destination list and favorites

A destination list appears to the right of the map. Toggle it with the list button in the title bar or `/efm list`.

- **Search**: Type part of a destination name to narrow the list; points that don't match are dimmed on the map. Press Enter to fly to the first reachable result.
- **Sort**: Use the Name, Time and Fare tabs.
- **Favorites**: Click the star at the start of a row. Favorites stay at the top of the list and get a star on their map label.
- Hover a row to highlight its route on the map; click it to fly.

## Flying

Click a reachable destination to fly. To review the destination, fare, and time before departure, open `/efm config` and enable **Confirm before flying**. Then click **Fly** in the confirmation dialog to depart. Confirmation is disabled by default. If the fare changes while the dialog is open, you must confirm the updated fare again.

## Reading fares and times

| Display | Meaning |
| --- | --- |
| Gold, silver, and copper icons with numbers | Current fare confirmed from the game |
| Free | A reachable route with a confirmed fare of zero |
| Unknown | The current fare could not be confirmed |
| A time such as ~1m 30s | Estimated time based on route distances and flight speed |
| A time without ~ | Actual time recorded after completing that route |
| Not recorded | No actual recording or sufficient segment data for an estimate |
| Flight path not discovered | A destination identified as undiscovered by the game |
| No connected flight path | No connected route from the current location could be confirmed |

Estimates may differ from actual travel times. Completing a flight saves its travel time. Early landing is excluded from time recording and flight speed learning. Unknown fares and times are not treated as free or zero seconds.

## Controls

- **Drag the window**: Move the map window.
- **Ctrl + Mouse Wheel**: Resize the map window.
- **Drag the flight timer bar**: Move the remaining time bar.
- **Show default flight map**: A button in the gear settings window that switches to the game's default flight map.
- **Remaining time bar**: Shows the remaining time and local arrival time while flying.

Labels are placed inside the map and avoid covering flight markers. Some labels may be hidden when destinations are too crowded. Hover over a marker to view its details in that case.

## Settings

Enter `/efm config` in chat to open settings.

| Setting | Purpose |
| --- | --- |
| Use the Easy Flight Map window | Enable or disable the dedicated map |
| Skip the dialog and open the map directly | Skip the flight master's conversation dialog |
| Show destination name, cost and time | Display labels on the map |
| Zoom to flight points | Zoom to the area containing flight markers; off by default |
| Show unreachable points | Display undiscovered and unconnected destinations |
| Show destination list | Searchable, sortable list with favorites next to the map |
| Pulse effect on your location | Soft rings spreading from your current location |
| Window size, transparency, and text size | Adjust the display |
| Confirm before flying | Review the destination and fare before departure |
| Show remaining flight time bar | Display the flight timer |
| Arrival alert | Play a sound and flash the taskbar on arrival |

## Commands

You can use `/easyflightmap` instead of `/efm`. The Korean alias `/비행지도` is also available.

| Command | Action |
| --- | --- |
| `/efm` | Show help and the current enabled state |
| `/efm config` | Open settings |
| `/efm on` / `/efm off` | Enable or disable the dedicated map |
| `/efm skip` | Toggle skipping the flight master dialog |
| `/efm labels` | Toggle destination labels |
| `/efm crop` | Toggle zooming to flight points |
| `/efm all` | Toggle undiscovered and unconnected destinations |
| `/efm list` | Toggle the destination list |
| `/efm scale 80` | Set window size to 80%; range: 50–120% |
| `/efm alpha 20` | Set transparency to 20%; range: 0–70% |
| `/efm bar` | Toggle the remaining time bar |
| `/efm alert` | Toggle arrival alerts |
| `/efm reset` | Reset map and timer bar positions and map size |
| `/efm donate` | Show the donation link |

`/efm reset` does not delete recorded flight times. Flight confirmation is configured in the settings window.

## Troubleshooting

**If the map is cropped or text is too large**, reduce window and text sizes and turn off **Zoom to flight points**. Use `/efm reset` if the window has moved off screen.

**If the time says Not recorded**, the route lacks sufficient data for an estimate. Completing the flight records its actual time.

**To use the default map**, click **Show default flight map** in the gear settings window or enter `/efm off`.

**When reporting an issue**, include the addon version, client version, faction, departure and destination, error message, and a screenshot.
