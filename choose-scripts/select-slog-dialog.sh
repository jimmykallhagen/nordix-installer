#!/bin/bash
# ZFS Script 5 - Dialog version
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
MASTER_LIST="${CONFIG_DIR}/device_list_l2arc.conf"
OUTPUT_FILE="${CONFIG_DIR}/selected-slog-drives.conf"
OUTPUT_LIST_FILE="${CONFIG_DIR}/device_list_tank.conf"
OUTPUT_FILE_SLOG_LAYOUT="${CONFIG_DIR}/slog-layout.conf"

source "${SCRIPT_DIR}/../gum-lib/gum.conf"
source "${MASTER_LIST}"

clear
echo -ne "\e]10;${G_BASE_COLOR}\a"

BACKTITLE="Nordix Installer"

dialog --clear --backtitle "$BACKTITLE" --title "SLOG" --msgbox "ZFS SLOG - Separate Intent Log. Fast NVMe/SSD  ZFS ZIL / synkrona writes -  Great for performance on HDD's" 10 70

if dialog --clear --backtitle "$BACKTITLE" --title "SLOG" --yesno "Do you want to add a SLOG Vdev to your zpool?" 10 60 2>&1 >/dev/tty; then

    sleep 1

    OPTIONS=(
    "SLOG - Single    : 1 drive, no redundancy"
    "SLOG - Stripe    : 2+ drives, maximum speed, no redundancy (Similar to RAID0)"
    "SLOG - Mirror    : 2 drives, fault tolerant (Similar to RAID 1)"
    "Exit without SLOG"
    )

    dialog --clear --backtitle "$BACKTITLE" --title "SLOG" --msgbox "Starting SLOG layout selection" 6 50
    sleep 1

    _SLOG=""

    while true; do
        dialog --clear --backtitle "$BACKTITLE" --title "SLOG" --msgbox "Choose Layout For SLOG" 6 50

        menu_args=()
        i=1
        for opt in "${OPTIONS[@]}"; do
            menu_args+=("$i" "$opt")
            ((i++))
        done

        choice_idx=$(dialog --clear --backtitle "$BACKTITLE" --title "SLOG Layout" \
            --stdout --menu "Press Enter to choose layout" 15 70 4 "${menu_args[@]}")
        ret=$?
        if [ $ret -ne 0 ] || [ -z "$choice_idx" ]; then
            dialog --clear --backtitle "$BACKTITLE" --title "Error" --msgbox "Please select a layout!" 6 50
            continue
        fi

        _SLOG_TEXT="${OPTIONS[$((choice_idx-1))]}"

        if [[ "$_SLOG_TEXT" == "Exit without SLOG" ]]; then
            dialog --clear --backtitle "$BACKTITLE" --title "Exit" --msgbox "Leaving SLOG..." 6 50
            dialog --clear --backtitle "$BACKTITLE" --title "Exit" --msgbox "Maybe next time." 6 50
            exit 1
        fi

        case "$_SLOG_TEXT" in
            "SLOG - Single    : 1 drive, no redundancy") _SLOG="slog-single" ;;
            "SLOG - Stripe    : 2+ drives, maximum speed, no redundancy (Similar to RAID0)") _SLOG="slog-stripe" ;;
            "SLOG - Mirror    : 2 drives, fault tolerant (Similar to RAID 1)") _SLOG="slog-mirror" ;;
        esac

        if dialog --clear --backtitle "$BACKTITLE" --title "Confirm Layout" --yesno "Confirm SLOG layout: ${_SLOG}?" 10 60 2>&1 >/dev/tty; then
            echo "$_SLOG" > "${OUTPUT_FILE_SLOG_LAYOUT}"
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
        dialog --clear --backtitle "$BACKTITLE" --title "Select Drives" --msgbox "$_SLOG (requires $MIN_DRIVES-$MAX_DRIVES drives)" 6 60

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
            dialog --clear --backtitle "$BACKTITLE" --title "Error" --msgbox "Error: $_SLOG layout requires at least $MIN_DRIVES drives (you selected $drive_count)" 7 70
            selected_ids=""
            continue
        fi

        if [[ $MAX_DRIVES != "999" && $drive_count -gt $MAX_DRIVES ]]; then
            dialog --clear --backtitle "$BACKTITLE" --title "Error" --msgbox "Error: $_SLOG layout allows maximum $MAX_DRIVES drives (you selected $drive_count)" 7 70
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
    dialog --clear --backtitle "$BACKTITLE" --title "Done" --msgbox "Configuring SLOG drive is done" 6 50
    dialog --clear --backtitle "$BACKTITLE" --title "Note" --msgbox "Note: A SLOG can be removed at any time" 6 60
    exit 0

else
    cp "$MASTER_LIST" "$OUTPUT_LIST_FILE"
    clear
    dialog --clear --backtitle "$BACKTITLE" --title "Note" --msgbox "SLOG can be added later" 6 60
    exit 1
fi
