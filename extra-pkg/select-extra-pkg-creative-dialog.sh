#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${SCRIPT_DIR}/../config/extra-pkg-creative.conf"
clear

BACKTITLE="Nordix Installer"

handle_interrupt() {
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --colors --color-mode 2 \
        --title "\Zb\Z1Cannot Exit" \
        --msgbox "You cant exit here" 5 25
exec "${BASH_SOURCE[0]}" "$@"
}
trap handle_interrupt INT TERM QUIT HUP

OPTIONS=(
    "Gimp - GNU Image Manipulation Program"
    "Blender - 3D modeling and animation software"
    "Krita - Digital painting and illustration software"
    "Inkscape - Vector graphics editor"
    "Shotcut - Video editing software"
    "OBS Studio - Open Broadcaster Software"
    "GPU Screen Recorder - The fastest screen recorder for Linux"
    "Upscayl Desktop app - AI image upscaling software"
)

while true; do
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --colors --color-mode 2 \
        --title "\ZbExtra Packages" \
        --msgbox "Extra package selection: Creative" 5 45

    menu_args=()
    i=1
    for opt in "${OPTIONS[@]}"; do
        [[ -z "$opt" ]] && continue
        menu_args+=("$i" "\Zb\Z1$opt" "OFF")
        ((i++))
    done
#              --aspect ratio \

    selected_tags=$(dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "\Zb\Z0Extra Packages" \
        --colors --color-mode 2 \
        --stdout --checklist "\Zb\Z4| Video Editing - Photo Editing - Graphics - Recording - Streaming - Image Editing - Upscaling" 0 100 9 "${menu_args[@]}")

    opt_list=()
    for o in "${OPTIONS[@]}"; do
        [[ -z "$o" ]] && continue
        opt_list+=("$o")
    done

    selected_opts=()
    exit_selected=false
    for tag in $selected_tags; do
        opt="${opt_list[$((tag-1))]}"
        if [[ "$opt" == "Exit" ]]; then
            exit_selected=true
        else
            selected_opts+=("$opt")
        fi
    done

    if $exit_selected || [ ${#selected_opts[@]} -eq 0 ]; then
        dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "Info" \
            --msgbox "Maybe next time" 5 40
        break
    fi

    confirm_text=$(printf "%s\n" "${selected_opts[@]}")
    if dialog --clear \
            --colors \
            --color-mode 2 \
            --backtitle "$BACKTITLE" \
            --title "\ZbConfirm Packages" \
            --yes-label "I want PKG" \
            --yesno "Confirm package(s):\n$confirm_text" 15 65 2>&1 >/dev/tty; then
        > "${OUTPUT_FILE}"

        for line in "${selected_opts[@]}"; do
            case "$line" in
                "Gimp - GNU Image Manipulation Program") echo "PKG-C1=gimp" >> "${OUTPUT_FILE}" ;;
                "Blender - 3D modeling and animation software") echo "PKG-C2=blender" >> "${OUTPUT_FILE}" ;;
                "Krita - Digital painting and illustration software") echo "PKG-C3=krita" >> "${OUTPUT_FILE}" ;;
                "Inkscape - Vector graphics editor") echo "PKG-C4=inkscape" >> "${OUTPUT_FILE}" ;;
                "Shotcut - Video editing software") echo "PKG-C5=shotcut" >> "${OUTPUT_FILE}" ;;
                "OBS Studio - Open Broadcaster Software") echo "PKG-C6=obs-studio" >> "${OUTPUT_FILE}" ;;
                "GPU Screen Recorder - The fastest screen recorder for Linux") echo "PKG-C7=gpu-screen-recorder" >> "${OUTPUT_FILE}" ;;
                "Upscayl Desktop app - AI image upscaling software") echo "PKG-C8=upscayl-desktop-git" >> "${OUTPUT_FILE}" ;;
            esac
        done
        break
    fi
done
