#!/bin/bash
# ZFS Script 2 - Dialog version
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
MASTER_LIST="${CONFIG_DIR}/device-list-vdev.conf"
ZFS_VDEV_INFO="${SCRIPT_DIR}/../info/zfs-info-vdev"

source "$MASTER_LIST"

unset ZPOOL CHOICE

clear


handle_interrupt() {
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --colors --color-mode 2 \
        --title "\ZbCannot Exit" \
        --msgbox "\Z1You cant exit here" 5 25
    exec "${BASH_SOURCE[0]}" "$@"
}
trap handle_interrupt INT TERM QUIT HUP

BACKTITLE="Nordix Installer"



OPTIONS=(
"ZFS Single           : 1  drive, no redundancy"
"ZFS Stripe           : 2+ drives, maximum speed and storage space, no redundancy (Similar to RAID0)"
"ZFS Mirror           : 2  drives, fault tolerant (Similar to RAID 1)"
"ZFS Striped_Mirror   : 4  drives, fast & safe (Similar to RAID 10)"
"ZFS RAIDZ            : 3+ drives, balanced safety/space (Similar to RAID 5)"
"ZFS RAIDZ2           : 5+ drives, balanced safety/space (Similar to RAID 6)"
"ZFS RAIDZ3           : 7+ drives, balanced safety/space"
)

while true; do

    dialog --clear \
        --backtitle "$BACKTITLE" \
        --colors --color-mode 2 \
        --title "Zpool Layouts" \
        --msgbox "Choose Zpool Layouts" 5 25

    # Build menu args, skip empty entries
    menu_args=()
    i=1
    for opt in "${OPTIONS[@]}"; do
        [[ -z "$opt" ]] && continue
        menu_args+=("$i" "\Zb\Z1$opt")
        ((i++))
    done

    CHOICE=$(dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "\Zb\Z0Zpool Layouts" \
        --no-cancel --colors --color-mode 2 \
        --help-button \
        --stdout --menu "\Zb\Z4Choose wisely" 0 90 9 "${menu_args[@]}")
    ret=$?

    if [ $ret -eq 2 ]; then
        dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "Help" \
            --colors \
            --color-mode 2 \
            --textbox "$ZFS_VDEV_INFO" 90 110

        continue
    fi

    if [ $ret -ne 0 ] || [ -z "$CHOICE" ]; then
        dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "\Zb\Z1Error" \
            --colors --color-mode 2 \
            --msgbox "Please select a layout!" 6 50
        continue
    fi


    # Map menu index back to actual option text
    # Rebuild array without empties to find text
    opt_index=0
    for opt in "${OPTIONS[@]}"; do
        [[ -z "$opt" ]] && continue
        ((opt_index++))
        if [ "$opt_index" -eq "$CHOICE" ]; then
            CHOICE_TEXT="$opt"
            break
        fi
    done



    case "$CHOICE_TEXT" in
        "ZFS Single           : 1  drive, no redundancy") ZPOOL="single" ;;
        "ZFS Stripe           : 2+ drives, maximum speed and storage space, no redundancy (Similar to RAID0)") ZPOOL="stripe" ;;
        "ZFS Mirror           : 2  drives, fault tolerant (Similar to RAID 1)") ZPOOL="zfs-mirror" ;;
        "ZFS Striped-Mirror   : 4  drives, fast & safe (Similar to RAID 10)") ZPOOL="stripe-mirror" ;;
        "ZFS RAIDZ            : 3+ drives, balanced safety/space (Similar to RAID 5)") ZPOOL="zfs-raidz" ;;
        "ZFS RAIDZ2           : 5+ drives, balanced safety/space (Similar to RAID 6)") ZPOOL="zfs-raidz2" ;;
        "ZFS RAIDZ3           : 7+ drives, balanced safety/space") ZPOOL="zfs-raidz3" ;;
    esac
    if [[ "$CHOICE_TEXT" == "---" ]]; then
        dialog --clear \
            --backtitle "$BACKTITLE" \
            --colors --color-mode 2 \
            --title "\Zb\Z1Error" \
            --msgbox "Please select a layout!" 6 50
        continue
    fi
    IWANT=$(echo $CHOICE_TEXT | awk '{print $2}')
    if dialog --clear \
        --backtitle "$BACKTITLE" \
        --colors --color-mode 2 \
        --title "\ZbConfirm Layout" \
        --yes-label "I want \Z4$IWANT" \
        --yesno "Confirm zpool vdev Layout:
        ${CHOICE_TEXT}?" 6 100 2>&1 >/dev/tty; then
        break
    fi
done

sed -i '/^ZPOOL=/d' "${CONFIG_DIR}/selected-zpool-layout.conf"
echo "ZPOOL=\"$ZPOOL\"" >> "${CONFIG_DIR}/selected-zpool-layout.conf"


