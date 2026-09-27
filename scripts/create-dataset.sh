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
zfs create -o mountpoint=$_USER_NAME/.cache \
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
zfs create -o mountpoint=$_USER_NAME/Games \
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
zfs create -o mountpoint=$_USER_NAME/Wine-prefix \
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
zfs create -o mountpoint=$_USER_NAME/Documents \
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
zfs create -o mountpoint=$_USER_NAME/.config \
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
zfs create -o mountpoint=$_USER_NAME/Pictures \
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
zfs create -o mountpoint=$_USER_NAME/Videos \
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
zfs create -o mountpoint=$_USER_NAME/Music    \
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
zfs create -o mountpoint=$_USER_NAME/Download \
-o canmount=on \
-o recordsize=128k \
-o logbias=throughput \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
nordix/home/downloads

sleep 0.5

# Create local dataset
zfs create -o mountpoint=$_USER_NAME/.local \
-o canmount=on \
-o logbias=throughput \
-o primarycache=metadata \
-o setuid=off \
-o devices=off \
nordix/home/local

sleep 0.5

# Create Lutris dataset
zfs create -o mountpoint=$_USER_NAME/.local/share/lutris \
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
zfs create -o mountpoint=$_USER_NAME/.local/share/Steam \
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
zfs create -o mountpoint=$_USER_NAME/.local/share/Steam/steamapps/common \
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
zfs create -o mountpoint=$_USER_NAME/.local/share/Steam/compatibilitytools.d \
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
zfs create -o mountpoint=$_USER_NAME/.local/share/Steam/steamapps/shadercache \
-o canmount=on \
-o compression=lz4 \
-o recordsize=16K \
-o logbias=throughput \
-o primarycache=all \
-o setuid=off \
-o devices=off \
nordix/home/local/steam/shadercache
}


check_dataset_creation() {

# check if all dataset have successfully been created

# Check if home dataset is created, if not, run create_dataset
if zfs list nordix/home | grep MOUNTPOINT; then
    continue
else
    # run create_dataset if dataset is not created
    create_dataset
fi

# Check if home/local dataset is created, if not, run create_dataset
if zfs list nordix/home/local | grep MOUNTPOINT; then
    continue
else
    # run create_dataset if dataset is not created
    create_dataset
fi

# Check if home/cache dataset is created, if not, run create_dataset
if zfs list nordix/home/cache | grep MOUNTPOINT; then
    continue
else
    # run create_dataset if dataset is not created
    create_dataset
fi

# Check if home/video dataset is created, if not, run create_dataset
if zfs list nordix/home/video | grep MOUNTPOINT; then
    continue
else
    # run create_dataset if dataset is not created
    create_dataset
fi

# Check if home/pictures dataset is created, if not, run create_dataset
if zfs list nordix/home/pictures | grep MOUNTPOINT; then
    continue
else
    # run create_dataset if dataset is not created
    create_dataset
fi

# Check if home/downloads dataset is created, if not, run create_dataset
if zfs list nordix/downloads | grep MOUNTPOINT; then
    continue
else
    # run create_dataset if dataset is not created
    create_dataset
fi

# Check if home/documents dataset is created, if not, run create_dataset
if zfs list nordix/home/documents | grep MOUNTPOINT; then
    continue
else
    # run create_dataset if dataset is not created
    create_dataset
fi

# Check if home/lutris dataset is created, if not, run create_dataset
if zfs list nordix/home/local/lutris | grep MOUNTPOINT; then
    continue
else
    # run create_dataset if dataset is not created
    create_dataset
fi

# Check if home/local/steam dataset is created, if not, run create_dataset
if zfs list nordix/home/local/steam | grep MOUNTPOINT; then
    continue
else
    # run create_dataset if dataset is not created
    create_dataset
fi

# Check if home/local/steam/shadercache dataset is created, if not, run create_dataset
if zfs list nordix/home/local/steam/shadercache | grep MOUNTPOINT; then
    continue
else
    # run create_dataset if dataset is not created
    create_dataset
fi

# Check if home/local/steam/game dataset is created, if not, run create_dataset
if zfs list nordix/home/local/steam/games | grep MOUNTPOINT; then
    continue
else
    # run create_dataset if dataset is not created
    create_dataset
fi

# Check if home/local/steam/proton dataset is created, if not, run create_dataset
if zfs list nordix/home/local/steam/proton | grep MOUNTPOINT; then
    continue
else
    # run create_dataset if dataset is not created
    create_dataset
fi

# Check if home/music dataset is created, if not, run create_dataset
if zfs list nordix/home/music | grep MOUNTPOINT; then
    continue
else
    # run create_dataset if dataset is not created
    create_dataset
fi

# Check if home/wine-prefix dataset is created, if not, run create_dataset
if zfs list nordix/home/wine-prefix | grep MOUNTPOINT; then
    continue
else
    # run create_dataset if dataset is not created
    create_dataset
fi

# Check if home/games dataset is created, if not, run create_dataset
if zfs list nordix/home/games | grep MOUNTPOINT; then
    continue
else
    # run create_dataset if dataset is not created
    create_dataset
fi

# Check if home/config dataset is created, if not, run create_dataset
if zfs list nordix/home/config | grep MOUNTPOINT; then
    continue
else
    # run create_dataset if dataset is not created
    create_dataset
fi
}


mount_datasets() {
    zfs mount nordix/home
    zfs mount nordix/home/local
    zfs mount nordix/home/local/lutris
    zfs mount nordix/home/local/steam
    zfs mount nordix/home/local/steam/shadercache
    zfs mount nordix/home/local/steam/games
    zfs mount nordix/home/local/steam/proton
    zfs mount nordix/home/music
    zfs mount nordix/home/wine-prefix
    zfs mount nordix/home/games
    zfs mount nordix/home/config
    zfs mount nordix/home/pictures
    zfs mount nordix/home/videos
    zfs mount nordix/home/documents
    zfs mount nordix/home/downloads
    zfs mount nordix/home/music
    zfs mount nordix/home/wine-prefix
    zfs mount nordix/home/config
    zfs mount nordix/var/cache
    zfs mount nordix/var/log
    zfs mount nordix/var/tmp
    zfs mount nordix/opt
    zfs mount nordix/tmp
}
