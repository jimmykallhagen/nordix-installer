#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${SCRIPT_DIR}/../config/extra-pkg-office-utils.conf"
BACKTITLE="Nordix Installer"

clear

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
    "LibreOffice - Completely featured office suite."
    "PeaZip - File and archive manager application features volume spanning, compression and authenticated encryption."
    "Qbittorrent - BitTorrent client."
)

while true; do
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --colors --color-mode 2 \
        --title "\ZbExtra Packages" \
        --msgbox "Extra package selection: Office & Utilities" 5 50

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
        --stdout --checklist "\Zb\Z4Utilities" 0 130 3 "${menu_args[@]}")

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
            --msgbox "Maybe next time" 5 20
        break
    fi

    confirm_text=$(printf "%s\n" "${selected_opts[@]}")
    if dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "\ZbConfirm Packages" \
        --yes-label "I want PKG" \
        --yesno "Confirm package(s):\n$confirm_text" 15 70 2>&1 >/dev/tty; then
        > "${OUTPUT_FILE}"
        for line in "${selected_opts[@]}"; do
            case "$line" in
                "LibreOffice"*)                         echo "libreoffice-fresh" >> "${OUTPUT_FILE}" ;;
                "PeaZip"*)                              echo "peazip"            >> "${OUTPUT_FILE}" ;;
                "Qbittorrent"*)                         echo "qbittorrent"       >> "${OUTPUT_FILE}" ;;
            esac
        done
        break
    fi
done
