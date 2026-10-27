#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
source "${SCRIPT_DIR}/../gum-lib/gum.conf"

echo -ne "\e]10;${G_BASE_COLOR}\a"

BACKTITLE="Nordix Installer"

dialog --clear --backtitle "$BACKTITLE" --title "Hostname" --msgbox "Set hostname" 6 40
sleep 1

OPTIONS_HOSTNAME=(
    'Default - nordix'
    'Custom'
)

while true; do
    dialog --clear --backtitle "$BACKTITLE" --title "Hostname" --msgbox "Choose hostname with Enter" 6 50

    menu_args=()
    i=1
    for opt in "${OPTIONS_HOSTNAME[@]}"; do
        menu_args+=("$i" "$opt")
        ((i++))
    done

    choice_idx=$(dialog --clear --backtitle "$BACKTITLE" --title "Hostname" \
        --stdout --menu "Press Enter to choose" 12 50 2 "${menu_args[@]}")
    ret=$?
    if [ $ret -ne 0 ] || [ -z "$choice_idx" ]; then
        dialog --clear --backtitle "$BACKTITLE" --title "Error" --msgbox "Please select a hostname!" 6 50
        continue
    fi

    CHOICE_HOST="${OPTIONS_HOSTNAME[$((choice_idx-1))]}"

    case "$CHOICE_HOST" in
        "Default - nordix")
            if dialog --clear --backtitle "$BACKTITLE" --title "Confirm" --yesno "Confirm hostname nordix" 10 40 2>&1 >/dev/tty; then
                HOSTNAME="nordix"
                break
            else
                dialog --clear --backtitle "$BACKTITLE" --title "Info" --msgbox "Hostname not confirmed. Returning to selection." 6 50
                continue
            fi
            ;;
        "Custom")
            custom_hostname=$(dialog --clear --backtitle "$BACKTITLE" --title "Custom Hostname" \
                --inputbox "Enter hostname (lowercase letters, numbers, hyphens - no spaces)" 10 60 "nordix" 2>&1 >/dev/tty)
            ret=$?
            if [ $ret -ne 0 ] || [ -z "$custom_hostname" ]; then
                dialog --clear --backtitle "$BACKTITLE" --title "Error" --msgbox "Hostname required!" 6 50
                continue
            fi
            if [[ "$custom_hostname" =~ ^[a-z][a-z0-9-]{2,62}$ ]]; then
                if dialog --clear --backtitle "$BACKTITLE" --title "Confirm" --yesno "Confirm $custom_hostname" 10 50 2>&1 >/dev/tty; then
                    HOSTNAME="$custom_hostname"
                    break
                else
                    dialog --clear --backtitle "$BACKTITLE" --title "Info" --msgbox "Hostname not confirmed. Returning to selection." 6 50
                    continue
                fi
            else
                dialog --clear --backtitle "$BACKTITLE" --title "Error" --msgbox "Invalid hostname format! Must start with a letter, only lowercase letters, numbers, hyphens, 3-63 chars. Returning to selection." 10 70
                continue
            fi
            ;;
    esac
done

dialog --clear --backtitle "$BACKTITLE" --title "Done" --msgbox "Hostname set to: $HOSTNAME" 6 50
echo "HOST_NAME=\"$HOSTNAME\"" > "$CONFIG_DIR/hostname.conf"
