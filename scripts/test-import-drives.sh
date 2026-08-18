#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE=$SCRIPT_DIR/../config/drives.conf

> "$OUTPUT_FILE"
count=1

for dev in $(lsblk -dpno NAME -t | grep -E '^/dev/(vd|sd|nvme)[a-z0-9]*$'); do
    [ -b "$dev" ] || continue

    # Hitta by-id
    by_id=$(find /dev/disk/by-id -maxdepth 1 -lname "$dev" -print -quit 2>/dev/null || true)
    [[ -z "$by_id" ]] && by_id="$dev"

    model=$(lsblk -dno MODEL "$dev" 2>/dev/null || echo "Unknown")
    size=$(lsblk -dno SIZE "$dev" 2>/dev/null || echo "Unknown")

    echo "DRIVE_${count}=\"${by_id} ${model} - ${size}\"" >> "$OUTPUT_FILE"
    ((count++))
done
