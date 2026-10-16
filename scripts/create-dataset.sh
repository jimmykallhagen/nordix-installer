# Nordix ZFS Dataset setup

create_dataset() {
# Create varcache dataset
zfs create -o mountpoint=/var/cache \
-o canmount=on \
-o recordsize=32k \
-o primarycache=metadata \
-o compression=zstd-3 \
-o exec=off \
-o setuid=off \
-o devices=off \
nordix/var/cache

sleep 0.5

# Create varlog dataset
zfs create -o mountpoint=/var/log \
-o canmount=on \
-o compression=zstd-4 \
-o recordsize=16k \
-o primarycache=metadata \
-o exec=off \
-o setuid=off \
-o devices=off \
nordix/var/log

sleep 0.5

# Create var/tmp dataset
zfs create -o mountpoint=/var/tmp \
-o canmount=on \
-o recordsize=64k \
-o xattr=sa \
-o setuid=off \
-o devices=off \
nordix/var/tmp

sleep 0.5

# Create opt dataset
zfs create -o mountpoint=/opt \
-o canmount=noauto \
-o compression=zstd-3 \
-o recordsize=128K \
-o primarycache=all \
-o devices=off \
-o setuid=off \
nordix/opt

sleep 0.5

# Create tmp dataset
zfs create -o mountpoint=/tmp \
-o canmount=on \
-o recordsize=64k \
-o setuid=off \
-o devices=off \
-o logbias=throughput \
-o primarycache=all \
 nordix/tmp

sleep 0.5

# Create Home dataset
zfs create -o mountpoint=/home \
-o canmount=on \
-o logbias=throughput \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
-o acltype=posixacl \
nordix/home

sleep 0.5

# pree create a home for the user

source "$SCRIPTDIR/config/user.conf"
mkdir -p "/home/$_USER_NAME"

sleep 0.5

# Create Home cache dataset
zfs create -o mountpoint=/home/$_USER_NAME/.cache \
-o canmount=on \
-o compression=zstd-4 \
-o recordsize=16k \
-o logbias=throughput \
-o primarycache=all \
-o setuid=off \
-o devices=off \
nordix/home/cache

sleep 0.5

# Create Games dataset
zfs create -o mountpoint=/home/$_USER_NAME/Games \
-o canmount=on \
-o recordsize=1M \
-o logbias=throughput \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
-o casesensitivity=insensitive \
nordix/home/games

sleep 0.5

# Create Wine-prefix dataset
zfs create -o mountpoint=/home/$_USER_NAME/Wine-prefix \
-o canmount=on \
-o compression=zstd-3 \
-o recordsize=32K \
-o logbias=throughput \
-o primarycache=all \
-o setuid=off \
-o devices=off \
-o casesensitivity=insensitive \
nordix/home/wine-prefix

sleep 0.5

# Create Documents dataset
zfs create -o mountpoint=/home/$_USER_NAME/Documents \
-o canmount=on \
-o compression=zstd-4 \
-o recordsize=16K \
-o logbias=throughput \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
-o casesensitivity=insensitive \
nordix/home/documents

# Create Config dataset
zfs create -o mountpoint=/home/$_USER_NAME/.config \
-o canmount=on \
-o compression=zstd-4 \
-o recordsize=16K \
-o copies=2 \
-o logbias=latency \
-o primarycache=metadata \
-o setuid=off \
-o exec=off \
-o devices=off \
nordix/home/config

sleep 0.5

# Create Pictures dataset
zfs create -o mountpoint=/home/$_USER_NAME/Pictures \
-o canmount=on \
-o recordsize=1M \
-o logbias=throughput \
-o primarycache=metadata \
-o exec=off \
-o setuid=off \
-o devices=off \
nordix/home/pictures

sleep 0.5

# Create Videos dataset
zfs create -o mountpoint=/home/$_USER_NAME/Videos \
-o canmount=on \
-o recordsize=4M \
-o logbias=throughput \
-o primarycache=metadata \
-o exec=off \
-o setuid=off \
-o devices=off \
nordix/home/videos

sleep 0.5

# Create Music dataset
zfs create -o mountpoint=/home/$_USER_NAME/Music    \
-o canmount=on \
-o recordsize=2M \
-o logbias=throughput \
-o primarycache=metadata \
-o exec=off \
-o setuid=off \
-o devices=off \
nordix/home/music

sleep 0.5

# Create Download dataset
zfs create -o mountpoint=/home/$_USER_NAME/Download \
-o canmount=on \
-o recordsize=128k \
-o logbias=throughput \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
nordix/home/downloads

sleep 0.5

# Create Projects dataset
zfs create -o mountpoint=/home/$_USER_NAME/Projects \
-o canmount=on \
-o recordsize=64k \
-o logbias=throughput \
-o primarycache=all \
-o setuid=off \
-o devices=off \
nordix/home/projects

sleep 0.5

# Create local dataset
zfs create -o mountpoint=/home/$_USER_NAME/.local \
-o canmount=on \
-o logbias=throughput \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
nordix/home/local

sleep 0.5

# Create Lutris dataset
zfs create -o mountpoint=/home/$_USER_NAME/.local/share/lutris \
-o canmount=on \
-o recordsize=32k \
-o logbias=throughput \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
-o casesensitivity=insensitive \
nordix/home/local/lutris

sleep 0.5

# Create Steam dataset
zfs create -o mountpoint=/home/$_USER_NAME/.local/share/Steam \
-o canmount=on \
-o compression=zstd-3 \
-o recordsize=1M \
-o logbias=throughput \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
-o casesensitivity=insensitive \
nordix/home/local/steam

sleep 0.5

# Create Steam game dataset
zfs create -o mountpoint=/home/$_USER_NAME/.local/share/Steam/steamapps/common \
-o canmount=on \
-o recordsize=1M \
-o logbias=throughput \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
-o casesensitivity=insensitive \
nordix/home/local/steam/games

sleep 0.5

# Create Steam compatibilitytools dataset
zfs create -o mountpoint=/home/$_USER_NAME/.local/share/Steam/compatibilitytools.d \
-o canmount=on \
-o compression=zstd-3 \
-o recordsize=32K \
-o logbias=throughput \
-o primarycache=all \
-o setuid=off \
-o devices=off \
nordix/home/local/steam/proton

sleep 0.5

# Create Steam shadercache dataset
zfs create -o mountpoint=/home/$_USER_NAME/.local/share/Steam/steamapps/shadercache \
-o canmount=on \
-o compression=lz4 \
-o recordsize=16K \
-o logbias=throughput \
-o primarycache=all \
-o setuid=off \
-o devices=off \
nordix/home/local/steam/shadercache
}



DATASET_ARRAY=(
    "nordix/home"
    "nordix/home/local"
    "nordix/home/local/lutris"
    "nordix/home/local/steam"
    "nordix/home/local/steam/shadercache"
    "nordix/home/local/steam/games"
    "nordix/home/local/steam/proton"
    "nordix/home/music"
    "nordix/home/wine-prefix"
    "nordix/home/games"
    "nordix/home/config"
    "nordix/home/pictures"
    "nordix/home/videos"
    "nordix/home/documents"
    "nordix/home/downloads"
    "nordix/home/projects"
    "nordix/var/cache"
    "nordix/var/log"
    "nordix/var/tmp"
    "nordix/opt"
    "nordix/tmp"
)

# check if all dataset have successfully been created, run create_dataset
check_dataset_creation() {
for dataset in "${DATASET_ARRAY[@]}"; do
    if zfs list "$dataset" | grep MOUNTPOINT; then
        echo "Dataset $dataset is already created"
    else
        echo "Dataset $dataset is not created, running create_dataset"
        # run create_dataset if dataset is not created
        create_dataset
    fi
done
}

# Mount all datasets
mount_datasets() {
    for dataset in "${DATASET_ARRAY[@]}"; do
        zfs mount "$dataset"
    done
}
