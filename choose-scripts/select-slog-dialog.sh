#!/bin/bash
# ZFS Script 5 - Dialog version
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
MASTER_LIST="${CONFIG_DIR}/device_list_l2arc.conf"
OUTPUT_FILE="${CONFIG_DIR}/selected-slog-drives.conf"
OUTPUT_LIST_FILE="${CONFIG_DIR}/device_list_tank.conf" # reserved for upgrade path of the installer - tank pool
OUTPUT_FILE_SLOG_LAYOUT="${CONFIG_DIR}/slog-layout.conf"
source "${MASTER_LIST}"


clear
leave() {
    cp "$MASTER_LIST" "$OUTPUT_LIST_FILE"
    clear
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "Note" \
        --msgbox "A SLOG (Log) Vdev can be added later, and be removed any time" 5 60
    exit 1
}

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
    --title "SLOG Vdev - Separate Internal Log." \
    --msgbox "ZFS SLOG Vdev - Speed up synchronous writes
    - Given the choice between the performance of asynchronous writes with the integrity of synchronous writes
    - A compromise is achieved with the ZFS Intent Log or ZIL

Explanation:
     When synchronous writes are required, often for critical data, not limited to:
     - Virtual Machines, Databases, or other critical services
     The kernel needs to wait for the write to be acknowledged by the ZIL (zfs internal log) before proceeding.

HDD system will suffer from this - SLOG solves this:
    - A SLOG is a separate log device that can be a fast NVMe/SSD, synchronous write will be written to this device
    - The kernel can then proceed faster
    - The SLOG device will later write the data to the pool

RECOMMENDATION:
    - Dont use on NVMe/SSD zpool
    - Just a few Gb is enough for a SLOG Vdev ~10Gb

ACKNOWLEDGEMENT:
    - Nordix dont have support to partition the extra vdev included in the SLOG device
    - Recommendation for now: After this installation, create a small partition on a NVMe/SSD to use as a SLOG (Zvol works too)

" 25 130
if dialog --clear \
    --backtitle "$BACKTITLE" \
    --title "SLOG Vdev" \
    --colors --color-mode 2 \
    --yes-label "IWANT SPECIAL VDEV" \
    --yesno "Do you want to add a SLOG Vdev to your zpool?" 5 55 2>&1 >/dev/tty; then

OPTIONS=(
     "SLOG - Single    : 1 drive, no redundancy"
     "SLOG - Stripe    : 2+ drives, maximum speed, no redundancy (Similar to RAID0)"
     "SLOG - Mirror    : 2 drives, fault tolerant (Similar to RAID 1)"
     "Exit without SLOG"
     )

    _SLOG=""

    while true; do
        dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "SLOG Vdev" \
            --msgbox "Choose Layout For SLOG Vdev" 5 35

        menu_args=()
        i=1
        for opt in "${OPTIONS[@]}"; do
            menu_args+=("$i" "\Zb\Z1$opt")
            ((i++))
        done

        choice_idx=$(dialog --clear \
            --backtitle "$BACKTITLE" \
            --colors --color-mode 2 \
            --title "SLOG Vdev Layout" \
            --stdout --menu "A SLOG Vdev - Fast log, can be removed." 0 90 4 "${menu_args[@]}")
        ret=$?

        if [ $ret -ne 0 ] || [ -z "$choice_idx" ]; then
            if dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "Exit" \
                --yesno "Do you want to cancel Special Vdev configuration?" 5 40; then
                leave
            else
                continue
            fi
        fi

        _SPECIAL_TEXT="${OPTIONS[$((choice_idx-1))]}"


        case "$_SPECIAL_TEXT" in
            "SLOG - Single"*) _SLOG="slog-single" ;;
            "SLOG - Stripe"*) _SLOG="slog-stripe" ;;
            "SLOG - Mirror"*) _SLOG="slog-mirror" ;;
        esac

        if dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "Confirm Layout" \
            --yesno "Confirm SLOG Vdev layout: ${_SLOG}?" 5 50 2>&1 >/dev/tty; then
            echo "$_SLOG" > "${OUTPUT_FILE_SPECIAL_LAYOUT}"
            break
        fi
    done

    # Build drive arrays with deduplicated display
    drive_ids=()
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
        display="${human_readable} [${by_id##*/}]"
        drive_displays+=("$display")
        ((count++))
    done

    get_min_max_drives() {
        case "$_SLOG" in
            "slog-single") echo "1 1" ;;
            "slog-stripe") echo "2 999" ;;
            "slog-mirror") echo "2 2" ;;
        esac
    }

    read MIN_DRIVES MAX_DRIVES <<< $(get_min_max_drives)

    selected_ids=""

    while true; do
        dialog --clear \
            --backtitle "$BACKTITLE" \
            --colors --color-mode 2 \
            --title "Select Drives" \
            --msgbox "\Zb$_SPECIAL (requires \Z4$MIN_DRIVES\Z0-\Z1$MAX_DRIVES\Z0 drives)" 6 60

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
                --stdout --checklist "Select device[s] for your SLOG Vdev" 20 90 10 "${checklist_args[@]}")
            ret=$?

            if [ $ret -ne 0 ] || [ -z "$selected_tags" ]; then
                if dialog --clear \
                    --backtitle "$BACKTITLE" \
                    --title "Exit" \
                    --yesno "Do you want to cancel SLOG Vdev configuration?" 5 40; then
                    leave
                else
                    continue
                fi
            fi

            selected_ids=""
            for tag in $selected_tags; do
                idx=$((tag-1))
                selected_ids+="${drive_ids[$idx]}"$'\n'
            done
        fi

        drive_count=0
        while IFS= read -r line; do
            [[ -n "$line" ]] && ((drive_count++))
        done <<< "$selected_ids"

        if [[ $drive_count -lt $MIN_DRIVES ]]; then
            dialog --clear \
                --backtitle "$BACKTITLE" \
                --colors --color-mode 2 \
                --title "\Z1Error" \
                --msgbox "\ZbError: $_SPECIAL layout requires at least \Z4$MIN_DRIVES\Z0 drives (you selected $drive_count)" 7 70
            selected_ids=""
            continue
        fi

        if [[ $MAX_DRIVES != "999" && $drive_count -gt $MAX_DRIVES ]]; then
            dialog --clear \
                --backtitle "$BACKTITLE" \
                --colors --color-mode 2 \
                --title "\Z1Error" \
                --msgbox "\ZbError: $_SPECIAL layout allows maximum \Z1$MAX_DRIVES\Z0 drives (you selected $drive_count)" 7 70
            selected_ids=""
            continue
        fi

        # Build confirmation text
        confirm_lines=""
        while IFS= read -r id; do
            [[ -z "$id" ]] && continue
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
            --title "Confirm Drives" \
            --yesno "Confirm selected $drive_count drives:\n$confirm_text" 15 70 2>&1 >/dev/tty; then
            break
        fi
        selected_ids=""
    done

    > "$OUTPUT_FILE"
    disk_count=1
    while IFS= read -r id; do
        [[ -z "$id" ]] && continue
        echo "DRIVE_${disk_count}=$id" >> "$OUTPUT_FILE"
        ((disk_count++))
    done <<< "$selected_ids"

    grep -v -Ff <(cut -d'=' -f2 "$OUTPUT_FILE") "$MASTER_LIST" | \
    awk -F'=' 'BEGIN { i=1 } { printf "DRIVE_%d=%s\n", i, $2; i++ }' > "$OUTPUT_LIST_FILE"

    clear
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "Note" \
        --msgbox "Note: A SLOG Vdev can be added or removed at any time" 7 60
    exit 0
else
  leave
fi