##---------------------DUBBLE-SCRIPT-IT-IS---------------------------##
######################################
# Chose devices/drives for the zpool #
######################################
clear

declare -a drive_ids
drive_names=()
drive_displays=()
count=1
while true; do
    var_name="DRIVE_${count}"
    drive_value="${!var_name}"
    [[ -z "$drive_value" ]] && break
    by_id="${drive_value%% *}"
    human_readable="${drive_value#* }"
    drive_ids+=("$by_id")
    drive_names+=("$human_readable")
    # Make display unique to avoid duplicate human readable names
    display="${human_readable} [${by_id##*/}]"
    drive_displays+=("$display")
    ((count++))
done

get_min_max_drives() {
    case "$ZPOOL" in
        "single")           echo "1 1" ;;
        "stripe")           echo "2 999" ;;
        "zfs-mirror")       echo "2 2" ;;
        "striped-mirror")   echo "4 4" ;;
        "zfs-raidz")        echo "3 999" ;;
        "zfs-raidz2")       echo "5 999" ;;
        "zfs-raidz3")       echo "7 999" ;;
    esac
}

read MIN_DRIVES MAX_DRIVES <<< $(get_min_max_drives)

selected_ids=""

while true; do
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "Select Devices" \
        --colors --color-mode 2 \
        --msgbox "\Zb$ZPOOL (requires \Zb\Z4$MIN_DRIVES\Z0-\Zb\Z1$MAX_DRIVES \Z0drives)" 5 39

    if [[ -z "$selected_ids" ]]; then
        checklist_args=()
        i=1
        for disp in "${drive_displays[@]}"; do
            checklist_args+=("$i" "\Zb\Z1$disp" "OFF")
            ((i++))
        done
        selected_tags=$(dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "Select Devices" \
            --colors --color-mode 2 \
            --stdout --checklist "\Z4Select device[s] for your root Zpool" 20 80 10 "${checklist_args[@]}")
        ret=$?
        if [ $ret -ne 0 ] || [ -z "$selected_tags" ]; then
            dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "Error" \
                --msgbox "Please select at least one drive!" 6 50
            continue
        fi
        # Convert tags to by-id list
        selected_ids=""
        for tag in $selected_tags; do
            idx=$((tag-1))
            selected_ids+="${drive_ids[$idx]}"$'\n'
        done
    fi

    # Count selected drives
    drive_count=0
    while IFS= read -r line; do
        [[ -n "$line" ]] && ((drive_count++))
    done <<< "$selected_ids"

    if [[ $drive_count -lt $MIN_DRIVES ]]; then
        dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "\Zb\Z1Error" \
            --colors --color-mode 2 \
            --msgbox "\Zb\Z1Error:\Z0 $ZPOOL layout requires at least \Z4$MIN_DRIVES\Z0 drives (you selected $drive_count)" 7 70
        selected_ids=""
        continue
    fi

    if [[ $MAX_DRIVES != "999" && $drive_count -gt $MAX_DRIVES ]]; then
        dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "\Zb\Z1Error" \
            --colors --color-mode 2 \
            --msgbox "\Zb\Z1Error:\Z0 $ZPOOL layout allows maximum \Z4$MAX_DRIVES\Z0 drives (you selected $drive_count)" 7 70
        selected_ids=""
        continue
    fi

    # Build confirmation text from human readable names
    confirm_lines=""
    while IFS= read -r id; do
        [[ -z "$id" ]] && continue
        # find matching human readable name
        for idx in "${!drive_ids[@]}"; do
            if [[ "${drive_ids[$idx]}" == "$id" ]]; then
                confirm_lines+="${drive_names[$idx]}"$'\n'
                break
            fi
        done
    done <<< "$selected_ids"
    confirm_text=$(printf "%s" "$confirm_lines")
    if dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "Confirm Devices" \
        --yesno "Confirm selected $drive_count devices:\n$confirm_text" 0 0 2>&1 >/dev/tty; then
        break
    fi
    selected_ids=""
done

> "$SCRIPT_DIR/../config/selected_drives.conf"
disk_count=1
while IFS= read -r id; do
    [[ -z "$id" ]] && continue
    echo "DRIVE_${disk_count}=$id" >> "$SCRIPT_DIR/../config/selected_drives.conf"
    ((disk_count++))
done <<< "$selected_ids"

grep -v -Ff <(cut -d'=' -f2 "$SCRIPT_DIR/../config/selected_drives.conf") "$MASTER_LIST" | \
awk -F'=' 'BEGIN { i=1 } { printf "DRIVE_%d=%s\n", i, $2; i++ }' > "$SCRIPT_DIR/../config/additional_drives_special.conf"
