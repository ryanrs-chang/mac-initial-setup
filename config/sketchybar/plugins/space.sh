#!/bin/sh

# Extract space index from NAME (e.g., "space.1" -> "1")
SID="${NAME#space.}"

# FOCUSED_WORKSPACE comes from the aerospace_workspace_change event;
# fall back to querying AeroSpace on initial draw / forced updates.
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"
if [ "$SID" = "$FOCUSED" ]; then
  sketchybar --set "$NAME" background.drawing=on
else
  sketchybar --set "$NAME" background.drawing=off
fi
