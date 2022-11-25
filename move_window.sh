#!/usr/bin/env bash

space_type=$(yabai -m query --spaces --space | jq -r .type)

if [ "$space_type" = "stack" ]; then
  if [ "$1" = "next" ]; then
    yabai -m window --focus stack.next || yabai -m window --focus stack.first
  else
    yabai -m window --focus stack.prev || yabai -m window --focus stack.last
  fi
else
  if [ "$1" = "next" ]; then
    yabai -m window --focus south
  else
    yabai -m window --focus north
  fi
fi
