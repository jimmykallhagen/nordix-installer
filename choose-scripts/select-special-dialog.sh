#!/bin/bash
# ZFS Script 3 - Dialog version
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
MASTER_LIST="${CONFIG_DIR}/additional_drives_special.conf"
OUTPUT_FILE="${CONFIG_DIR}/selected-special-drives.conf"
OUTPUT_LIST_FILE="${CONFIG_DIR}/device_list_special.conf"
OUTPUT_FILE_SPECIAL_LAYOUT="${CONFIG_DIR}/special-layout.conf"

source "${SCRIPT_DIR}/../gum-lib/gum.conf"
source "${MASTER_LIST}"

clear
echo -ne "\e]10;${G_BASE_COLOR}\a"

BACKTITLE="Nordix Installer"

handle_interrupt() {
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "Cannot Exit" \
        --msgbox "You cant exit here" 5 25
    exec "${BASH_SOURCE[0]}" "$@"
}
trap handle_interrupt INT TERM QUIT HUP


dialog --clear \
    --backtitle "$BACKTITLE" \
    --title "Special Vdev" \
    --msgbox "ZFS Special Vdev - Metadata and small files on NVMe/SSD - Game changer for performance on HDD's" 5 100

if dialog --clear \
    --backtitle "$BACKTITLE" \
    --title "Special Vdev" \
    --yesno "Do you want to add a Special Vdev to your zpool?" 5 55 2>&1 >/dev/tty; then



    OPTIONS=(
    "SPECIAL - Single    : 1 drive, no redundancy"
    "SPECIAL - Stripe    : 2+ drives, maximum speed, no redundancy (Similar to RAID0)"
    "SPECIAL - Mirror    : 2 drives, fault tolerant (Similar to RAID 1)"
    "Exit without Special Vdev"
    )

    _SPECIAL=""

    while true; do
        dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "Special Vdev" \
            --msgbox "Choose Layout For Special Vdev" 5 35

        menu_args=()
        i=1
        for opt in "${OPTIONS[@]}"; do
            menu_args+=("$i" "$opt")
            ((i++))
        done

        choice_idx=$(dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "Special Vdev Layout" \
            --stdout --menu "A Special Vdev stores all metadata, if you lose it, you lose your entire zpool.
           Mirror is recommended." 12 90 4 "${menu_args[@]}")
        ret=$?

        if [ $ret -ne 0 ] || [ -z "$choice_idx" ]; then
            dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "Error" \
                --msgbox "Please select a layout!" 5 30
            continue
        fi

        _SPECIAL_TEXT="${OPTIONS[$((choice_idx-1))]}"

        if [[ "$_SPECIAL_TEXT" == "Exit without Special Vdev" ]]; then
            dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "Exit" \
                --msgbox "Leaving Special Vdev..." 5 30
            dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "Exit" \
                --msgbox "Maybe next time." 5 30
            exit 1
        fi

        case "$_SPECIAL_TEXT" in
            "SPECIAL - Single    : 1 drive, no redundancy") _SPECIAL="special-single" ;;
            "SPECIAL - Stripe    : 2+ drives, maximum speed, no redundancy (Similar to RAID0)") _SPECIAL="special-stripe" ;;
            "SPECIAL - Mirror    : 2 drives, fault tolerant (Similar to RAID 1)") _SPECIAL="special-mirror" ;;
        esac

        if dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "Confirm Layout" \
            --yesno "Confirm Special Vdev layout: ${_SPECIAL}?" 5 50 2>&1 >/dev/tty; then
            echo "$_SPECIAL" > "${OUTPUT_FILE_SPECIAL_LAYOUT}"
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
        case "$_SPECIAL" in
            "special-single") echo "1 1" ;;
            "special-stripe") echo "2 999" ;;
            "special-mirror") echo "2 2" ;;
        esac
    }

    read MIN_DRIVES MAX_DRIVES <<< $(get_min_max_drives)

    selected_ids=""

    while true; do
        dialog --clear --backtitle "$BACKTITLE" --title "Select Drives" --msgbox "$_SPECIAL (requires $MIN_DRIVES-$MAX_DRIVES drives)" 6 60

        if [[ -z "$selected_ids" ]]; then
            checklist_args=()
            i=1
            for disp in "${drive_displays[@]}"; do
                checklist_args+=("$i" "$disp" "OFF")
                ((i++))
            done
            selected_tags=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "Select Drives" \
                --stdout --checklist "Select drive for your Special Vdev" 20 90 10 "${checklist_args[@]}")
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
            dialog --clear --backtitle "$BACKTITLE" --title "Error" --msgbox "Error: $_SPECIAL layout requires at least $MIN_DRIVES drives (you selected $drive_count)" 7 70
            selected_ids=""
            continue
        fi

        if [[ $MAX_DRIVES != "999" && $drive_count -gt $MAX_DRIVES ]]; then
            dialog --clear --backtitle "$BACKTITLE" --title "Error" --msgbox "Error: $_SPECIAL layout allows maximum $MAX_DRIVES drives (you selected $drive_count)" 7 70
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
        confirm_text=$(printf "%s" "$confirm_lines" | head -c 200)

        if dialog --clear --backtitle "$BACKTITLE" --title "Confirm Drives" --yesno "Confirm selected $drive_count drives:\n$confirm_text" 15 70 2>&1 >/dev/tty; then
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
    dialog --clear --backtitle "$BACKTITLE" --title "Done" --msgbox "Configuring special drive is done" 6 50
    dialog --clear --backtitle "$BACKTITLE" --title "Note" --msgbox "Note: A Special Vdev can not be removed" 6 60
    exit 0

else
    cp "$MASTER_LIST" "$OUTPUT_LIST_FILE"
    clear
    dialog --clear --backtitle "$BACKTITLE" --title "Note" --msgbox "Special Vdev can be added later, but never removed" 6 60
    exit 1
fi
