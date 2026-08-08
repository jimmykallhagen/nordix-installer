#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
MASTER_LIST="${CONFIG_DIR}/drives.conf"
BOOT_FILE="${CONFIG_DIR}/selected_boot_drive.conf"
OUTPUT_FILE="${CONFIG_DIR}/device-list-vdev.conf"

source $SCRIPT_DIR/../config/drives.conf
source $SCRIPT_DIR/../gum-lib/gum.conf

clear
# Set base color for the installer
echo -ne "\e]10;${G_BASE_COLOR}\a"


gum_box 'In order to give ZFS the best possible performance and conditions
it is recommended not to partition its drives
Instead it is better to put the boot/fat32 partition "Zfsbootmenu" on a separate drive, preferably a USB'

if gum_confirm 'Do you want to install zfsbootmenu on a separate drive?'; then

gum_spin_timer "Proceeding with separate zfsbootmenu drive setup"

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


while true; do
    selected_boot_drive=$(printf "%s\n" "${options[@]}" |  gum_choose 'Select Boot Drive - Choose Drive With Enter')

    # Confirm drivers to be installed
    gum_confirm "Confirm selected drives: $selected_boot_drive?" && break

done


# Write selected by-id to new config
> $SCRIPT_DIR/../config/selected_boot_drive.conf
disk_count=1

while IFS= read -r choice; do
    echo "DRIVE_${disk_count}=${drive_map[$choice]}" >> $SCRIPT_DIR/../config/selected_boot_drive.conf
    ((disk_count++))
done <<< "$selected_boot_drive"

# Fix the device list to next step 
  grep -v -Ff <(cut -d'=' -f2 "${BOOT_FILE}") "${MASTER_LIST}" | \
  awk -F'=' 'BEGIN { i=1 } { printf "DRIVE_%d=%s\n", i, $2; i++ }' > "${OUTPUT_FILE}"


clear
gum_spin_timer 'Select boot drive is done'
exit 0

 else
# Fix the device list to next step
cp "${MASTER_LIST}" "${OUTPUT_FILE}"
 
 clear 
 gum_spin_timer "Note: This May Impact ZFS Performance"

exit 1
fi

