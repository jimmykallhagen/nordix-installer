#!/bin/bash
# # ZFS Script 1 - Dialog version
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
MASTER_LIST="${CONFIG_DIR}/drives.conf"
BOOT_FILE="${CONFIG_DIR}/selected_boot_drive.conf"
OUTPUT_FILE="${CONFIG_DIR}/device-list-vdev.conf"

source "$SCRIPT_DIR/../config/drives.conf"

clear

BACKTITLE="Nordix Installer"

handle_interrupt() {
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --colors --color-mode 2 \
        --title "Cannot Exit" \
        --msgbox "\Z1You cant exit here" 5 25
    exec "${BASH_SOURCE[0]}" "$@"
}
trap handle_interrupt INT TERM QUIT HUP

dialog --clear \
    --backtitle "$BACKTITLE" \
    --colors --color-mode 2 \
    --title "ZFS Boot Drive" \
    --msgbox "For optimal performance and efficiency, ZFS should be given entire drives.
Nordix therefore recommends installing Zfsbootmenu on a separate drive, for example a USB." 6 95

if dialog --clear \
    --backtitle "$BACKTITLE" \
    --title "Separate Boot Drive" \
    --yesno "Do you want to install zfsbootmenu on a separate drive?" 5 60 2>&1 >/dev/tty; then


    declare -A drive_map
    options=()
    count=1
    while true; do
        var_name="DRIVE_${count}"
        drive_value="${!var_name}"

        if [[ -z "$drive_value" ]]; then
            break
        fi

        by_id="${drive_value%% *}"
        human_readable="${drive_value#* }"

        drive_map["$human_readable"]="$by_id"
        options+=("$human_readable")

        ((count++))
    done

    # Build menu arguments: tag = index, item = human readable
    menu_args=()
    i=1
    for opt in "${options[@]}"; do
        menu_args+=("$i" "\Zb\Z1$opt")
        ((i++))
    done

    while true; do
        selected_index=$(dialog --clear \
            --backtitle "$BACKTITLE" \
            --no-cancel \
            --colors --color-mode 2 \
            --title "🐧Select Boot Drive🐧" \
            --menu "The selected device will be used exclusively for Zfsbootmenu and cannot be used as a system device." 0 0 0 "${menu_args[@]}" 2>&1 >/dev/tty)

        ret=$?
        if [ $ret -ne 0 ]; then
            selected_index=""
        fi

        if [ -z "$selected_index" ]; then
            selected_boot_drive=""
        else
            selected_boot_drive="${options[$((selected_index-1))]}"
        fi

        if dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "🐧Confirm Selection🐧" \
            --yesno "Confirm selected drives: $selected_boot_drive?" 0 0 2>&1 >/dev/tty; then
            break
        fi
        if [ $? -ne 0 ]; then
              # användaren tryckte Esc/Cancel -> börja om
              continue
          fi
    done

    # Write selected by-id to new config
    > "$BOOT_FILE"
    disk_count=1

    while IFS= read -r choice; do
        echo "DRIVE_${disk_count}=${drive_map[$choice]}" >> "$BOOT_FILE"
        ((disk_count++))
    done <<< "$selected_boot_drive"

    # Fix the device list to next step
    grep -v -Ff <(cut -d'=' -f2 "${BOOT_FILE}") "${MASTER_LIST}" | \
    awk -F'=' 'BEGIN { i=1 } { printf "DRIVE_%d=%s\n", i, $2; i++ }' > "${OUTPUT_FILE}"

    exit 0
else
    # Fix the device list to next step
    cp "${MASTER_LIST}" "${OUTPUT_FILE}"
    exit 1
fi
