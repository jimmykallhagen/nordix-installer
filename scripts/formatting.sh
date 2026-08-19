#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
BOOT_CONF="${CONFIG_DIR}/selected_boot_drive.conf"
DRIVES_CONF="${CONFIG_DIR}/selected_drives.conf"
ZPOOL_DEVICES_CONF="${CONFIG_DIR}/zpool_devices.conf"

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

    [[ -b "$disk" ]] || return 0
    zpool labelclear -f "$disk" 2>/dev/null || true
    wipefs -a "$disk" 2>/dev/null || true
    dd if=/dev/zero of="$disk" bs=1M count=10 2>/dev/null || true

    disk_size_mb=$(blockdev --getsz "$disk" 2>/dev/null || echo 0)
    disk_size_mb=$(( disk_size_mb / 2048 ))
    [[ $disk_size_mb -gt 0 ]] && dd if=/dev/zero of="$disk" bs=1M seek=$((disk_size_mb - 10)) count=10 2>/dev/null || true

    blockdev --rereadpt "$disk" 2>/dev/null || true
    blockdev --flushbufs "$disk" 2>/dev/null || true
    udevadm settle 2>/dev/null || true
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

log() { echo "[formatting] $*"; }

# By-id partition path, e.g. /dev/disk/by-id/ata-XXX -> /dev/disk/by-id/ata-XXX-part1
byid_part_dev() {
    local byid="$1"
    local part="$2"
    echo "${byid}-part${part}"
}

parse_drives_file() {
    local file="$1"
    local -n out_arr="$2"
    out_arr=()
    if [[ ! -f "$file" ]]; then
        return 0
    fi
    while IFS= read -r line || [[ -n "$line" ]]; do
        # strip comments
        line="${line%%#*}"
        # extract first /dev/disk/by-id/... occurrence, stop at whitespace
        if [[ "$line" =~ (/dev/disk/by-id/[^[:space:]]+) ]]; then
            out_arr+=("${BASH_REMATCH[1]}")
        fi
    done < "$file"
}

format_boot_partition() {
    local byid="$1"
    log "Preparing boot device $byid"

    # Wipe and create GPT on by-id device
    sgdisk -Z "$byid" || true
    sgdisk -o "$byid" || true

    # Create 2GiB FAT32 partition
    sgdisk -n 1:0:+2G -t 1:EF00 "$byid"

    partprobe "$byid" || true
    udevadm settle || true

    local part_dev
    part_dev=$(byid_part_dev "$byid" 1)
    # Wait for device to appear
    for i in {1..10}; do
        if [[ -b "$part_dev" ]]; then break; fi
        sleep 0.5
    done

    if [[ ! -b "$part_dev" ]]; then
        log "Error: partition $part_dev did not appear"
        exit 1
    fi

    mkfs.vfat -F 32 -n BOOT "$part_dev"
    log "Formatted $part_dev as FAT32"
}

partition_pool_drive_for_boot() {
    local byid="$1"
    log "Partitioning pool drive for combined boot+ZFS: $byid"

    sgdisk -Z "$byid" || true
    sgdisk -o "$byid" || true

    # 2GiB FAT32 boot partition
    sgdisk -n 1:0:+2G -t 1:EF00 "$byid"
    # Rest of disk for ZFS
    sgdisk -n 2:0:0 -t 2:BF00 "$byid"

    partprobe "$byid" || true
    udevadm settle || true

    local boot_part
    boot_part=$(byid_part_dev "$byid" 1)
    for i in {1..10}; do
        if [[ -b "$boot_part" ]]; then break; fi
        sleep 0.5
    done
    mkfs.vfat -F 32 -n BOOT "$boot_part"
    log "Formatted $boot_part as FAT32"
    # Return ZFS partition device for caller using by-id
    local zfs_part
    zfs_part=$(byid_part_dev "$byid" 2)
    echo "$zfs_part"
}

# Main logic
root_devices=()
boot_drives=()
pool_drives=()

parse_drives_file "$DRIVES_CONF" pool_drives

if [[ -f "$BOOT_CONF" ]]; then
    log "Boot configuration detected"
    parse_drives_file "$BOOT_CONF" boot_drives

    # Deduplicate
    declare -A boot_seen
    declare -A pool_seen
    uniq_boot=()
    uniq_pool=()
    for d in "${boot_drives[@]}"; do
        if [[ -z "${boot_seen[$d]:-}" ]]; then
            boot_seen[$d]=1
            uniq_boot+=("$d")
        fi
    done
    for d in "${pool_drives[@]}"; do
        if [[ -z "${pool_seen[$d]:-}" ]]; then
            pool_seen[$d]=1
            uniq_pool+=("$d")
        fi
    done

    # Check for overlap between boot and pool drives
    declare -A boot_map
    for d in "${uniq_boot[@]}"; do
        boot_map["$d"]=1
    done

    overlap_found=false
    for d in "${uniq_pool[@]}"; do
        if [[ -n "${boot_map[$d]:-}" ]]; then
            overlap_found=true
            break
        fi
    done

    if $overlap_found; then
        log "Boot drive overlaps with pool drives - using combined boot+ZFS partitioning"
        declare -A processed
        for d in "${uniq_pool[@]}"; do
            if [[ -n "${boot_map[$d]:-}" ]]; then
                zfs_part=$(partition_pool_drive_for_boot "$d")
                root_devices+=("$zfs_part")
                processed["$d"]=1
            else
                root_devices+=("$d")
            fi
        done
        # Format separate boot drives not used in pool
        for d in "${uniq_boot[@]}"; do
            if [[ -z "${processed[$d]:-}" ]]; then
                format_boot_partition "$d"
            fi
        done
    else
        log "Separate boot drive configuration detected"
        for d in "${uniq_boot[@]}"; do
            format_boot_partition "$d"
        done
        root_devices=("${uniq_pool[@]}")
    fi
else
    log "No separate boot drive, boot will be on first pool drive"
    if [[ ${#pool_drives[@]} -eq 0 ]]; then
        log "Error: no pool drives found"
        exit 1
    fi
    # Deduplicate pool drives
    declare -A seen_pool
    unique_pool=()
    for d in "${pool_drives[@]}"; do
        if [[ -z "${seen_pool[$d]:-}" ]]; then
            seen_pool[$d]=1
            unique_pool+=("$d")
        fi
    done
    first_drive="${unique_pool[0]}"
    zfs_part=$(partition_pool_drive_for_boot "$first_drive")
    root_devices+=("$zfs_part")
    for d in "${unique_pool[@]:1}"; do
        root_devices+=("$d")
    done
fi

# Export ROOT_DISK for callers
ROOT_DISK="${root_devices[*]}"
export ROOT_DISK
log "ROOT_DISK set to: $ROOT_DISK"

# Persist for later scripts
printf "%s\n" "${root_devices[@]}" > "$ZPOOL_DEVICES_CONF"
log "Wrote device list to $ZPOOL_DEVICES_CONF"

log " complete"
