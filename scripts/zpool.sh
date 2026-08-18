
# Create the ZFS pool
 zpool create -f \
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
-O canmount=off \
  nordix "${ROOT_DISK}"

# Create the parent ROOT dataset
zfs create -o mountpoint=none \
-o canmount=off \
nordix/ROOT

# Create system root dataset
zfs create -o mountpoint=/ \
-o canmount=noauto \
-o recordsize=64k \
-o copies=2 \
nordix/ROOT/default

# Create varcache dataset
zfs create -o mountpoint=/var/cache \
-o canmount=on \
-o recordsize=32k \
-o primarycache=metadata \
-o compression=zstd-3 \
-o exec=off \
-o setuid=off \
-o devices=off \
nordix/varcache

# Create varlog dataset
zfs create -o mountpoint=/var/log \
-o canmount=on \
-o compression=zstd-4 \
-o recordsize=16k \
-o primarycache=metadata \
-o exec=off \
-o setuid=off \
-o devices=off \
nordix/varlog

# Create varlib dataset
zfs create -o mountpoint=/var/lib \
-o canmount=on \
-o compression=zstd-3 \
-o recordsize=32k \
-o primarycache=all \
-o secondarycache=none \
-o devices=off \
-o setuid=off \
nordix/varlib

# Create opt dataset
zfs create -o mountpoint=/opt \
-o canmount=noauto \
-o compression=zstd-3 \
-o recordsize=128K \
-o primarycache=all \
-o devices=off \
-o setuid=off \
nordix/opt

# Create tmp dataset
zfs create -o mountpoint=/tmp \
-o canmount=on \
-o recordsize=64k \
-o setuid=off \
-o devices=off \
-o logbias=throughput \
-o primarycache=all \
 nordix/tmp

# Create var/tmp dataset
zfs create -o mountpoint=/var/tmp \
-o canmount=on \
-o recordsize=64k \
-o xattr=sa \
-o setuid=off \
-o devices=off \
nordix/vartmp

# Create Home dataset
zfs create -o mountpoint=/home \
-o canmount=on \
-o logbias=throughput \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
-o acltype=posixacl \
nordix/home

# Create Home cache dataset
zfs create -o mountpoint=$_USR/.cache \
-o canmount=on \
-o compression=zstd-4 \
-o recordsize=16k \
-o logbias=latency \
-o primarycache=all \
-o setuid=off \
-o devices=off \
nordix/home/cache

# Create Games dataset
zfs create -o mountpoint=$_USR/Games \
-o canmount=on \
-o recordsize=1M \
-o logbias=throughput \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
-o casesensitivity=insensitive \
nordix/home/games

# Create Wine-prefix dataset
zfs create -o mountpoint=$_USR/Wine-prefix \
-o canmount=on \
-o compression=zstd-3 \
-o recordsize=32K \
-o logbias=latency \
-o primarycache=all \
-o setuid=off \
-o devices=off \
-o casesensitivity=insensitive \
nordix/home/wine-prefix

# Create Documents dataset
zfs create -o mountpoint=$_USR/Documents \
-o canmount=on \
-o compression=zstd-4 \
-o recordsize=16K \
-o logbias=latency \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
-o casesensitivity=insensitive \
nordix/home/documents

# Create Config dataset
zfs create -o mountpoint=$_USR/.config \
-o canmount=on \
-o compression=zstd-4 \
-o recordsize=16K \
-o copies=2 \
-o primarycache=metadata \
-o setuid=off \
-o exec=off \
-o devices=off \
nordix/home/config

# Create Documents dataset
zfs create -o mountpoint=$_USR/Pictures \
-o canmount=on \
-o recordsize=1M \
-o logbias=throughput \
-o primarycache=metadata \
-o exec=off \
-o setuid=off \
-o devices=off \
nordix/home/pictures

# Create Config dataset
zfs create -o mountpoint=$_USR/Videos \
-o canmount=on \
-o recordsize=4M \
-o logbias=throughput \
-o primarycache=metadata \
-o exec=off \
-o setuid=off \
-o devices=off \
nordix/home/videos

# Create Music dataset
zfs create -o mountpoint=$_USR/Music \
-o canmount=on \
-o recordsize=2M \
-o logbias=throughput \
-o primarycache=metadata \
-o exec=off \
-o setuid=off \
-o devices=off \
nordix/home/music

# Create Download dataset
zfs create -o mountpoint=$_USR/Download \
-o canmount=on \
-o recordsize=128k \
-o logbias=throughput \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
nordix/home/downloads

# Create local dataset
zfs create -o mountpoint=$_USR/.local \
-o canmount=on \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
nordix/home/local

# Create Lutris dataset
zfs create -o mountpoint=$_USR/.local/share/lutris \
-o canmount=on \
-o recordsize=32k \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
-o casesensitivity=insensitive \
nordix/home/local/lutris

# Create Steam dataset
zfs create -o mountpoint=$_USR/.local/share/Steam \
-o canmount=on \
-o compression=zstd-3 \
-o recordsize=1M \
-o logbias=throughput \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
-o casesensitivity=insensitive \
nordix/home/local/steam

# Create Steam game dataset
zfs create -o mountpoint=$_USR/.local/share/Steam/steamapps/common \
-o canmount=on \
-o recordsize=1M \
-o logbias=throughput \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
-o casesensitivity=insensitive \
nordix/home/local/steam/game

# Create Steam compatibilitytools dataset
zfs create -o mountpoint=$_USR/.local/share/Steam/compatibilitytools.d \
-o canmount=on \
-o compression=zstd-3 \
-o recordsize=32K \
-o logbias=latency \
-o primarycache=all \
-o setuid=off \
-o devices=off \
nordix/home/local/steam/proton

# Create Steam shadercache dataset
zfs create -o mountpoint=$_USR/.local/share/Steam/steamapps/shadercache \
-o canmount=on \
-o compression=lz4 \
-o recordsize=16K \
-o logbias=throughput \
-o primarycache=all \
-o setuid=off \
-o devices=off \
nordix/home/local/steam/shadercache

# Create VM dataset
zfs create -o mountpoint=$_USR/.local/vm \
-o canmount=on \
-o compression=lz4 \
-o recordsize=64K \
-o logbias=throughput \
-o primarycache=all \
nordix/home/local/vm
