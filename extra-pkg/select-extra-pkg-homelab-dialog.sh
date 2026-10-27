#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../gum-lib/gum.conf"
OUTPUT_FILE="${SCRIPT_DIR}/../config/extra-pkg-homelab.conf"
unset CHOICE

echo -ne "\e]10;${G_BASE_COLOR}\a"

BACKTITLE="Nordix Installer"

OPTIONS=(
    'Docker - ZFS drivers'
    'SSH -  OpenSSH remote login client'
    'VM - Run virtual machines with Qemu, KVM, libvirt and Virt-Manager'
    'Ollama - Host local ai, simpel terminal ui, good support to supply local ai models to other ai tools'
    'LmStudio - Host local ai, full GUI from start, can be used to supply local ai models to other ai tools'
    'Unsloth - Fast inference and fine-tuning for transformer models, with webui'
    'Cockpit - Web-based server management'
    'Exit'
)

while true; do
    dialog --clear --backtitle "$BACKTITLE" --title "Extra Packages" --msgbox "Extra package selection: Homelab" 6 50

    # Build checklist args
    menu_args=()
    i=1
    for opt in "${OPTIONS[@]}"; do
        [[ -z "$opt" ]] && continue
        menu_args+=("$i" "$opt" "OFF")
        ((i++))
    done

    selected_tags=$(dialog --clear --backtitle "$BACKTITLE" --title "Extra Packages" \
        --stdout --checklist "Press SPACE to choose - Enter to confirm" 20 100 8 "${menu_args[@]}")
    ret=$?
    if [ $ret -ne 0 ]; then
        dialog --clear --backtitle "$BACKTITLE" --title "Info" --msgbox "Maybe next time" 6 40
        break
    fi

    # Map tags to option texts
    selected_opts=()
    exit_selected=false
    for tag in $selected_tags; do
        idx=$((tag-1))
        # Find option by index skipping empty
        # Rebuild list without empties
        opt_list=()
        for o in "${OPTIONS[@]}"; do
            [[ -z "$o" ]] && continue
            opt_list+=("$o")
        done
        opt="${opt_list[$((tag-1))]}"
        if [[ "$opt" == "Exit" ]]; then
            exit_selected=true
        else
            selected_opts+=("$opt")
        fi
    done

    if $exit_selected || [ ${#selected_opts[@]} -eq 0 ]; then
        dialog --clear --backtitle "$BACKTITLE" --title "Info" --msgbox "Maybe next time" 6 40
        break
    fi

    # Confirm
    confirm_text=$(printf "%s\n" "${selected_opts[@]}" | head -c 200)
    if dialog --clear --backtitle "$BACKTITLE" --title "Confirm" --yesno "Confirm package(s):\n$confirm_text" 15 70 2>&1 >/dev/tty; then
        > "${OUTPUT_FILE}"
        for line in "${selected_opts[@]}"; do
            case "$line" in
                "Docker - ZFS drivers")   echo "PKG-H1=docker" >> "${OUTPUT_FILE}" ;;
                "SSH -  OpenSSH remote login client")   echo "PKG-H2=ssh" >> "${OUTPUT_FILE}" ;;
                "VM - Run virtual machines with Qemu, KVM, libvirt and Virt-Manager") echo "PKG-H3=VM" >> "${OUTPUT_FILE}" ;;
                "Ollama - Host local ai, simpel terminal ui, good support to supply local ai models to other ai tools") echo "PKG-H4=ollama" >> "${OUTPUT_FILE}" ;;
                "LmStudio - Host local ai, full GUI from start, can be used to supply local ai models to other ai tools") echo "PKG-H5=lmstudio" >> "${OUTPUT_FILE}" ;;
                "Unsloth - Fast inference and fine-tuning for transformer models, with webui") echo "PKG-H6=unsloth" >> "${OUTPUT_FILE}" ;;
                "Cockpit - Web-based server management") echo "PKG-H7=cockpit" >> "${OUTPUT_FILE}" ;;
            esac
        done
        break
    fi
done
