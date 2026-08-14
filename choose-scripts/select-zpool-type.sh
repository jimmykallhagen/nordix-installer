#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf
ZFS_INFO_ADVANCED="${SCRIPT_DIR}/../info/zfs-info-advanced"
ZFS_INFO_VDEV="${SCRIPT_DIR}/../info/zfs-info-vdev"
MASTER_LIST="$SCRIPT_DIR/../config/selected_drives.conf"
source $SCRIPT_DIR/../config/drives.conf

CONFIG_DIR="${SCRIPT_DIR}/../config"


unset ZPOOL CHOICE

# Set base color for the installer
echo -ne "\e]10;${G_BASE_COLOR}\a"
# Help section

# Nordix intro

# Choose options for Zpool layouts
OPTIONS=(
"Nordix ZFS Help"
"ZFS Single : 1 drive, no redundancy"
"ZFS Stripe : 2+ drives, maximum speed, no redundancy (Similar to RAID0)"
"ZFS Mirror : 2 drives, fault tolerant (Similar to RAID 1)"
"ZFS Stripe + Mirror : 4+ drives, fast & safe (Similar to RAID 10)"
"ZFS RAIDZ : 3+ drives, balanced safety/space (Similar to RAID 5)"
"ZFS RAIDZ2 : 5+ drives, balanced safety/space (Similar to RAID 6)"
"ZFS RAIDZ3 : 7+ drives, balanced safety/space"

)
clear
gum_box "Starting Zpool layout selection"
gum_spin_timer "Gathering some Zpool layout....."


while true; do
    clear
    gum_box "Choose Zpool Layouts"
    #  show the list of zpools layouts with gum_choose
    CHOICE=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose "Press Enter to choose")

    # handling ESC/no choise

    if [[ -z "$CHOICE" ]]; then
        clear
        gum_box_sleep "Please select a layout!" && true
        continue
    fi

    # show help
    if [[ "$CHOICE" == "Nordix ZFS Help" ]]; then
        clear
        gum_spin_timer "Gather info..." && true
        gum_pager < "${ZFS_INFO_VDEV}"
        gum_spin_timer "Now you know..."
        continue
    fi

    # Map the choice to a variable and break the loop
    case "$CHOICE" in
        "ZFS Single : 1 drive, no redundancy")                                       ZPOOL="single" ;;
        "ZFS Stripe : 2+ drives, maximum speed, no redundancy (Similar to RAID0)")   ZPOOL="stripe" ;;
        "ZFS Mirror : 2 drives, fault tolerant (Similar to RAID 1)")                 ZPOOL="zfs-mirror" ;;
        "ZFS Stripe + Mirror : 4+ drives, fast & safe (RAID 10)")                    ZPOOL="stripe-mirror" ;;
        "ZFS RAIDZ : 3+ drives, balanced safety/space (Similar to RAID 5)")          ZPOOL="zfs-raidz" ;;
        "ZFS RAIDZ2 : 5+ drives, balanced safety/space (Similar to RAID 6)")         ZPOOL="zfs-raidz2" ;;
        "ZFS RAIDZ3 : 7+ drives, balanced safety/space")                             ZPOOL="zfs-raidz3" ;;
    esac

    # Confirm the selected layout
    if gum_confirm "Confirm zpool vdev Layout: ${CHOICE}?"; then
        break
    fi
done

# Write selectet layout to zpool.conf
sed -i '/^ZPOOL=/d' "${CONFIG_DIR}/selected-zpool-layout.conf"
echo "ZPOOL=\"$ZPOOL\"" >> "${CONFIG_DIR}/selected-zpool-layout.conf"

# Now we're done, clear the screen and show a completion message
clear
gum_spin_timer "Zpool layout selection complete"


##---------------------------------------------------------------------------##
######################################
# Chose devices/drives for the zpool #
######################################



clear

# Get the drives/devices in human readable format
declare -A drive_map

options_devices=()
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

    drive_map["${human_readable}"]="$by_id"
    options_devices+=("${human_readable}")

    ((count++))
done
# Validate minimum/maximum drives based on ZPOOL layout
get_min_max_drives() {
    case "$ZPOOL" in
        "single")       echo "1 1" ;;   # max 1 drive
        "stripe")       echo "2 999" ;; # min 2, no real max
        "zfs-mirror")   echo "2 2" ;;   # exactly 2 drives
        "stripe-mirror") echo "4 4" ;;  # exactly 4 drives
        "zfs-raidz")    echo "3 999" ;; # min 3, no real max
        "zfs-raidz2")   echo "5 999" ;; # min 5, no real max
        "zfs-raidz3")   echo "7 999" ;; # min 7, no real max
    esac
}

read MIN_DRIVES MAX_DRIVES <<< $(get_min_max_drives)

echo "Layout: $ZPOOL requires minimum $MIN_DRIVES and maximum $MAX_DRIVES drives"

# Read previously selected drives count (if any)
declare -a drive_choices=()
while IFS= read -r choice; do
    drive_choices+=("$choice")
done <<< "$selected_drives"

current_count=${#drive_choices[@]}

# Check if previous selection is valid, otherwise clear it
if [[ $current_count -lt $MIN_DRIVES || $current_count -gt $MAX_DRIVES ]]; then
    selected_drives=""
fi

while true; do
    clear
    gum_box "$ZPOOL (requires $MIN_DRIVES-$MAX_DRIVES drives)"

    if [[ -z "$selected_drives" ]]; then
        selected_drives=$(printf "%s\n" "${options_devices[@]}" | gum_choose_no_limit "Select Drives")
    fi

    # If no drive is selected, show an error and continue
    if [[ -z "$selected_drives" ]]; then
        gum_box_sleep "Please select at least one drive!"
        continue
    fi

    # Count selected drives
    drive_count=0
    while IFS= read -r line; do
        [[ -n "$line" ]] && ((drive_count++))
    done <<< "$selected_drives"

    # Validate drive count
    if [[ $drive_count -lt $MIN_DRIVES ]]; then
        gum_box_sleep "Error: $ZPOOL layout requires at least $MIN_DRIVES drives (you selected $drive_count)"
        selected_drives=""  # Clear selection to retry
        continue
    fi

    if [[ $MAX_DRIVES != "999" && $drive_count -gt $MAX_DRIVES ]]; then
        gum_box_sleep "Error: $ZPOOL layout allows maximum $MAX_DRIVES drives (you selected $drive_count)"
        selected_drives=""  # Clear selection to retry
        continue
    fi

    # Confirm drivers to be installed
    if gum_confirm "Confirm selected $drive_count drives: $selected_drives?"; then
        break
    fi
    selected_drives=""  # Clear selection to retry
done

# Clear the selected drives config
sed -i '/^DRIVE_/d' "$SCRIPT_DIR/../config/selected_drives.conf"

# Write selected by-id to new config
> $SCRIPT_DIR/../config/selected_drives.conf
disk_count=1

while IFS= read -r choice; do
    echo "DRIVE_${disk_count}=${drive_map[$choice]}" >> $SCRIPT_DIR/../config/selected_drives.conf
    ((disk_count++))
done <<< "$selected_drives"

grep -v -Ff <(cut -d'=' -f2 "${SCRIPT_DIR}/../config/selected_drives.conf") "${MASTER_LIST}" | \
awk -F'=' 'BEGIN { i=1 } { printf "DRIVE_%d=%s\n", i, $2; i++ }' > "${SCRIPT_DIR}/../config/additional_drives.conf"
