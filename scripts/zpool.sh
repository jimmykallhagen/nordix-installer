#!/bin/bash

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
  ${ZPOOL_OPTIONS} nordix "${ROOT_DISK}" mirror "${MIRROR_DISK}"
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
