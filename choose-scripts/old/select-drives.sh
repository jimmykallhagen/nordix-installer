#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
MASTER_LIST="${CONFIG_DIR}/device-list-vdev.conf"
BOOT_FILE="${CONFIG_DIR}/selected_drives.conf"
OUTPUT_FILE="${CONFIG_DIR}/device-list-extra-vdev.conf"

source $SCRIPT_DIR/../config/drives.conf
source $SCRIPT_DIR/../gum-lib/gum.conf

clear
# Set base color for the installer
echo -ne "\e]10;${G_BASE_COLOR}\a"
declare -A drive_map

zfs_info() {
gum_pager "
##=======================================================================================##
* You often see that ZFS Stripe is not recommended
this is precisely because the ZFS recommendations are aimed at larger enterprice pools
where it would be risky to run stripe.
For a home PC there is a big difference
and there's not much more risk to running ZFS Stripe than running a single device.

- ZFS Stripe är ett bra alternativ för ett entusiast-system

- ZFS Stripe offers the absolute highest performance but provides no redundancy.
All storage capacity is usable. Redundancy = 0.

* ZFS Mirror offers roughly double the read performance
with write performance equivalent to a single drive.
Half the storage capacity. Redundancy = can lose 1 drive.

* ZFS Stripe + Mirror offers roughly four times the read performance
with write performance equivalent to two drives.
Half the storage capacity. Redundancy = can lose 1 drive in each mirror pair.

* ZFS RAIDZ offers poor write performance and decent read performance.
With three drives you can use the storage capacity of two.
Redundancy = can lose 1 drive.
##=======================================================================================##

##=======================##
 # Press ESC to continue #
##=======================##

"
}
zfs_info
gum_box "ZFS Stripe – at least two devices
ZFS Mirror – two devices
ZFS Stripe + Mirror – 4 devices
ZFS Raidz – at least 3 devices"

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

    drive_map["${human_readable}"]="$by_id"
    options+=("${human_readable}")

    ((count++))
done

echo "ZFS-Info" >> $SCRIPT_DIR/../config/drives.conf
while true; do
    selected_drives=$(printf "%s\n" "${options[@]}" |  gum_choose_no_limit "Select Drives")

    if [[ -z "$selected_drives" ]]; then
        gum_box_sleep "Please select at least one drive!" && true
   fi
    if gum_confirm "Do you want to see ZFS info again?"; then
    gum_spin_timer "Gather Info"
    zfs_info

        continue
    else
        continue
    
    fi
  
    # Confirm drivers to be installed
    gum_confirm "Confirm selected drives: $selected_drives?" && break

done


# Write selected by-id to new config
> $SCRIPT_DIR/../config/selected_drives.conf
disk_count=1

while IFS= read -r choice; do
    echo "DRIVE_${disk_count}=${drive_map[$choice]}" >> $SCRIPT_DIR/../config/selected_drives.conf
    ((disk_count++))
done <<< "$selected_drives"
