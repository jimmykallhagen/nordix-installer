#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
OPTIONS=""
OUTPUT_FILE="${CONFIG_DIR}/timezone.conf"
source ${SCRIPT_DIR}/../gum-lib/gum.conf
source ${SCRIPT_DIR}/../lib/timezone.conf
echo -ne "\e]10;${G_BASE_COLOR}\a"

clear
 gum_spin_timer "Searching for the continents of the world..."

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
    clear
    gum_box "Select the continent for the timezone the system should use."
    CHOICE=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose "Press Enter to choose")

    # handling ESC/no choice
    if [[ -z "$CHOICE" ]]; then
        clear
        gum_box_sleep "Please select a continent!" && true
        continue
    fi

    # Confirm the selected continent
    if gum_confirm "Confirm continent: ${CHOICE}?"; then
        SELECTED_CONTINENT="$CHOICE"
        declare -n region_arr="$SELECTED_CONTINENT"

        # Choose the timezone
        clear
         gum_spin_timer "Gathering ${SELECTED_CONTINENT}'s regions..."

        while true; do
            clear
            gum_box "Select the region for the timezone the system should use."

            CONTINENT_OPTIONS=("<- Back to continent" "${region_arr[@]}")

            SELECTED_TIMEZONE=$(printf "%s\n" "${CONTINENT_OPTIONS[@]}" | gum_choose "Press Enter to choose")

            # handling ESC/no choice
            if [[ -z "$SELECTED_TIMEZONE" ]]; then
                clear
                gum_box_sleep "Please select a timezone!" && true
                continue
            fi

            # Back to continent selection
            if [[ "$SELECTED_TIMEZONE" == "<- Back to continent" ]]; then
                break
            fi
            # write selected timezone to output file
            echo "TIMEZONE=\"${SELECTED_CONTINENT}/${SELECTED_TIMEZONE}\"" > "${OUTPUT_FILE}"
            clear
            gum_spin_timer "timezone selected: ${SELECTED_CONTINENT}/${SELECTED_TIMEZONE} moving on to next step..."
            break 2
        done
    fi
done
