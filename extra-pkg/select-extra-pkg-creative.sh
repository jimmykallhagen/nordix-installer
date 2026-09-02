#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf
OUTPUT_FILE="$SCRIPT_DIR/../config/extra-pkg-creative.conf"
unset CHOICE

# Set base color for the installer
echo -ne "\e]10;${G_BASE_COLOR}\a"

clear
gum_sin_sleep "Looking for some content creator packages..."

while true; do
    clear
    gum_box "Extra package selection: Content Creator"

# Choose package
OPTIONS=(
    "Gimp - GNU Image Manipulation Program"
    "Blender - 3D modeling and animation software"
    "Krita - Digital painting and illustration software"
    "Inkscape - Vector graphics editor"
    "Shotcut - Video editing software"
    "Kdenlive - Video editing software"
    "OBS Studio - Open Broadcaster Software"
    "GPU Screen Recorder - The fastest screen recorder for Linux"
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
                "Gimp - GNU Image Manipulation Program")   echo "PKG-C1=gimp" >> "${OUTPUT_FILE}"  ;;
                "Blender - 3D modeling and animation software")   echo "PKG-C2=blender" >> "${OUTPUT_FILE}"  ;;
                "Krita - Digital painting and illustration software")   echo "PKG-C3=krita" >> "${OUTPUT_FILE}"  ;;
                "Inkscape - Vector graphics editor")   echo "PKG-C4=inkscape" >> "${OUTPUT_FILE}"  ;;
                "Shotcut - Video editing software")   echo "PKG-C5=shotcut" >> "${OUTPUT_FILE}"  ;;
                "Kdenlive - Video editing software")   echo "PKG-C6=kdenlive" >> "${OUTPUT_FILE}"  ;;
                "OBS Studio - Open Broadcaster Software")   echo "PKG-C7=obs-studio" >> "${OUTPUT_FILE}"  ;;
                "GPU Screen Recorder - The fastest screen recorder for Linux")   echo "PKG-C8=gpu-screen-recorder" >> "${OUTPUT_FILE}"  ;;
          esac
        done <<< "$CHOICE_FILTERED"
        break
    fi
done
