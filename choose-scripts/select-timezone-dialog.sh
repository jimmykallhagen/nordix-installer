#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
OUTPUT_FILE="${CONFIG_DIR}/timezone.conf"
source "${SCRIPT_DIR}/../gum-lib/gum.conf"
source "${SCRIPT_DIR}/../lib/timezone.conf"
echo -ne "\e]10;${G_BASE_COLOR}\a"

BACKTITLE="Nordix Installer"

dialog --clear --backtitle "$BACKTITLE" --title "Timezone" --msgbox "Searching for the continents of the world..." 6 50
sleep 1

OPTIONS=(
    "Africa"
    "America"
    "Antarctica"
    "Arctic"
    "Asia"
    "Atlantic"
    "Australia"
    "Brazil"
    "Canada"
    "Chile"
    "Europe"
    "Indian"
    "Mexico"
    "Pacific"
)

while true; do
    dialog --clear --backtitle "$BACKTITLE" --title "Timezone" --msgbox "Select the continent for the timezone the system should use." 8 60

    menu_args=()
    i=1
    for opt in "${OPTIONS[@]}"; do
        menu_args+=("$i" "$opt")
        ((i++))
    done

    choice_idx=$(dialog --clear --backtitle "$BACKTITLE" --title "Continent" \
        --stdout --menu "Press Enter to choose" 20 60 14 "${menu_args[@]}")
    ret=$?
    if [ $ret -ne 0 ] || [ -z "$choice_idx" ]; then
        dialog --clear --backtitle "$BACKTITLE" --title "Error" --msgbox "Please select a continent!" 6 50
        continue
    fi

    CHOICE="${OPTIONS[$((choice_idx-1))]}"

    if dialog --clear --backtitle "$BACKTITLE" --title "Confirm Continent" --yesno "Confirm continent: ${CHOICE}?" 10 60 2>&1 >/dev/tty; then
        SELECTED_CONTINENT="$CHOICE"
        declare -n region_arr="$SELECTED_CONTINENT"

        dialog --clear --backtitle "$BACKTITLE" --title "Timezone" --msgbox "Gathering ${SELECTED_CONTINENT}'s regions..." 6 50
        sleep 1

        while true; do
            dialog --clear --backtitle "$BACKTITLE" --title "Timezone" --msgbox "Select the region for the timezone the system should use." 8 60

            # Build region options with Back
            region_opts=("<- Back to continent")
            for tz in "${region_arr[@]}"; do
                region_opts+=("$tz")
            done

            menu_args=()
            i=1
            for opt in "${region_opts[@]}"; do
                menu_args+=("$i" "$opt")
                ((i++))
            done

            sel_idx=$(dialog --clear --backtitle "$BACKTITLE" --title "Timezone Region" \
                --stdout --menu "Press Enter to choose" 25 80 15 "${menu_args[@]}")
            ret=$?
            if [ $ret -ne 0 ] || [ -z "$sel_idx" ]; then
                dialog --clear --backtitle "$BACKTITLE" --title "Error" --msgbox "Please select a timezone!" 6 50
                continue
            fi

            SELECTED_TIMEZONE="${region_opts[$((sel_idx-1))]}"

            if [[ "$SELECTED_TIMEZONE" == "<- Back to continent" ]]; then
                break
            fi

            echo "TIMEZONE=\"${SELECTED_CONTINENT}/${SELECTED_TIMEZONE}\"" > "${OUTPUT_FILE}"
            dialog --clear --backtitle "$BACKTITLE" --title "Timezone" --msgbox "timezone selected: ${SELECTED_CONTINENT}/${SELECTED_TIMEZONE} moving on to next step..." 8 70
            exit 0
        done
    fi
done
