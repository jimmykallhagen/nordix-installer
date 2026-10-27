#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../gum-lib/gum.conf"
OUTPUT_FILE="${SCRIPT_DIR}/../config/gpu.conf"
unset DRIVER CHOICE

echo -ne "\e]10;${G_BASE_COLOR}\a"

BACKTITLE="Nordix Installer"

OPTIONS=(
    'AMD - amdgpu'
    'Intel - i915'
    'NVIDIA - nvidia-open (Turing/Ampere/Ada/Blackwell: 16xx,20xx,30xx,40xx,50xx)'
    'Legacy NVIDIA - nvidia-580xx (Maxwell/Pascal/Volta: GTX900,10xx,Titan)'
    'Laptop: NVIDIA - nvidia-open (Turing/Ampere/Ada/Blackwell: 16xx,20xx,30xx,40xx,50xx)'
    'Laptop: Legacy NVIDIA - nvidia-580xx (Maxwell/Pascal/Volta: GTX900,10xx,Titan)'
)

while true; do
    dialog --clear --backtitle "$BACKTITLE" --title "GPU" --msgbox "Choose GPU with Enter" 6 50

    menu_args=()
    i=1
    for opt in "${OPTIONS[@]}"; do
        menu_args+=("$i" "$opt")
        ((i++))
    done

    choice_idx=$(dialog --clear --backtitle "$BACKTITLE" --title "GPU" \
        --stdout --menu "Press Enter to choose" 20 90 6 "${menu_args[@]}")
    ret=$?
    if [ $ret -ne 0 ] || [ -z "$choice_idx" ]; then
        dialog --clear --backtitle "$BACKTITLE" --title "Error" --msgbox "Please select a GPU!" 6 50
        continue
    fi

    CHOICE="${OPTIONS[$((choice_idx-1))]}"

    case "$CHOICE" in
        "AMD - amdgpu")   GPU="AMD" ;;
        "Intel - i915")   GPU="INTEL" ;;
        "Legacy NVIDIA - nvidia-580xx (Maxwell/Pascal/Volta: GTX900,10xx,Titan)")  GPU="LEGACY-NVIDIA" ;;
        "NVIDIA - nvidia-open (Turing/Ampere/Ada/Blackwell: 16xx,20xx,30xx,40xx,50xx)")  GPU="NVIDIA" ;;
        "Laptop: Legacy NVIDIA - nvidia-580xx (Maxwell/Pascal/Volta: GTX900,10xx,Titan)")  GPU="LAPTOP-LEGACY-NVIDIA" ;;
        "Laptop: NVIDIA - nvidia-open (Turing/Ampere/Ada/Blackwell: 16xx,20xx,30xx,40xx,50xx)")  GPU="LAPTOP-NVIDIA" ;;
    esac

    if dialog --clear --backtitle "$BACKTITLE" --title "Confirm GPU" --yesno "Confirm GPU: ${CHOICE}?" 10 90 2>&1 >/dev/tty; then
        echo "GPU=\"$GPU\"" > "${OUTPUT_FILE}"
        break
    fi
done
