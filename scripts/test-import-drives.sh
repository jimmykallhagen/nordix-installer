#!/bin/bash
# import drives by /dev/disk/by-id and fallback if Nordix is running in VM
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE=$SCRIPT_DIR/../config/drives.conf

get_disk_info() {
    local disk_path="$1"
    local model size
    model=$(lsblk -dno MODEL "$disk_path" 2>/dev/null || echo "Unknown")
    size=$(lsblk -dno SIZE "$disk_path" 2>/dev/null || echo "Unknown")
    echo "${model} - ${size}"
}

get_by_id_path() {
    local disk_name="$1"
    for id_path in /dev/disk/by-id/*; do
        if [[ "$(readlink -f "$id_path")" == "/dev/$disk_name" ]]; then
            if [[ "$id_path" =~ /dev/disk/by-id/(ata-|nvme-[A-Z]|usb-) ]]; then
                echo "$id_path"
                return
            fi
        fi
    done
    echo ""
}

> "$OUTPUT_FILE"
count=1

while IFS= read -r disk; do
    if [[ ! "$disk" =~ ^/dev/(sd[a-z]|vd[a-z]|nvme[0-9]n[0-9])$ ]]; then
        continue
    fi
    if [[ "$(lsblk -dno TYPE "$disk" 2>/dev/null)" != "disk" ]]; then
        continue
    fi

    disk_name=$(basename "$disk")
    by_id_path=$(get_by_id_path "$disk_name")

    # Fallback for VM where by-id is missing
    if [[ -z "$by_id_path" ]]; then
        by_id_path="$disk"
    fi

    disk_info=$(get_disk_info "$disk")
    echo "DRIVE_${count}=\"${by_id_path} ${disk_info}\"" >> "$OUTPUT_FILE"
    ((count++))
done < <(lsblk -dpno NAME 2>/dev/null)
