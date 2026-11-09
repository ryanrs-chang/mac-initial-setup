#!/bin/sh

# Spotify dock plugin for SketchyBar
# Inline dock style: controls slide in on hover

SPOTIFY_CONTROLS="spotify.shuffle spotify.back spotify.play spotify.next spotify.repeat"

next() {
  osascript -e 'tell application "Spotify" to play next track'
}

back() {
  osascript -e 'tell application "Spotify" to play previous track'
}

play() {
  osascript -e 'tell application "Spotify" to playpause'
}

shuffle() {
  SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
  if [ "$SHUFFLE" = "false" ]; then
    sketchybar --set spotify.shuffle icon.highlight=on
    osascript -e 'tell application "Spotify" to set shuffling to true'
  else
    sketchybar --set spotify.shuffle icon.highlight=off
    osascript -e 'tell application "Spotify" to set shuffling to false'
  fi
}

repeat() {
  REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
  if [ "$REPEAT" = "false" ]; then
    sketchybar --set spotify.repeat icon.highlight=on
    osascript -e 'tell application "Spotify" to set repeating to true'
  else
    sketchybar --set spotify.repeat icon.highlight=off
    osascript -e 'tell application "Spotify" to set repeating to false'
  fi
}

show_controls() {
  args=()
  for item in $SPOTIFY_CONTROLS; do
    args+=(--set "$item" drawing=on)
  done
  sketchybar "${args[@]}"
}

hide_controls() {
  args=()
  for item in $SPOTIFY_CONTROLS; do
    args+=(--set "$item" drawing=off)
  done
  sketchybar "${args[@]}"
}

update() {
  # Check if Spotify is running
  if ! pgrep -x "Spotify" > /dev/null; then
    sketchybar --set spotify.anchor drawing=off
    hide_controls
    return
  fi

  PLAYING=1
  # If INFO is available (from spotify_change event), use it
  if [ -n "$INFO" ] && [ "$(echo "$INFO" | jq -r '.["Player State"]')" = "Playing" ]; then
    PLAYING=0
    TRACK="$(echo "$INFO" | jq -r .Name | cut -c1-25)"
    ARTIST="$(echo "$INFO" | jq -r .Artist | cut -c1-25)"
  # Otherwise query Spotify directly (for periodic updates)
  elif [ -z "$INFO" ]; then
    STATE=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)
    if [ "$STATE" = "playing" ]; then
      PLAYING=0
      TRACK=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null | cut -c1-25)
      ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null | cut -c1-25)
    fi
  fi

  if [ $PLAYING -eq 0 ]; then
    SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
    REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
  fi

  args=()
  if [ $PLAYING -eq 0 ]; then
    if [ -n "$ARTIST" ] && [ "$ARTIST" != "" ]; then
      args+=(--set spotify.anchor label="$TRACK - $ARTIST" drawing=on)
    else
      args+=(--set spotify.anchor label="$TRACK" drawing=on)
    fi
    args+=(--set spotify.play icon=󰏤)
    args+=(--set spotify.shuffle icon.highlight=$SHUFFLE)
    args+=(--set spotify.repeat icon.highlight=$REPEAT)
  else
    args+=(--set spotify.anchor drawing=off)
    args+=(--set spotify.play icon=󰐊)
    hide_controls
  fi
  sketchybar -m "${args[@]}"
}

mouse_clicked() {
  case "$NAME" in
    "spotify.next") next ;;
    "spotify.back") back ;;
    "spotify.play") play ;;
    "spotify.shuffle") shuffle ;;
    "spotify.repeat") repeat ;;
    *) exit ;;
  esac
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked ;;
  "mouse.entered") show_controls ;;
  "mouse.exited.global") hide_controls ;;
  "forced") exit ;;
  *) update ;;
esac
