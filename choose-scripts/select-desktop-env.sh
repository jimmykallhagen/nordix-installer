#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf
OUTPUT_FILE="$SCRIPT_DIR/../config/desktop.env.conf"
echo -ne "\e]10;${G_BASE_COLOR}\a"

clear
gum_spin_timer "Loading desktop environment options..."



OPTIONS=(
    "Niri - Ready to use. Preconfigured setup with VanillaGreen Shell"
    "Comsic Desktop - Modern look and feel, nice and simple to use"
    "GNOME - Modern desktop environment, classic Linux style"
    "KDE Plasma - Windows Like, easy to personalize"
    ""
    "Server - Headless/No desktop environment"
)

while true; do
    clear
    gum_box "Desktop Environment"

CHOICE=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose "Press Enter to confirm")
    # handling ESC/no choise
    if [[ -z "$CHOICE" ]]; then
        clear
        gum_box_sleep "Please select a desktop environment!" && true
        continue
    fi


case "$CHOICE" in
    "Niri - Ready to use. Preconfigured setup with VanillaGreen Shell")
        DESKTOP_ENV=niri
        ;;
    "Comsic Desktop - Modern look and feel, nice and simple to use")
        DESKTOP_ENV=cosmic
        ;;
    "GNOME - Modern desktop environment, classic Linux style")
        DESKTOP_ENV=gnome
        ;;
    "KDE Plasma - Windows Like, easy to personalize")
        DESKTOP_ENV=kde
        ;;
    "Server - Headless/No desktop environment")
        DESKTOP_ENV=server
        ;;
esac
    if gum_confirm "Confirm desktop environment: ${CHOICE}?"; then
        echo "DESKTOP_ENV=$DESKTOP_ENV" > "$OUTPUT_FILE"
        gum_box_sleep "Hope you enjoy: ${CHOICE}"
        break
    fi
done
