#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
OPTIONS=""
OUTPUT_FILE="${CONFIG_DIR}/locale.conf"
source "${SCRIPT_DIR}/../gum-lib/gum.conf"
source "${SCRIPT_DIR}/../lib/locale.conf"
echo -ne "\e]10;${G_BASE_COLOR}\a"

BACKTITLE="Nordix Installer"

dialog --clear --backtitle "$BACKTITLE" --title "Locale" --msgbox "Searching for the continents of the world..." 6 50
sleep 1

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
    dialog --clear --backtitle "$BACKTITLE" --title "Locale" --msgbox "Select the region for the language the system should use." 8 60

    menu_args=()
    i=1
    for opt in "${OPTIONS[@]}"; do
        menu_args+=("$i" "$opt")
        ((i++))
    done

    choice_idx=$(dialog --clear --backtitle "$BACKTITLE" --title "Continent" \
        --stdout --menu "Press Enter to choose" 20 80 7 "${menu_args[@]}")
    ret=$?
    if [ $ret -ne 0 ] || [ -z "$choice_idx" ]; then
        dialog --clear --backtitle "$BACKTITLE" --title "Error" --msgbox "Please select a continent!" 6 50
        continue
    fi

    CHOICE="${OPTIONS[$((choice_idx-1))]}"

    case "$CHOICE" in
        "Africa")        CONTINENT_NAME="AFRICA" ;;
        "Asia")          CONTINENT_NAME="ASIA" ;;
        "Europe")        CONTINENT_NAME="EUROPE" ;;
        "North America Including Central America and Caribbean") CONTINENT_NAME="NORTH_AMERICA_INCL_CENTRAL_AMERICA_AND_CARIBBEAN" ;;
        "South America") CONTINENT_NAME="SOUTH_AMERICA" ;;
        "Oceania")       CONTINENT_NAME="OCEANIA" ;;
        "Other International (Esperanto, Syriac, Toki Pona)") CONTINENT_NAME="OTHER_INTERNATIONAL" ;;
    esac

    if dialog --clear --backtitle "$BACKTITLE" --title "Confirm Continent" --yesno "Confirm continent: ${CHOICE}?" 10 60 2>&1 >/dev/tty; then
        declare -n CONTINENT="$CONTINENT_NAME"

        dialog --clear --backtitle "$BACKTITLE" --title "Locale" --msgbox "Gathering ${CHOICE}'s languages..." 6 50
        sleep 1

        while true; do
            dialog --clear --backtitle "$BACKTITLE" --title "Locale" --msgbox "Select the language the system should use." 8 60

            # Build language menu with Back option
            lang_opts=("<- Back to continent")
            for lang in "${CONTINENT[@]}"; do
                lang_opts+=("$lang")
            done

            menu_args=()
            i=1
            for opt in "${lang_opts[@]}"; do
                menu_args+=("$i" "$opt")
                ((i++))
            done

            sel_idx=$(dialog --clear --backtitle "$BACKTITLE" --title "Language" \
                --stdout --menu "Press Enter to choose" 25 80 15 "${menu_args[@]}")
            ret=$?
            if [ $ret -ne 0 ] || [ -z "$sel_idx" ]; then
                dialog --clear --backtitle "$BACKTITLE" --title "Error" --msgbox "Please select a language!" 6 50
                continue
            fi

            SELECTED_LOCALE="${lang_opts[$((sel_idx-1))]}"

            if [[ "$SELECTED_LOCALE" == "<- Back to continent" ]]; then
                break
            fi

            # Map to locale encoding
            SELECTED_LOCALE="$SELECTED_LOCALE"
            case_locale
            echo "LOCALE=\"$_LOCALE\"" > "${OUTPUT_FILE}"
            dialog --clear --backtitle "$BACKTITLE" --title "Locale" --msgbox "Locale selected: ${SELECTED_LOCALE} moving on to next step..." 8 60
            exit 0
        done
    fi
done
