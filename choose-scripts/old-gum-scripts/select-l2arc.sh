#!/bin/bash
# ZFS Script 4
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
MASTER_LIST="${CONFIG_DIR}/device_list_special.conf"
OUTPUT_FILE="${CONFIG_DIR}/selected-l2arc-drives.conf"
OUTPUT_LIST_FILE="${CONFIG_DIR}/device_list_l2arc.conf"
OUTPUT_FILE_L2ARC_LAYOUT="${CONFIG_DIR}/l2arc-layout.conf"

source ${SCRIPT_DIR}/../gum-lib/gum.conf
source ${MASTER_LIST}

clear
echo -ne "\e]10;${G_BASE_COLOR}\a"


gum_box "ZFS L2ARC - NVMe/SSD as extended cache - Great for performance on HDD's"

if gum_confirm 'Do you want to add a L2ARC to your zpool?'; then

gum_spin_timer "Proceeding with L2ARC setup"

# options for slog
OPTIONS=(
"L2ARC - Single    : 1 drive, no redundancy"
"L2ARC - Stripe    : 2+ drives, maximum speed, no redundancy (Similar to RAID0)"
"L2ARC - Mirror    : 2 drives, fault tolerant (Similar to RAID 1)"
"Exit without L2ARC"
)
gum_box "Starting L2ARC layout selection"
gum_spin_timer "Gathering some L2ARC's layout....."

while true; do
    clear
    gum_box "Choose Layout For L2ARC"
    #  show the list of zpools layouts with gum_choose
    _L2ARC=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose "Press Enter to choose")

    # handling ESC/no choise
    if [[ -z "$_L2ARC" ]]; then
        clear
        gum_box_sleep "Please select a layout!" && true
        continue
    fi
    if [[ "$_L2ARC" == "Exit without L2ARC" ]]; then
        clear
        gum_spin_timer "Leaving L2ARC..."
        gum_spin_timer "Maybe next time."
        return
    fi
    # Map the choice to a variable and break the loop
    case "$_L2ARC" in
        "L2ARC - Single    : 1 drive, no redundancy")                                       _L2ARC="l2arc-single" ;;
        "L2ARC - Stripe    : 2+ drives, maximum speed, no redundancy (Similar to RAID0)")   _L2ARC="l2arc-stripe" ;;
        "L2ARC - Mirror    : 2 drives, fault tolerant (Similar to RAID 1)")                 _L2ARC="l2arc-mirror" ;;
    esac

    # Confirm the selected layout
    if gum_confirm "Confirm L2ARC layout: ${_L2ARC}?"; then
        # write special layout to file
        echo "$_L2ARC" > "${OUTPUT_FILE_L2ARC_LAYOUT}"
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
    case "$_L2ARC" in
        "l2arc-single")       echo "1 1" ;;   # max 1 drive
        "l2arc-stripe")       echo "2 999" ;; # min 2, no real max
        "l2arc-mirror")       echo "2 2" ;;   # exactly 2 drives
        esac
}

read MIN_DRIVES MAX_DRIVES <<< $(get_min_max_drives)

echo "Layout: $_L2ARC requires minimum $MIN_DRIVES and maximum $MAX_DRIVES drives"

# Read previously selected drives count (if any)
declare -a drive_choices=()
while IFS= read -r choice; do
    drive_choices+=("$choice")
done <<< "$selected_l2arc_drives"

current_count=${#drive_choices[@]}



# Check if previous selection is valid, otherwise clear it
if [[ $current_count -lt $MIN_DRIVES || $current_count -gt $MAX_DRIVES ]]; then
    selected_l2arc_drives=""
fi

while true; do
    clear
    gum_box "$_L2ARC (requires $MIN_DRIVES-$MAX_DRIVES drives)"

    if [[ -z "$selected_l2arc_drives" ]]; then
        selected_l2arc_drives=$(printf "%s\n" "${options[@]}" | gum_choose_no_limit "Select drive with SPACE")
    fi

    # If no drive is selected, show an error and continue
    if [[ -z "$selected_l2arc_drives" ]]; then
        gum_box_sleep "Please select at least one drive!"
        continue
    fi

    # Count selected drives
    drive_count=0
    while IFS= read -r line; do
        [[ -n "$line" ]] && ((drive_count++))
    done <<< "$selected_l2arc_drives"

    # Validate drive count
    if [[ $drive_count -lt $MIN_DRIVES ]]; then
        gum_box_sleep "Error: $_L2ARC layout requires at least $MIN_DRIVES drives (you selected $drive_count)"
        selected_l2arc_drives=""  # Clear selection to retry
        continue
    fi

    if [[ $MAX_DRIVES != "999" && $drive_count -gt $MAX_DRIVES ]]; then
        gum_box_sleep "Error: $_L2ARC layout allows maximum $MAX_DRIVES drives (you selected $drive_count)"
        selected_l2arc_drives=""  # Clear selection to retry
        continue
    fi

    # Confirm drivers to be installed
    if gum_confirm "Confirm selected $drive_count drives: $selected_l2arc_drives?"; then
        break
    fi
    selected_l2arc_drives=""  # Clear selection to retry
done



# Write selected by-id to new config
> ${CONFIG_DIR}/selected-l2arc-drives.conf
disk_count=1

while IFS= read -r choice; do
    echo "DRIVE_${disk_count}=${drive_map[$choice]}" >> "$OUTPUT_FILE"
    ((disk_count++))
done <<< "$selected_l2arc_drives"

grep -v -Ff <(cut -d'=' -f2 "${OUTPUT_FILE}") "${MASTER_LIST}" | \
awk -F'=' 'BEGIN { i=1 } { printf "DRIVE_%d=%s\n", i, $2; i++ }' > "${OUTPUT_LIST_FILE}"

clear
gum_spin_timer 'Configuring L2ARC drive is done'
gum_spin_timer 'Note: A L2ARC can be removed at any time'
exit 0

 else
# Fix the device list to next step
cp "${MASTER_LIST}" "${OUTPUT_LIST_FILE}"

 clear
 gum_spin_timer "L2ARC Vdev can be added later"

exit 1
fi
