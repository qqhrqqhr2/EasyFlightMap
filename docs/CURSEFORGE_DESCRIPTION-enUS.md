# Easy Flight Map

**See destinations, fares, and flight times at a glance.**

Talk to a flight master to open a clean, dedicated flight map. Check each destination's name, area, fare, and travel time directly on the map, then hover over a destination to highlight its flight route.

## Features

- **Destination details on the map** — Labels display destination names, areas, fares, and flight times. Gold, silver, and copper icons make fares easy to read.
- **Animated route highlighting** — Hovering over a destination highlights its marker, label, connecting line, and flight route. Moving lights trace the route.
- **Labels inside the map** — Labels are positioned to avoid covering flight markers. The full map is shown by default.
- **Recorded flight times** — Completed flights save the actual travel time. Routes without a recorded time show an estimate when segment distance data is available.
- **Destination list and favorites** — Search destinations by name and sort by name, time or fare in a list beside the map. Starred favorites stay on top and are marked on the map.
- **Optional flight confirmation** — Enable a confirmation dialog to review the destination, fare, and time before taking off.
- **Remaining time and arrival alerts** — An optional flight timer bar and arrival alert help you track your trip.
- **Display settings** — Adjust window size, transparency, text size, labels, and the visibility of undiscovered or unconnected destinations.
- **Korean and English UI** — Korean clients use Korean; other client languages use English. Destination names come from the game client.

## Getting started

1. Install the addon and talk to a flight master.
2. Check the fare and time on the destination labels.
3. Hover over a marker or label to inspect the route.
4. Click a reachable destination to fly. To enable confirmation, open `/efm config` and turn on **Confirm before flying**.

Drag the window to move it, or use **Ctrl + Mouse Wheel** to change its size. Hold **Shift while talking to a flight master** to see the conversation dialog even when dialog skipping is enabled.

## Understanding the information

- **~…**: An estimated time based on route distances and flight speed. Actual flight time may differ.
- **Not recorded**: No recorded time or sufficient segment data is available.
- **Unknown**: The fare could not be confirmed from the game.
- **Flight path not discovered**: The game identifies this destination as undiscovered.
- **No connected flight path**: A connected route from your current location could not be confirmed.

Only completed flights are used to record travel times. Flights ended with early landing are excluded. If destinations are too crowded for every label to fit, hover over a marker to view its details.

## Compatibility

The current package targets interface version **16001**. Compatibility with other game client versions is not guaranteed.

## Support development

[Buy the developer a coffee](https://buymeacoffee.com/qqhrqqhr2)
