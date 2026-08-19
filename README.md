# Nordix installer


## First impressions
An installer is the first impression you get of a system, but its appearance has nothing to do with whether a system is modern or not, whether a system is technically good or bad, but it is a first impression and using ready-made installers like Calamares gives a professional impression.

---

## Why not Calamarer?

Calamares is great for handling standard installations, perfect for giving the user smooth system setup with location, language, keyboard, partitioning, formatting your drive and configure a bootloader.
But when a system like Nordix deviates from this standard with zfs and its various vdev layouts it becomes problematic, not using a traditional bootloader but instead using Zfsbootmenu means that you have to put more work into "hacking" Calameres than it takes to write your own installer.
I have had different ideas for how this setup should look, an installer written with python GUI or similar has been one of my thoughts at first, but then I think that for a first release I should not bother too much with it. A graphical installer can also introduce compatibility issues with diverse hardware, using Bash and Gum ensures it runs on any console without extra drivers.
and running KMS is hardcore mode, even if it a installer, so it fits with "Nordix follow the law of performance".

---
## Nordix installer
The philosophy behind the Nordix installer is that it should be modular and easy to understand and so it will be easier to contribute to the Nordix installer if you would like to do so.
> You could think of the Nordix installer as a universal Arch ZFS installer.
---

# Contribute

Things I write tend to be a bit enthusiastic, but I have to let it be, nothing is written in stone and if you are someone who wants to contribute to this project and maybe make it have a less enthusiastic, are welcome to help me with this, you are welcome to help and contribute even if you don't want to change the impression of course


---

# Update 


* Detekt devices /dev/disk/by-id and convert it to human readable format
* Choose seperate boot device y/n
* Choose zpool layout
* Choose devices
* choose special vdev, SLOG, l2arc
* erase and formatting disk

seems to working now!!

---
## Some info
---
**The installer supports:**
 - Single drive
 - Stripe (Raid0)
 - Mirror (2 Drives)
 - Stripe + Mirror
 - RAIDZ (RAID5)
 - RAIDZ2
 - RAIDZ2
 - RAIDZ3

**Extra vdevs like:**
 - L2ARC
 - Special
 - Slog
---

---
# 1.
### ``It starts with select-boot-drive.sh``.
Gum shell scripts will give the options to the user to choose a seperate device for boot to be able to give whole disk to zfs for best performance
 - 1. choose if you want to have boot (zfsbootmenu) on a seperate device.
 - 2. if yes - choose boot drive.

# 2.
### ``select zpool layout and devices for the zpool - help is written so you can get a guidence direktly here``
 - 1. select zpool layout
 - 2. select devices for the zpool.

# 3.
### ``This part is 3 but they is the same for every extra vdev: One for Special vdev, one for SLOG, one for l2arc``
 - 1. select singl, stripe or mirror
 - 2. select devices

choose exit if you dont want additional vdevs.

# 4 
### ``Formatting``
 - 1.erase the devices
 - 2. look if seperate boot is selected, if yes - no partition of zpool devices, if no partition will be created on zpool devices
 - 3. format fat32
 - 4. create the zpool 

# 5.
### ``Add SLOG, Special, L2ARC``

---
## Nordix ZPOOL setup:

```fish 
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
```
---

## Nordix ZFS Dataset setup:

```fish

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
```
