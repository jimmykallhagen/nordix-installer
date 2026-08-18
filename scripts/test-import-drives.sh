#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE=$SCRIPT_DIR/../config/drives.conf

> "$OUTPUT_FILE"
count=1
declare -A seen

for id_path in /dev/disk/by-id/*; do
    [ -e "$id_path" ] || continue
    [[ "$id_path" == *-part* ]] && continue

    real=$(readlink -f "$id_path")
    [ -b "$real" ] || continue
    [[ -n "${seen[$real]:-}" ]] && continue
    seen[$real]=1

    model=$(lsblk -dno MODEL "$real" 2>/dev/null || echo "Unknown")
    size=$(lsblk -dno SIZE "$real" 2>/dev/null || echo "Unknown")

    echo "DRIVE_${count}=\"${id_path} ${model} - ${size}\"" >> "$OUTPUT_FILE"
    ((count++))
done
