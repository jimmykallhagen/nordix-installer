#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf
OUTPUT_FILE="$SCRIPT_DIR/../config/extra-pkg-office-utils.conf"
unset CHOICE

# Set base color for the installer
echo -ne "\e]10;${G_BASE_COLOR}\a"

clear
gum_sin_sleep "Looking for some Office & Utilities packages..."

while true; do
    clear
    gum_box "Extra package selection: Office & Utilities"
# Choose package
OPTIONS=(
    "LibreOffice Fresh - Completely featured office suite"
    "PeaZip - File and archive manager application features volume spanning, compression and authenticated encryption"
    ""
    'Exit'
)

    # show the list of packages with gum_choose
    CHOICE=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose_no_limit "Press Space to choose - Enter to confirm")

    # handling ESC/no choice
    if [[ -z "$CHOICE" ]]; then
        gum_box_sleep "Please select an option with Space!" && true
        continue
    fi

    # Filter out Exit from selection
    CHOICE_FILTERED=$(printf "%s\n" "$CHOICE" | grep -vx "Exit" || true)

    # If user only selected Exit or nothing remains after filtering
    if [[ -z "$CHOICE_FILTERED" ]]; then
        gum_box_sleep "Maybe next time"
        break
    fi

    # Confirm the selected package(s)
    if gum_confirm "Confirm package(s): ${CHOICE_FILTERED}?"; then
        # Clear output file before writing - overwrite each run
        > "${OUTPUT_FILE}"
        # Process each selected choice line by line
        while IFS= read -r line; do
            case "$line" in
                "LibreOffice Fresh - Completely featured office suite")   echo "PKG-OU1=libreoffice" >> "${OUTPUT_FILE}"  ;;
                "PeaZip - File and archive manager application features volume spanning, compression and authenticated encryption")   echo "PKG-OU2=peazip" >> "${OUTPUT_FILE}"  ;;
         esac
        done <<< "$CHOICE_FILTERED"
        break
    fi
done
