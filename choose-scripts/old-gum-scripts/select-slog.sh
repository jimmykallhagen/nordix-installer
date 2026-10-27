#!/bin/bash
# ZFS Script 5
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
MASTER_LIST="${CONFIG_DIR}/device_list_l2arc.conf"
OUTPUT_FILE="${CONFIG_DIR}/selected-slog-drives.conf"
OUTPUT_LIST_FILE="${CONFIG_DIR}/device_list_tank.conf"
OUTPUT_FILE_SLOG_LAYOUT="${CONFIG_DIR}/slog-layout.conf"

source ${SCRIPT_DIR}/../gum-lib/gum.conf
source ${MASTER_LIST}

clear
echo -ne "\e]10;${G_BASE_COLOR}\a"


gum_box "ZFS SLOG - Separate Intent Log. Fast NVMe/SSD  ZFS ZIL / synkrona writes -  Great for performance on HDD's"

if gum_confirm 'Do you want to add a SLOG Vdev to your zpool?'; then

gum_spin_timer "Proceeding with SLOG setup"


# options for slog
OPTIONS=(
"SLOG - Single    : 1 drive, no redundancy"
"SLOG - Stripe    : 2+ drives, maximum speed, no redundancy (Similar to RAID0)"
"SLOG - Mirror    : 2 drives, fault tolerant (Similar to RAID 1)"
"Exit without SLOG"
)
gum_box "Starting SLOG layout selection"
gum_spin_timer "Gathering some SLOG's layout....."

while true; do
    clear
    gum_box "Choose Layout For SLOG"
    #  show the list of zpools layouts with gum_choose
    _SLOG=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose "Press Enter to choose layout")


    # handling ESC/no choise
    if [[ -z "$_SLOG" ]]; then
        clear
        gum_box_sleep "Please select a layout!" && true
        continue
    fi
    if [[ "$_SLOG" == "Exit without SLOG" ]]; then
        clear
        gum_spin_timer "Leaving SLOG..."
        gum_spin_timer "Maybe next time."
        return
    fi
    # Map the choice to a variable and break the loop
    case "$_SLOG" in
        "SLOG - Single    : 1 drive, no redundancy")                                       _SLOG="slog-single" ;;
        "SLOG - Stripe    : 2+ drives, maximum speed, no redundancy (Similar to RAID0)")   _SLOG="slog-stripe" ;;
        "SLOG - Mirror    : 2 drives, fault tolerant (Similar to RAID 1)")                 _SLOG="slog-mirror" ;;
    esac

    # Confirm the selected layout
    if gum_confirm "Confirm SLOG layout: ${_SLOG}?"; then
        # write special layout to file
        echo "$_SLOG" > "${OUTPUT_FILE_SLOG_LAYOUT}"
        break
    fi
done

declare -A drive_map

options=()
count=1
while true; do
    var_name="DRIVE_${count}"
    drive_value="${!var_name}"

    if [[ -z "$drive_value" ]]; then
        break
    fi

    #  by-id
    by_id="${drive_value%% *}"                     # "/dev/disk/by-id/ata-Samsung..."
    human_readable="${drive_value#* }"             # "Samsung SSD 860 EVO - 465.8G"

    drive_map["$human_readable"]="$by_id"
    options+=("$human_readable")

    ((count++))
done


get_min_max_drives() {
    case "$_SLOG" in
        "slog-single")       echo "1 1" ;;   # max 1 drive
        "slog-stripe")       echo "2 999" ;; # min 2, no real max
        "slog-mirror")       echo "2 2" ;;   # exactly 2 drives
        esac
}

read MIN_DRIVES MAX_DRIVES <<< $(get_min_max_drives)

echo "Layout: $_SLOG requires minimum $MIN_DRIVES and maximum $MAX_DRIVES drives"

# Read previously selected drives count (if any)
declare -a drive_choices=()
while IFS= read -r choice; do
    drive_choices+=("$choice")
done <<< "$selected_slog_drives"

current_count=${#drive_choices[@]}



# Check if previous selection is valid, otherwise clear it
if [[ $current_count -lt $MIN_DRIVES || $current_count -gt $MAX_DRIVES ]]; then
    selected_slog_drives=""
fi

while true; do
    clear
    gum_box "$_SLOG (requires $MIN_DRIVES-$MAX_DRIVES drives)"

    if [[ -z "$selected_slog_drives" ]]; then
        selected_slog_drives=$(printf "%s\n" "${options[@]}" | gum_choose_no_limit "Select drives with SPACE")
    fi

    # If no drive is selected, show an error and continue
    if [[ -z "$selected_slog_drives" ]]; then
        gum_box_sleep "Please select at least one drive!"
        continue
    fi

    # Count selected drives
    drive_count=0
    while IFS= read -r line; do
        [[ -n "$line" ]] && ((drive_count++))
    done <<< "$selected_slog_drives"

    # Validate drive count
    if [[ $drive_count -lt $MIN_DRIVES ]]; then
        gum_box_sleep "Error: $_SLOG layout requires at least $MIN_DRIVES drives (you selected $drive_count)"
        selected_slog_drives=""  # Clear selection to retry
        continue
    fi

    if [[ $MAX_DRIVES != "999" && $drive_count -gt $MAX_DRIVES ]]; then
        gum_box_sleep "Error: $_SLOG layout allows maximum $MAX_DRIVES drives (you selected $drive_count)"
        selected_slog_drives=""  # Clear selection to retry
        continue
    fi

    # Confirm drivers to be installed
    if gum_confirm "Confirm selected $drive_count drives: $selected_slog_drives?"; then
        break
    fi
    selected_slog_drives=""  # Clear selection to retry
done



# Write selected by-id to new config
> ${CONFIG_DIR}/selected-slog-drives.conf
disk_count=1

while IFS= read -r choice; do
    echo "DRIVE_${disk_count}=${drive_map[$choice]}" >> "$OUTPUT_FILE"
    ((disk_count++))
done <<< "$selected_slog_drives"

grep -v -Ff <(cut -d'=' -f2 "${OUTPUT_FILE}") "${MASTER_LIST}" | \
awk -F'=' 'BEGIN { i=1 } { printf "DRIVE_%d=%s\n", i, $2; i++ }' > "${OUTPUT_LIST_FILE}"

clear
gum_spin_timer 'Configuring SLOG drive is done'
gum_spin_timer 'Note: A SLOG can be removed at any time'
exit 0

 else
# Fix the device list to next step
cp "${MASTER_LIST}" "${OUTPUT_LIST_FILE}"

 clear
 gum_spin_timer "SLOG can be added later"

exit 1
fi
