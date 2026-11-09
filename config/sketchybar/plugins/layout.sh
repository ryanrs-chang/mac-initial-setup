#!/bin/sh

# Show the AeroSpace layout of the focused window as "[root] › [parent] N".
# - layout       : focused window's parent container layout (or floating / fullscreen)
# - layout_root  : workspace root layout, shown only when the window is nested
# - layout_sep   : "›" between the two, shown only when nested
# - layout_count : number of windows on the focused workspace
# Icons live in $CONFIG_DIR/icons/layout/<state>.png (sources: <state>.svg).
# Triggered by: aerospace_layout_change (from aerospace.toml), aerospace_workspace_change,
# front_app_switched.

ICON_DIR="$CONFIG_DIR/icons/layout"

hide_all() {
  sketchybar --set layout drawing=off --set layout_root drawing=off \
             --set layout_sep drawing=off --set layout_count drawing=off
}

if ! pgrep -x AeroSpace >/dev/null 2>&1; then
  hide_all
  exit 0
fi

INFO=$(aerospace list-windows --focused --format '%{window-is-fullscreen} %{window-parent-container-layout}' 2>/dev/null)
if [ -z "$INFO" ]; then
  hide_all
  exit 0
fi

FULLSCREEN="${INFO%% *}"
LAYOUT="${INFO#* }"
ROOT=$(aerospace list-workspaces --focused --format '%{workspace-root-container-layout}' 2>/dev/null)
COUNT=$(aerospace list-windows --workspace focused --count 2>/dev/null)

# Fullscreen is a per-window flag, separate from the container layout
[ "$FULLSCREEN" = "true" ] && LAYOUT="fullscreen"

# Nested = parent orientation differs from root orientation. Normalization forces nested
# containers to the opposite orientation, so this catches one level of join / move-out.
NESTED=false
case "$LAYOUT" in
  h_*|v_*) [ "${LAYOUT%%_*}" != "${ROOT%%_*}" ] && NESTED=true ;;
esac

ICON="$ICON_DIR/$LAYOUT.png"
if [ -f "$ICON" ]; then
  sketchybar --set layout drawing=on background.image="$ICON"
else
  sketchybar --set layout drawing=off
fi

if [ "$NESTED" = "true" ] && [ -f "$ICON_DIR/$ROOT.png" ]; then
  sketchybar --set layout_root drawing=on background.image="$ICON_DIR/$ROOT.png" \
             --set layout_sep drawing=on
else
  sketchybar --set layout_root drawing=off --set layout_sep drawing=off
fi

if [ -n "$COUNT" ] && [ "$COUNT" -gt 1 ]; then
  sketchybar --set layout_count drawing=on label="$COUNT"
else
  sketchybar --set layout_count drawing=off
fi
