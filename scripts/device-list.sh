#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"

list_vdev() {
  local MASTER_LIST="${CONFIG_DIR}/drives.conf"
  local BOOT_FILE="${CONFIG_DIR}/selected_boot_drive.conf"
  local OUTPUT_FILE="${CONFIG_DIR}/device-list-vdev.conf"

  grep -v -Ff <(cut -d'=' -f2 "${BOOT_FILE}") "${MASTER_LIST}" | \
  awk -F'=' 'BEGIN { i=1 } { printf "DRIVE_%d=%s\n", i, $2; i++ }' > "${OUTPUT_FILE}"
}

list_extra_vdev() {
  local MASTER_LIST="${CONFIG_DIR}/device-list-vdev.conf"
  local VDEV_FILE="${CONFIG_DIR}/selected_drives.conf"
  local OUTPUT_FILE="${CONFIG_DIR}/device-list-extra-vdev.conf"

  grep -v -Ff <(cut -d'=' -f2 "${BOOT_FILE}") "${MASTER_LIST}" | \
  awk -F'=' 'BEGIN { i=1 } { printf "DRIVE_%d=%s\n", i, $2; i++ }' > "${OUTPUT_FILE}"
}