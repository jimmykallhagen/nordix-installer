#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf
OUTPUT_FILE="$SCRIPT_DIR/../config/gpu.conf"
unset DRIVER CHOICE

# Set base color for the installer
echo -ne "\e]10;${G_BASE_COLOR}\a"

clear
gum_spin_timer "Proceeding with GPU setup"



# Choose GPU
OPTIONS=(
    'AMD - amdgpu'
    'Intel - i915'
    'NVIDIA - nvidia-open (Turing/Ampere/Ada/Blackwell: 16xx,20xx,30xx,40xx,50xx)'
    'Legacy NVIDIA - nvidia-580xx (Maxwell/Pascal/Volta: GTX900,10xx,Titan)'
)


while true; do
    clear
    gum_box "Choose GPU with Enter"
    #  show the list of gpus with gum_choose
    CHOICE=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose "Press Enter to choose")

    # handling ESC/no choise
    if [[ -z "$CHOICE" ]]; then
        clear
        gum_box_sleep "Please select a GPU!" && true
        continue
    fi

    # Map the choice to a variable and break the loop
    case "$CHOICE" in
        "AMD - amdgpu")   GPU="AMD" ;;
        "Intel - i915")   GPU="INTEL" ;;
        *"nvidia-open"*)  GPU="NVIDIA" ;;
        *"nvidia-580xx"*) GPU="LEGACY-NVIDIA" ;;
    esac

    # Confirm the selected gpu
    if gum_confirm "Confirm GPU: ${CHOICE}?"; then
        # write GPU to file
        echo "GPU=\"$GPU\"" > "${OUTPUT_FILE}"
        break
    fi
done
