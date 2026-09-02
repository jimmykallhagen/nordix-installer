#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf
OUTPUT_FILE="$SCRIPT_DIR/../config/desktop.env.conf"
echo -ne "\e]10;${G_BASE_COLOR}\a"

clear
gum_spin_timer "Loading desktop environment options..."

OPTIONS=(
    "Niri with VanillaGreen Shell - Preconfigured, ready to use tilling window manager."
    "GNOME - Modern desktop environment, classic Linux style"
    ""
    "Server - Headless/No desktop environment"
)

while true; do
    clear
    gum_box "Desktop Environment"

    CHOICE=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose_no_limit "Press Space to select, Enter to confirm")
    if [[ -z "$CHOICE" ]]; then
        clear
        gum_box_sleep "Please select a desktop environment!" && true
        continue
    fi

    # Check mutual exclusion: server can't be chosen together with GNOME or Niri
    has_server=0
    has_gnome=0
    has_niri=0
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        case "$line" in
            "Server - Headless/No desktop environment") has_server=1 ;;
            "GNOME - Modern desktop environment, classic Linux style") has_gnome=1 ;;
            "Niri with VanillaGreen Shell - Preconfigured, ready to use tilling window manager.") has_niri=1 ;;
        esac
    done <<< "$CHOICE"

    if (( has_server && (has_gnome || has_niri) )); then
        clear
        gum_box_sleep "You can't select headless server together with GNOME or Niri!" && true
        continue
    fi

    # Determine DESKTOP_ENV from the first valid selection
    DESKTOP_ENV=""
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        case "$line" in
            "Niri with VanillaGreen Shell - Preconfigured, ready to use tilling window manager.")
                DESKTOP_ENV1=niri
                ;;
            "GNOME - Modern desktop environment, classic Linux style")
                DESKTOP_ENV2=gnome
                ;;
            "Server - Headless/No desktop environment")
                DESKTOP_ENV3=server
                ;;
        esac
        [[ -n "$DESKTOP_ENV" ]] && break
    done <<< "$CHOICE"

    if gum_confirm "Confirm desktop environment: $CHOICE?"; then
        echo "DESKTOP_ENV=$DESKTOP_ENV" > "$OUTPUT_FILE"
        gum_box_sleep "Hope you enjoy: $CHOICE"
        break
    fi
done
