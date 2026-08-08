#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"

source $SCRIPT_DIR/../config/drives.conf
source $SCRIPT_DIR/../gum-lib/gum.conf
# Set base color for the installer
echo -ne "\e]10;${G_BASE_COLOR}\a"

# Choose options for Zpool layouts
OPTIONS=(
"Nordix ZFS Help"
"ZFS Single          : 1 drive, no redundancy"
"ZFS Stripe          : 2+ drives, maximum speed, no redundancy (Similar to RAID0)"
"ZFS Mirror          : 2 drives, fault tolerant (Similar to RAID 1)"
"ZFS Stripe + Mirror : 4+ drives, fast & safe (Similar to RAID 10)"
"ZFS RAIDZ           : 3+ drives, balanced safety/space (Similar to RAID 5)"
"ZFS RAIDZ2          : 5+ drives, balanced safety/space (Similar to RAID 6)"
"ZFS RAIDZ3          : 7+ drives, balanced safety/space"
)

clear
gum_box "Starting Zpool layout selection"
gum_spin_timer "Gathering some Zpool layout....."

while true; do
    clear
    gum_box "Choose Zpool Layouts"
    CHOICE=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose "Press Enter to choose")

    if [[ -z "$CHOICE" ]]; then
        clear
        gum_box_sleep "Please select a layout!" && true
        continue
    fi

    if [[ "$CHOICE" == "Nordix ZFS Help" ]]; then
        clear
        gum_spin_timer "Gather info..." && true
        gum_pager < "${ZFS_INFO_VDEV}"
        gum_spin_timer "Now you know..."
        continue
    fi

    case "$CHOICE" in
        "ZFS Single          : 1 drive, no redundancy") ZPOOL="single" ;;
        "ZFS Stripe          : 2+ drives, maximum speed, no redundancy (Similar to RAID0)") ZPOOL="stripe" ;;
        "ZFS Mirror          : 2 drives, fault tolerant (Similar to RAID 1)") ZPOOL="zfs-mirror" ;;
        "ZFS Stripe + Mirror : 4+ drives, fast & safe (RAID 10)") ZPOOL="stripe-mirror" ;;
        "ZFS RAIDZ           : 3+ drives, balanced safety/space (Similar to RAID 5)") ZPOOL="zfs-raidz" ;;
        "ZFS RAIDZ2          : 5+ drives, balanced safety/space (Similar to RAID 6)") ZPOOL="zfs-raidz2" ;;
        "ZFS RAIDZ3          : 7+ drives, balanced safety/space") ZPOOL="zfs-raidz3" ;;
    esac

    if gum_confirm "Confirm zpool vdev Layout: $ZPOOL?"; then
        break
    fi
done

sed -i '/^ZPOOL=/d' "${CONFIG_DIR}/selected-zpool-layout.conf"
echo "ZPOOL=\"$ZPOOL\"" >> "${CONFIG_DIR}/selected-zpool-layout.conf"

clear
gum_spin_timer "Zpool layout selection complete"
