#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../gum-lib/gum.conf"
OUTPUT_FILE="${SCRIPT_DIR}/../config/extra-pkg-office-utils.conf"
unset CHOICE

echo -ne "\e]10;${G_BASE_COLOR}\a"

BACKTITLE="Nordix Installer"

dialog --clear --backtitle "$BACKTITLE" --title "Extra Packages" --msgbox "Looking for some Office & Utilities packages..." 6 50

OPTIONS=(
    "LibreOffice Fresh - Completely featured office suite"
    "PeaZip - File and archive manager application features volume spanning, compression and authenticated encryption"
    "Qbittorrent - BitTorrent client"
    "Exit"
)

while true; do
    dialog --clear --backtitle "$BACKTITLE" --title "Extra Packages" --msgbox "Extra package selection: Office & Utilities" 6 50

    menu_args=()
    i=1
    for opt in "${OPTIONS[@]}"; do
        [[ -z "$opt" ]] && continue
        menu_args+=("$i" "$opt" "OFF")
        ((i++))
    done

    selected_tags=$(dialog --clear --backtitle "$BACKTITLE" --title "Extra Packages" \
        --stdout --checklist "Press SPACE to choose - Enter to confirm" 15 100 4 "${menu_args[@]}")
    ret=$?
    if [ $ret -ne 0 ]; then
        dialog --clear --backtitle "$BACKTITLE" --title "Info" --msgbox "Maybe next time" 6 40
        break
    fi

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
        dialog --clear --backtitle "$BACKTITLE" --title "Info" --msgbox "Maybe next time" 6 40
        break
    fi

    confirm_text=$(printf "%s\n" "${selected_opts[@]}" | head -c 200)
    if dialog --clear --backtitle "$BACKTITLE" --title "Confirm" --yesno "Confirm package(s):\n$confirm_text" 15 70 2>&1 >/dev/tty; then
        > "${OUTPUT_FILE}"
        for line in "${selected_opts[@]}"; do
            case "$line" in
                "LibreOffice Fresh - Completely featured office suite") echo "PKG-OU1=libreoffice" >> "${OUTPUT_FILE}" ;;
                "PeaZip - File and archive manager application features volume spanning, compression and authenticated encryption") echo "PKG-OU2=peazip" >> "${OUTPUT_FILE}" ;;
                "Qbittorrent - BitTorrent client") echo "PKG-OU3=qbittorrent" >> "${OUTPUT_FILE}" ;;
            esac
        done
        break
    fi
done
