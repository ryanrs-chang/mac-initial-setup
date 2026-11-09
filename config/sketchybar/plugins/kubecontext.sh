#!/bin/sh

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Kubernetes context plugin for SketchyBar

KUBE_BLUE="0xff326ce5"
KUBE_BLUE_DIM="0xff888888"
KUBE_GREEN="0xff73daca"
KUBE_RED="0xfff7768e"

get_current_context() {
    if command -v kubectl >/dev/null 2>&1; then
        kubectl config current-context 2>/dev/null || echo "No context"
    else
        echo "N/A"
    fi
}

get_all_contexts() {
    if command -v kubectl >/dev/null 2>&1; then
        kubectl config get-contexts -o name 2>/dev/null
    fi
}

update_display() {
    CURRENT_CONTEXT=$(get_current_context)

    # Truncate long context names - show last 15 characters
    if [ ${#CURRENT_CONTEXT} -gt 15 ]; then
        DISPLAY_CONTEXT="…${CURRENT_CONTEXT: -15}"
    else
        DISPLAY_CONTEXT="$CURRENT_CONTEXT"
    fi

    sketchybar --set "$NAME" label="$DISPLAY_CONTEXT"
}

create_popup_items() {
    # Clear existing popup items
    sketchybar --remove '/kubecontext\.popup\..*/' 2>/dev/null

    CONTEXTS=$(get_all_contexts)
    CURRENT=$(get_current_context)

    if [ -z "$CONTEXTS" ]; then
        sketchybar --add item kubecontext.popup.none popup.kubecontext \
                   --set kubecontext.popup.none \
                        icon=󰀦 \
                        icon.font="Hack Nerd Font:Bold:14.0" \
                        icon.color="$KUBE_RED" \
                        icon.padding_left=10 \
                        icon.padding_right=6 \
                        label="No contexts available" \
                        label.font="Hack Nerd Font:Bold:13.0" \
                        label.color="$KUBE_RED" \
                        label.padding_right=10
        return
    fi

    echo "$CONTEXTS" > /tmp/kube_contexts.tmp
    while IFS= read -r context; do
        [ -z "$context" ] && continue

        ITEM_NAME="kubecontext.popup.$(echo "$context" | sed 's/[^a-zA-Z0-9]/_/g')"

        if [ "$context" = "$CURRENT" ]; then
            ICON=󰄬
            ICON_COLOR="$KUBE_GREEN"
            LABEL_COLOR="$KUBE_GREEN"
        else
            ICON=󰧞
            ICON_COLOR="$KUBE_BLUE_DIM"
            LABEL_COLOR="0xffc0c0c0"
        fi

        sketchybar --add item "$ITEM_NAME" popup.kubecontext \
                   --set "$ITEM_NAME" \
                        icon="$ICON" \
                        icon.font="Hack Nerd Font:Bold:14.0" \
                        icon.color="$ICON_COLOR" \
                        icon.padding_left=10 \
                        icon.padding_right=6 \
                        label="$context" \
                        label.font="Hack Nerd Font:Bold:13.0" \
                        label.color="$LABEL_COLOR" \
                        label.padding_right=10
    done < /tmp/kube_contexts.tmp
    rm -f /tmp/kube_contexts.tmp
}

if [ "$1" = "toggle_popup" ]; then
    sketchybar --set kubecontext popup.drawing=toggle
    create_popup_items
elif [ "$SENDER" = "mouse.exited.global" ] || [ "$SENDER" = "front_app_switched" ] || [ "$SENDER" = "space_change" ]; then
    sketchybar --set kubecontext popup.drawing=off
else
    update_display
fi
