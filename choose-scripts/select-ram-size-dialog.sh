#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../gum-lib/gum.conf"
unset RAM_SIZE CHOICE

MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_GB=$(( (MEM_KB + 1024 * 1024 / 2) / (1024 * 1024) ))

echo -ne "\e]10;${G_BASE_COLOR}\a"

BACKTITLE="Nordix Installer"

dialog --clear --backtitle "$BACKTITLE" --title "RAM" --msgbox "Proceeding with ZFS configuration - RAM" 6 50
sleep 1

OPTIONS=(
"RAM Size - 8GB"
"RAM Size - 16GB"
"RAM Size - 32GB"
"RAM Size - 64GB"
"RAM Size - 128GB"
)

while true; do
    dialog --clear --backtitle "$BACKTITLE" --title "RAM" --msgbox "Choose RAM size with Enter" 6 50

    menu_args=()
    i=1
    for opt in "${OPTIONS[@]}"; do
        menu_args+=("$i" "$opt")
        ((i++))
    done

    choice_idx=$(dialog --clear --backtitle "$BACKTITLE" --title "RAM Size" \
        --stdout --menu "Press Enter to choose" 15 50 5 "${menu_args[@]}")
    ret=$?
    if [ $ret -ne 0 ] || [ -z "$choice_idx" ]; then
        dialog --clear --backtitle "$BACKTITLE" --title "Error" --msgbox "Please select a RAM configuration!" 6 50
        continue
    fi

    CHOICE="${OPTIONS[$((choice_idx-1))]}"

    case "$CHOICE" in
        "RAM Size - 8GB")   RAM_SIZE="8GB" ;;
        "RAM Size - 16GB")  RAM_SIZE="16GB" ;;
        "RAM Size - 32GB")  RAM_SIZE="32GB" ;;
        "RAM Size - 64GB")  RAM_SIZE="64GB" ;;
        "RAM Size - 128GB") RAM_SIZE="128GB" ;;
    esac

    if dialog --clear --backtitle "$BACKTITLE" --title "Confirm RAM" --yesno "Confirm RAM Size: ${CHOICE}?" 10 50 2>&1 >/dev/tty; then
        echo "_RAM=\"$RAM_SIZE\"" > "$SCRIPT_DIR/../config/ram-size.conf"
        break
    fi
done
