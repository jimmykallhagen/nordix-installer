#!/bin/bash
# ZFS Script 3
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
MASTER_LIST="${CONFIG_DIR}/additional_drives_special.conf"
OUTPUT_FILE="$CONFIG_DIR/selected-special-drives.conf"
OUTPUT_LIST_FILE="${CONFIG_DIR}/device_list_special.conf"
OUTPUT_FILE_SPECIAL_LAYOUT="${CONFIG_DIR}/special-layout.conf"

source ${SCRIPT_DIR}/../gum-lib/gum.conf
source ${MASTER_LIST}

clear
echo -ne "\e]10;${G_BASE_COLOR}\a"


gum_box "ZFS Special Vdev - Metadata and small files on NVMe/SSD - Game changer for performance on HDD's"

if gum_confirm "Do you want to add a Special Vdev to your zpool?"; then

gum_spin_timer "Proceeding with Special Vdev setup"

# options for Special Vdev
OPTIONS=(
"SPECIAL - Single    : 1 drive, no redundancy"
"SPECIAL - Stripe    : 2+ drives, maximum speed, no redundancy (Similar to RAID0)"
"SPECIAL - Mirror    : 2 drives, fault tolerant (Similar to RAID 1)"
"Exit without Special Vdev"
)
gum_box "Starting Special Vdev layout selection"
gum_spin_timer "Gathering some Special Vdev's layout....."

while true; do
    clear
    gum_box "Choose Layout For Special Vdev"
    #  show the list of zpools layouts with gum_choose
    _SPECIAL=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose "Press Enter to choose layout")

    # handling ESC/no choise
    if [[ -z "$_SPECIAL" ]]; then
        clear
        gum_box_sleep "Please select a layout!" && true
        continue
    fi
    if [[ "$_SPECIAL" == "Exit without Special Vdev" ]]; then
        clear
        gum_spin_timer "Leaving Special Vdev..."
    gum_spin_timer "Maybe next time."
        return
    fi
    # Map the choice to a variable and break the loop
    case "$_SPECIAL" in
        "SPECIAL - Single    : 1 drive, no redundancy")                                       _SPECIAL="special-single" ;;
        "SPECIAL - Stripe    : 2+ drives, maximum speed, no redundancy (Similar to RAID0)")   _SPECIAL="special-stripe" ;;
        "SPECIAL - Mirror    : 2 drives, fault tolerant (Similar to RAID 1)")                 _SPECIAL="special-mirror" ;;
    esac

    # Confirm the selected layout
    if gum_confirm "Confirm Special Vdev layout: ${_SPECIAL}?"; then
        # write special layout to file
        echo "$_SPECIAL" > "${OUTPUT_FILE_SPECIAL_LAYOUT}"
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
    case "$_SPECIAL" in
        "special-single")       echo "1 1" ;;   # max 1 drive
        "special-stripe")       echo "2 999" ;; # min 2, no real max
        "special-mirror")       echo "2 2" ;;   # exactly 2 drives
        esac
}

read MIN_DRIVES MAX_DRIVES <<< $(get_min_max_drives)

echo "Layout: $_SPECIAL requires minimum $MIN_DRIVES and maximum $MAX_DRIVES drives"

# Read previously selected drives count (if any)
declare -a drive_choices=()
while IFS= read -r choice; do
    drive_choices+=("$choice")
done <<< "$selected_special_drives"

current_count=${#drive_choices[@]}



# Check if previous selection is valid, otherwise clear it
if [[ $current_count -lt $MIN_DRIVES || $current_count -gt $MAX_DRIVES ]]; then
    selected_special_drives=""
fi

while true; do
    clear
    gum_box "$_SPECIAL (requires $MIN_DRIVES-$MAX_DRIVES drives)"

    if [[ -z "$selected_special_drives" ]]; then
        selected_special_drives=$(printf "%s\n" "${options[@]}" | gum_choose_no_limit "Select drive with SPACE")
    fi

    # If no drive is selected, show an error and continue
    if [[ -z "$selected_special_drives" ]]; then
        gum_box_sleep "Please select at least one drive!"
        continue
    fi

    # Count selected drives
    drive_count=0
    while IFS= read -r line; do
        [[ -n "$line" ]] && ((drive_count++))
    done <<< "$selected_special_drives"

    # Validate drive count
    if [[ $drive_count -lt $MIN_DRIVES ]]; then
        gum_box_sleep "Error: $_SPECIAL layout requires at least $MIN_DRIVES drives (you selected $drive_count)"
        selected_special_drives=""  # Clear selection to retry
        continue
    fi

    if [[ $MAX_DRIVES != "999" && $drive_count -gt $MAX_DRIVES ]]; then
        gum_box_sleep "Error: $_SPECIAL layout allows maximum $MAX_DRIVES drives (you selected $drive_count)"
        selected_special_drives=""  # Clear selection to retry
        continue
    fi

    # Confirm drivers to be installed
    if gum_confirm "Confirm selected $drive_count drives: $selected_special_drives?"; then
        break
    fi
    selected_special_drives=""  # Clear selection to retry
done



# Write selected by-id to new config
> ${CONFIG_DIR}/selected-special-drives.conf
disk_count=1

while IFS= read -r choice; do
    echo "DRIVE_${disk_count}=${drive_map[$choice]}" >> "$OUTPUT_FILE"
    ((disk_count++))
done <<< "$selected_special_drives"

grep -v -Ff <(cut -d'=' -f2 "${OUTPUT_FILE}") "${MASTER_LIST}" | \
awk -F'=' 'BEGIN { i=1 } { printf "DRIVE_%d=%s\n", i, $2; i++ }' > "${OUTPUT_LIST_FILE}"

clear
gum_spin_timer 'Configuring special drive is done'
gum_spin_timer 'Note: A Special Vdev can not be removed'
exit 0

 else
# Fix the device list to next step
cp "${MASTER_LIST}" "${OUTPUT_LIST_FILE}"

 clear
 gum_spin_timer "Special Vdev can be added later, but never removed"

exit 1
fi
