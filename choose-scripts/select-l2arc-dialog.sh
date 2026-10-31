#!/bin/bash
# ZFS Script 4 - Dialog version
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
MASTER_LIST="${CONFIG_DIR}/device_list_special.conf"
OUTPUT_FILE="${CONFIG_DIR}/selected-l2arc-drives.conf"
OUTPUT_LIST_FILE="${CONFIG_DIR}/device_list_l2arc.conf"
OUTPUT_FILE_L2ARC_LAYOUT="${CONFIG_DIR}/l2arc-layout.conf"

source "${MASTER_LIST}"

clear
BACKTITLE="Nordix Installer"

# Cant run Ctrl + C to exit
handle_interrupt() {
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --colors --color-mode 2 \
        --title "Cannot Exit" \
        --msgbox "\Z1You cant exit here" 5 25
    exec "${BASH_SOURCE[0]}" "$@"
}
trap handle_interrupt INT TERM QUIT HUP

# info
dialog --clear \
    --backtitle "$BACKTITLE" \
    --title "L2ARC" \
    --msgbox "ZFS L2ARC - NVMe/SSD as extended cache - Great for performance on HDD's" 5 75


    OPTIONS=(
    "L2ARC - Single    : 1 drive, no redundancy"
    "L2ARC - Stripe    : 2+ drives, maximum speed, no redundancy (Similar to RAID0)"
    "L2ARC - Mirror    : 2 drives, fault tolerant (Similar to RAID 1)"
    )
    _L2ARC=""




    if dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "🐧L2ARC🐧" \
        --yeslabel "I WANT L2ARC" \
        --yesno "Do you want to add a L2ARC to your zpool?" 10 60 2>&1 >/dev/tty; then

            dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "L2ARC" \
                --msgbox "Choose Layout For L2ARC" 5 40

        while true; do

            dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "L2ARC" \
                --msgbox "Choose Layout For L2ARC" 5 40

        menu_args=()
        i=1
        for opt in "${OPTIONS[@]}"; do
            menu_args+=("$i" "\Zb\Z1$opt")
            ((i++))
        done

        choice_idx=$(dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "L2ARC Layout" \
            --colors --color-mode 2 \
            --stdout --menu "\Z4| Choose L2ARC layout" 15 70 4 "${menu_args[@]}")

        ret=$?
        if [ $ret -ne 0 ] || [ -z "$choice_idx" ]; then
            dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "Exit" \
                --msgbox "Maybe next time." 5 40
                cp "$MASTER_LIST" "$OUTPUT_LIST_FILE"    cp "$MASTER_LIST" "$OUTPUT_LIST_FILE"

            exit 1
        fi

        _L2ARC_TEXT="${OPTIONS[$((choice_idx-1))]}"


        case "$_L2ARC_TEXT" in
            "L2ARC - Single    : 1 drive, no redundancy") _L2ARC="l2arc-single" ;;
            "L2ARC - Stripe    : 2+ drives, maximum speed, no redundancy (Similar to RAID0)") _L2ARC="l2arc-stripe" ;;
            "L2ARC - Mirror    : 2 drives, fault tolerant (Similar to RAID 1)") _L2ARC="l2arc-mirror" ;;
        esac

        if dialog --clear --backtitle "$BACKTITLE" --title "Confirm Layout" --yesno "Confirm L2ARC layout: ${_L2ARC}?" 10 60 2>&1 >/dev/tty; then
            echo "$_L2ARC" > "${OUTPUT_FILE_L2ARC_LAYOUT}"
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
        case "$_L2ARC" in
            "l2arc-single") echo "1 1" ;;
            "l2arc-stripe") echo "2 999" ;;
            "l2arc-mirror") echo "2 2" ;;
        esac
    }

    read MIN_DRIVES MAX_DRIVES <<< $(get_min_max_drives)

    selected_ids=""

    while true; do
        dialog --clear --backtitle "$BACKTITLE" --title "Select Drives" --msgbox "$_L2ARC (requires $MIN_DRIVES-$MAX_DRIVES drives)" 6 60

        if [[ -z "$selected_ids" ]]; then
            checklist_args=()
            i=1
            for disp in "${drive_displays[@]}"; do
                checklist_args+=("$i" "$disp" "OFF")
                ((i++))
            done
            selected_tags=$(dialog --clear --backtitle "$BACKTITLE" --title "Select Drives" \
                --stdout --checklist "Select drive with SPACE, Enter to confirm" 20 90 10 "${checklist_args[@]}")
            ret=$?
            if [ $ret -ne 0 ] || [ -z "$selected_tags" ]; then
                dialog --clear --backtitle "$BACKTITLE" --title "Error" --msgbox "Please select at least one drive!" 6 50
                continue
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
            dialog --clear --backtitle "$BACKTITLE" --title "Error" --msgbox "Error: $_L2ARC layout requires at least $MIN_DRIVES drives (you selected $drive_count)" 7 70
            selected_ids=""
            continue
        fi

        if [[ $MAX_DRIVES != "999" && $drive_count -gt $MAX_DRIVES ]]; then
            dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "Error" \
                --msgbox "Error: $_L2ARC layout allows maximum $MAX_DRIVES drives (you selected $drive_count)" 7 70
            selected_ids=""
            continue
        fi

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
            --title "🐧Confirm Drives🐧" \
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
        --title "🐧🐧🐧" \
        --msgbox "Note: A L2ARC can be removed at any time" 6 60
    exit 0

else
    cp "$MASTER_LIST" "$OUTPUT_LIST_FILE"
    clear
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "🐧🐧🐧" \
        --msgbox "L2ARC Vdev can be added later" 6 60
    exit 1

fi
