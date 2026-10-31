#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
BACKTITLE="Nordix Installer"


handle_interrupt() {
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "Cannot Exit" \
        --msgbox "You cant exit here" 5 25
    exec "${BASH_SOURCE[0]}" "$@"
}
trap handle_interrupt INT TERM QUIT HUP

while true; do
    HOSTNAME=$(dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "Custom Hostname" \
        --no-cancel \
        --inputbox "Enter hostname (lowercase letters, numbers, hyphens - no spaces)" 7 80 "nordix" 2>&1 >/dev/tty)

    dialog --clear  \
    --backtitle "$BACKTITLE" \
    --title "Hostname" \
    --yesno "Hostname set to: $HOSTNAME" 6 50
    if [ $? -eq 0 ]; then
        break

fi
done

echo "HOST_NAME=\"$HOSTNAME\"" > "$CONFIG_DIR/hostname.conf"
