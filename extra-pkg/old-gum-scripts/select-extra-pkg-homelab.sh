#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf
OUTPUT_FILE="$SCRIPT_DIR/../config/extra-pkg-homelab.conf"
unset CHOICE

# Set base color for the installer
echo -ne "\e]10;${G_BASE_COLOR}\a"

# Choose package
OPTIONS=(
    'Docker - ZFS drivers'
    'SSH -  OpenSSH remote login client'
    'VM - Run virtual machines with Qemu, KVM, libvirt and Virt-Manager'
    'Ollama - Host local ai, simpel terminal ui, good support to supply local ai models to other ai tools'
    'LmStudio - Host local ai, full GUI from start, can be used to supply local ai models to other ai tools'
    'Unsloth - Fast inference and fine-tuning for transformer models, with webui'
    'Cockpit - Web-based server management'
    ""
    'Exit'
)

while true; do
    clear
    gum_box "Extra package selection: Homelab"
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
                "Docker - ZFS drivers")   echo "PKG-H1=docker" >> "${OUTPUT_FILE}"  ;;
                "SSH")   echo "PKG-H2=ssh" >> "${OUTPUT_FILE}" ;;
                "VM*") echo "PKG-H3=VM" >> "${OUTPUT_FILE}" ;;
                "Ollama*") echo "PKG-H4=ollama" >> "${OUTPUT_FILE}" ;;
                "LmStudio*") echo "PKG-H5=lmstudio" >> "${OUTPUT_FILE}" ;;
                "Unsloth*") echo "PKG-H6=unsloth" >> "${OUTPUT_FILE}" ;;
                "Cockpit - Web-based server management") echo "PKG-H7=cockpit" >> "${OUTPUT_FILE}" ;;
            esac
        done <<< "$CHOICE_FILTERED"
        break
    fi
done
