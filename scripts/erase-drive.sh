#!/bin/bash
# Disk Preparation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"

CONFIG_FILES=(
    "$CONFIG_DIR/selected_drives.conf"
    "$CONFIG_DIR/selected_boot_drive.conf"
    "$CONFIG_DIR/selected-special-drives.conf"
    "$CONFIG_DIR/selected-l2arc-drive.conf"
    "$CONFIG_DIR/selected-slog-drive.conf"
)

# Erase a disk by wipefs and with overwriting the start and end of the disk with zeros
prepare_disk() {
    local disk="$1"
    local disk_size_mb

    zpool labelclear -f "$disk" 2>/dev/null || true
    wipefs -a "$disk" 2>/dev/null
    dd if=/dev/zero of="$disk" bs=1M count=10 2>/dev/null

    disk_size_mb=$(($(blockdev --getsz "$disk") / 2048))
    dd if=/dev/zero of="$disk" bs=1M seek=$((disk_size_mb - 10)) count=10 2>/dev/null

    blockdev --rereadpt "$disk" 2>/dev/null
    blockdev --flushbufs "$disk" 2>/dev/null
    udevadm settle 2>/dev/null
}

# Loop all config files and erase the disks
for conf in "${CONFIG_FILES[@]}"; do
    [[ -f "$conf" ]] || continue

    while IFS='=' read -r key value; do
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs | tr -d '"')

        if [[ "$key" =~ ^DRIVE_ && -n "$value" && -e "$value" ]]; then
            prepare_disk "$value"
        fi
    done < "$conf"
done
