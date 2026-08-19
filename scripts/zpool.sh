#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
ZPOOL_DEVICES_CONF="${CONFIG_DIR}/zpool_devices.conf"
ZPOOL_LAYOUT_CONF="${CONFIG_DIR}/selected-zpool-layout.conf"

# Load devices from formatting output
mapfile -t DEVICES < "$ZPOOL_DEVICES_CONF"
ROOT_DISK="${DEVICES[*]}"

# Build mirror groups for stripe-mirror
MIRROR1=""
MIRROR2=""
if [[ ${#DEVICES[@]} -eq 4 ]]; then
  MIRROR1="${DEVICES[0]} ${DEVICES[1]}"
  MIRROR2="${DEVICES[2]} ${DEVICES[3]}"
fi

# Optional: load selected layout for convenience
if [[ -f "$ZPOOL_LAYOUT_CONF" ]]; then
  # file contains: ZPOOL="stripe-mirror"
  # shellcheck disable=SC1090
  source "$ZPOOL_LAYOUT_CONF"
fi

ZPOOL_OPTIONS="\
-o feature@large_dnode=enabled \
-o feature@large_blocks=enabled \
-o feature@extensible_dataset=enabled \
-o feature@large_microzap=enabled \
-o feature@spacemap_v2=enabled \
-o feature@device_removal=enabled \
-o feature@obsolete_counts=enabled \
-o feature@physical_rewrite=enabled \
-o feature@raidz_expansion=enabled \
-o feature@spacemap_histogram=enabled \
-o feature@log_spacemap=enabled \
-o feature@zilsaxattr=enabled \
-o feature@zpool_checkpoint=enabled \
-o feature@zstd_compress=enabled \
-o feature@livelist=enabled \
-o feature@empty_bpobj=enabled \
-o feature@embedded_data=enabled \
-o feature@dynamic_gang_header=enabled \
-o feature@bookmarks=enabled \
-o feature@bookmark_v2=enabled \
-o feature@bookmark_written=enabled \
-o feature@block_cloning=enabled \
-o feature@block_cloning_endian=enabled \
-o feature@async_destroy=enabled \
\
-o ashift=12 \
-o autotrim=on \
-O redundant_metadata=most \
-O dnodesize=auto \
-O mountpoint=none \
-O compression=lz4 \
-O atime=off \
-O xattr=sa \
-O sync=standard \
-O checksum=fletcher4 \
-O acltype=off \
-O logbias=latency \
-O primarycache=all \
-O secondarycache=none \
-o autoexpand=on \
-O canmount=off"

# Create the Zpool with single and stripe layout
ZPOOL_SINGLE_STRIPE() {
  zpool create -f \
 ${ZPOOL_OPTIONS} nordix "${ROOT_DISK}"
}

# Create the Zpool with mirror layout
ZPOOL_MIRROR() {
  zpool create -f \
  ${ZPOOL_OPTIONS} nordix mirror "${ROOT_DISK}"
}

# Create the Zpool with stripe mirror layout
ZPOOL_STRIPE_MIRROR() {
  zpool create -f \
  ${ZPOOL_OPTIONS} nordix "${MIRROR1}" mirror "${MIRROR2}"
}

# Create the Zpool with raidz layout
ZPOOL_RAIDZ() {
  zpool create -f \
  ${ZPOOL_OPTIONS} nordix raidz "${ROOT_DISK}"
}

# Create the Zpool with raidz2 layout
ZPOOL_RAIDZ2() {
  zpool create -f \
  ${ZPOOL_OPTIONS} nordix raidz2 "${ROOT_DISK}"
}

# Create the Zpool with raidz3 layout
ZPOOL_RAIDZ3() {
  zpool create -f \
  ${ZPOOL_OPTIONS} nordix raidz3 "${ROOT_DISK}"
}

# Auto-select layout based on config
create_zpool() {
  case "${ZPOOL:-}" in
    single|stripe)
      ZPOOL_SINGLE_STRIPE
      ;;
    zfs-mirror)
      ZPOOL_MIRROR
      ;;
    stripe-mirror)
      ZPOOL_STRIPE_MIRROR
      ;;
    zfs-raidz)
      ZPOOL_RAIDZ
      ;;
    zfs-raidz2)
      ZPOOL_RAIDZ2
      ;;
    zfs-raidz3)
      ZPOOL_RAIDZ3
      ;;
    *)
      echo "Unknown or missing ZPOOL layout: ${ZPOOL:-<empty>}"
      exit 1
      ;;
  esac
}

# Kör automatiskt när skriptet startas som separat process
create_zpool
