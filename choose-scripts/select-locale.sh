#!/bin/bash
# # ZFS Script 1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
OPTIONS=""
OUTPUT_FILE="${CONFIG_DIR}/locale.conf"
source ${SCRIPT_DIR}/../gum-lib/gum.conf
source ${SCRIPT_DIR}/../lib/locale.conf
echo -ne "\e]10;${G_BASE_COLOR}\a"

clear
gum_spin_timer "Searching for the continents of the world..."

OPTIONS=(
    "Africa"
    "Asia"
    "Europe"
    "North America Including Central America and Caribbean"
    "South America"
    "Oceania"
    "Other International (Esperanto, Syriac, Toki Pona)"
)


while true; do
    clear
    gum_box "Select the region for the language the system should use."
    #  show the list of gpus with gum_choose
    CHOICE=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose "Press Enter to choose")

    # handling ESC/no choise
    if [[ -z "$CHOICE" ]]; then
        clear
        gum_box_sleep "Please select a continent!" && true
        continue
    fi

    # Map the choice to a variable and break the loop
    case "$CHOICE" in
        "Africa")        CONTINENT_NAME="AFRICA" ;;
        "Asia")           CONTINENT_NAME="ASIA" ;;
        "Europe")         CONTINENT_NAME="EUROPE" ;;
        "North America Including Central America and Caribbean") CONTINENT_NAME="NORTH_AMERICA_INCL_CENTRAL_AMERICA_AND_CARIBBEAN" ;;
        "South America")  CONTINENT_NAME="SOUTH_AMERICA" ;;
        "Oceania")        CONTINENT_NAME="OCEANIA" ;;
        "Other International (Esperanto, Syriac, Toki Pona)") CONTINENT_NAME="OTHER_INTERNATIONAL" ;;
    esac

    # Confirm the selected continent
    if gum_confirm "Confirm continent: ${CHOICE}?"; then
        declare -n CONTINENT="$CONTINENT_NAME"

        # Choose the language
        clear
        gum_spin_timer "Gathering ${CHOICE}'s languages..."

        while true; do
            clear
            gum_box "Select the language the system should use."
            #  show the list of languages
            #  Using nameref to access the correct continent array
            #  Add back option at top
            LANGUAGE_OPTIONS=("<- Back to continent" "" "${CONTINENT[@]}")

        SELECTED_LOCALE=$(printf "%s\n" "${LANGUAGE_OPTIONS[@]}" | gum_choose "Press Enter to choose")

            # handling ESC/no choise
            if [[ -z "$SELECTED_LOCALE" ]]; then
                clear
                gum_box_sleep "Please select a language!" && true
                continue
            fi

            # Back to continent selection
            if [[ "$SELECTED_LOCALE" == "<- Back to continent" ]]; then
                break
            fi

            # run the case funktion in lib/locale.conf
            # to map selected language to correct UTF-8 encoding
            case_locale
            # write selected locale to output file
            echo "LOCALE=\"$_LOCALE\""  > "${OUTPUT_FILE}"
            clear
            gum_spin_timer "Locale selected: ${SELECTED_LOCALE} mowing on to next step..."
            break 2
        done

    fi
done
