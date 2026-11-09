#!/bin/zsh

# Show "App · window title" for the focused window so multiple windows of the
# same app (e.g. several Zed projects) can be told apart. Long titles are truncated.

MAX_CHARS=40

IFS=$'\t' read -r APP TITLE <<< "$(aerospace list-windows --focused --format '%{app-name}%{tab}%{window-title}' 2>/dev/null)"

# Fall back to the event payload when AeroSpace has no focused window (e.g. empty workspace)
[ -z "$APP" ] && APP="$INFO"

if [ -z "$TITLE" ] || [ "$TITLE" = "$APP" ]; then
  LABEL="$APP"
else
  LABEL="$APP · $TITLE"
fi

if (( ${#LABEL} > MAX_CHARS )); then
  LABEL="${LABEL[1,MAX_CHARS-1]}…"
fi

sketchybar --set "$NAME" label="$LABEL"
