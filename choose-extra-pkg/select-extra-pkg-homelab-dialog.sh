#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${SCRIPT_DIR}/../config/extra-pkg-homelab.conf"

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
    'Docker - ZFS drivers.'
    'Podman - Container runtime.'
    'Podman Desktop - GUI management tool for Podman, docker, Kubernetes.'
    'SSH -  OpenSSH remote login client.'
    'VM - Run virtual machines with Qemu, KVM, libvirt and Virt-Manager.'
    'Ollama - Host local ai, simpel terminal ui, good support to supply local ai models to other ai tools.'
    'LmStudio - Host local ai, full GUI from start, can be used to supply local ai models to other ai tools.'
    'Unsloth - Chat, create music, video, images and full development tooling with WebUI for local ai development.'
    'Cockpit - Web-based server management (Base).'
    'Kodi – a self-hosted entertainment hub for media.'


)

while true; do
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --colors --color-mode 2 \
        --title "\ZbExtra Packages" \
        --msgbox "Extra package selection: Homelab" 5 40

    # Build checklist args
    menu_args=()
    i=1
    for opt in "${OPTIONS[@]}"; do
        [[ -z "$opt" ]] && continue
        menu_args+=("$i" "\Zb\Z1$opt" "OFF")
        ((i++))
    done

    selected_tags=$(dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "\Zb\Z0Extra Packages" \
        --colors --color-mode 2 \
        --stdout --checklist "\Zb\Z4| Local AI - SSH - Virtualization - WebUI - Self hosting" 0 122 9 "${menu_args[@]}")


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
        dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "Info" \
            --msgbox "Maybe next time" 5 40
        break
    fi

    # Confirm
    confirm_text=$(printf "%s\n" "${selected_opts[@]}")
    if dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "\ZbConfirm Packages" \
        --yes-label "I want PKG" \
        --yesno "Confirm package(s):\n$confirm_text" 15 70 2>&1 >/dev/tty; then
        > "${OUTPUT_FILE}"

        for line in "${selected_opts[@]}"; do
            case "$line" in
                "Docker - Container runtime with ZFS drivers.")                                                                     echo "docker" >> "${OUTPUT_FILE}" ;;
                "Podman - Container runtime.")                                                                                      echo "podman" >> "${OUTPUT_FILE}" ;;
                "Podman Desktop - GUI management tool for Podman, docker, Kubernetes.")                                             echo "podman-desktop" >> "${OUTPUT_FILE}" ;;
                "SSH -  OpenSSH remote login client.")                                                                              echo "openssh" >> "${OUTPUT_FILE}" ;;
                "VM - Run virtual machines with Qemu, KVM, libvirt and Virt-Manager.")                                              echo "VM" >> "${OUTPUT_FILE}" ;;
                "Ollama - Host local ai, simpel terminal ui, good support to supply local ai models to other ai tools.")            echo "ollama" >> "${OUTPUT_FILE}" ;;
                "LmStudio - Host local ai, full GUI from start, can be used to supply local ai models to other ai tools.")          echo "lmstudio" >> "${OUTPUT_FILE}" ;;
                "Unsloth - Chat, create music, video, images and full development tooling with WebUI for local ai development.")    echo "unsloth" >> "${OUTPUT_FILE}" ;;
                "Cockpit - Web-based server management (Base).")                                                                    echo "cockpit" >> "${OUTPUT_FILE}" ;;
                "Kodi – a self-hosted entertainment hub for media.")                                                                echo "kodi" >> "${OUTPUT_FILE}" ;;
            esac
        done
        break
    fi
done
