#!/bin/sh

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# dbc port-forward plugin for SketchyBar
# Shows which DB port-forwards (dbc) are up; hidden when none are.
# Red when prod is forwarded, green otherwise. Popup entries stop a forward on click.

DBC_GREEN="0xff73daca"
DBC_RED="0xfff7768e"
DBC_DIM="0xffc0c0c0"

# "name port" for each forward whose state is up
up_forwards() {
    dbc ls 2>/dev/null | awk 'NR>1 && $3=="up" {print $1, $2}'
}

update_display() {
    UP=$(up_forwards)
    if [ -z "$UP" ]; then
        sketchybar --set "$NAME" drawing=off popup.drawing=off
        return
    fi

    LABEL=$(echo "$UP" | awk '{printf "%s%s", (NR>1?" · ":""), $1}')
    if echo "$UP" | grep -q '^prod '; then
        COLOR="$DBC_RED"; BG="0x40f7768e"
    else
        COLOR="$DBC_GREEN"; BG="0x3073daca"
    fi

    sketchybar --set "$NAME" drawing=on label="$LABEL" \
                    icon.color="$COLOR" label.color="$COLOR" background.color="$BG"
}

create_popup_items() {
    sketchybar --remove '/dbc\.popup\..*/' 2>/dev/null

    up_forwards | while read -r fwd port; do
        [ -z "$fwd" ] && continue
        if [ "$fwd" = "prod" ]; then C="$DBC_RED"; else C="$DBC_GREEN"; fi
        sketchybar --add item "dbc.popup.$fwd" popup.dbc \
                   --set "dbc.popup.$fwd" \
                        icon=󰅖 \
                        icon.font="Hack Nerd Font:Bold:14.0" \
                        icon.color="$C" \
                        icon.padding_left=10 \
                        icon.padding_right=6 \
                        label="$fwd  :$port  (click to stop)" \
                        label.font="Hack Nerd Font:Bold:13.0" \
                        label.color="$DBC_DIM" \
                        label.padding_right=10 \
                        click_script="dbc stop $fwd; sketchybar --set dbc popup.drawing=off"
    done
}

if [ "$1" = "toggle_popup" ]; then
    create_popup_items
    sketchybar --set dbc popup.drawing=toggle
elif [ "$SENDER" = "mouse.exited.global" ] || [ "$SENDER" = "front_app_switched" ] || [ "$SENDER" = "space_change" ]; then
    sketchybar --set dbc popup.drawing=off
else
    update_display
fi
