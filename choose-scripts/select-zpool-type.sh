#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf
INSTALL_DIR="$SCRIPT_DIR/../install"
unset ZPOOL RAM_SIZE DRIVER


# Set base color for the installer
echo -ne '\e]10;${G_BASE_COLOR}\a'

# Confirm yes/no
gum_confirm() {
    local message="$1"
    gum confirm --padding="$G_PADDING" \
\
      --selected.align="$G_ALIGN" \
      --selected.border="$G_BOX_STYLE" \
      --selected.bold \
      --selected.background="$G_SELECTED_BACKGROUND_COLOR" \
      --selected.foreground="$GUM_SELECTED_TEXT_COLOR" \
\
      --unselected.align="$G_ALIGN" \
      --unselected.border="$G_BOX_STYLE" \
      --unselected.background="$G_UNSELECTED_BACKGROUND_COLOR" \
      --unselected.foreground="$LIGHT1_GRAY" \
      --unselected.faint \
\
      --prompt.padding="$G_BOX_PADDING" \
      --prompt.align="$BOX_ALIGN" \
      --prompt.border="$G_BOX_STYLE" \
      --prompt.foreground="$GUM_CONFIRMBOX_TEXT_COLOR" "$message"
}

# Choose Zpool
OPTIONS=(
"Single: One drive, no redundancy"
"Stripe: 2+ drives, maximum speed, no redundancy (RAID0)"
"Mirror: 2 drives, fault tolerant (RAID 1)"
"Stripe + Mirror: 4+ drives, fast & safe (RAID 10)"
"RAIDZ: 3+ drives, balanced safety/space (RAID 5)"
"Nordix ZGuide: Vdev"
)

while true; do
    CHOICE=$(printf "%s\n" "${OPTIONS[@]}" | gum choose \
            --header.border="$G_BOX_STYLE" \
            --header.align="center" \
            --item.align="center" \
            --header.width=$HEADAER_WIDHT \
            --header.height=$HEADER_HEIGHT \
            --header.border-foreground="${G_BASE_COLOR}" \
            --header.foreground="$GUM_CONFIRMBOX_TEXT_COLOR" \
            --header.bold \
            --item.foreground="$LIGHT1_GRAY" \
            --cursor.foreground="$TEXT_COLOR_1" \
            --cursor.bold \
            --cursor="     ••❯ " \
            --header "Choose Zpool Layouts")


    case "$CHOICE" in
        "Single: One drive, no redundancy")                         ZPOOL="single-stripe" ;;
        "Stripe: 2+ drives, maximum speed, no redundancy (RAID0)")  ZPOOL="single-stripe" ;;
        "Mirror: 2 drives, fault tolerant (RAID 1)")                ZPOOL="zfs-mirror" ;;
        "Stripe + Mirror: 4+ drives, fast & safe (RAID 10)")        ZPOOL="stripe-mirror" ;;
        "RAIDZ: 3+ drives, balanced safety/space (RAID 5)")         ZPOOL="zfs-raidz" ;;
    esac
    

# Confirm drivers to be installed
    gum_confirm "Confirm zpool vdev Layout: $ZPOOL?" && break

done
 echo "ZPOOL=\"$ZPOOL\"" >> "$INSTALL_DIR/install.conf"


# Set no color for the installer
echo -ne '\033[0m'



You often see that stripe/Raid0 is not recommended with ZFS, but you must not forget that zfs is designed for enterprise.
If you have a server that has around 20 drives, it is a disaster to run with stripe. 
A home PC where you only have a few drives it is a completely different situation.
ZFS will close zpool if something serious happens you can now import it in read only and save the data,
however, it is not a guarantee, but there is still a high probability that ZFS will see a failed drive.
This is not an option in an enterprice server as the server would be down for maybe several weeks to rescue data.
Nordix also uses a S.M.A.R.T service from smartmontools that scans your devices at every boot and notifies you if something bad starts to happen
This is to make stripe a more pleasant choice. 
I would personally recommend stripe in a home PC, it gives top performance and you use the entire storage area.



 ## RIADZ
 # RAIDZ is a variation on RAID-5 that allows for better distribution of parity and eliminates the RAID-5 “write hole” (in which data and parity become inconsistent after a power loss). Data and parity is striped across all disks within a raidz group.
 # A raidz group can have single, double, or triple parity, meaning that the raidz group can sustain one, two, or three failures, respectively, without losing any data. The raidz1 vdev type specifies a single-parity raidz group; the raidz2 vdev type specifies a double-parity raidz group; and the raidz3 vdev type specifies a triple-parity raidz group. The raidz vdev type is an alias for raidz1.
 # A raidz group of N disks of size X with P parity disks can hold approximately (N-P)*X bytes and can withstand P devices failing without losing data. The minimum number of devices in a raidz group is one more than the number of parity disks. The recommended number is between 3 and 9 to help increase performance.





# Whole disks should be given to ZFS rather than partitions. If you must use a partition, make certain that the partition is properly aligned to avoid read-modify-write overhead.
 # check Wine Windows file systems’ standard behavior is to be case-insensitive. Create dataset with zfs create -o casesensitivity=insensitive




 ##############


Mirror: A vdev that stores the same data on two or more drives for redundancy.

RAIDZ: A vdev that uses parity to provide fault tolerance, similar to traditional RAID 5/6. There are three levels of RAIDZ:

RAIDZ1: Single parity, similar to RAID 5. Requires at least 2 disks (3+ recommended), can tolerate one drive failure.

RAIDZ2: Double parity, similar to RAID 6. Requires at least 3 disks (5+ recommended), can tolerate two drive failures.

RAIDZ3: Triple parity. Requires at least 4 disks (7+ recommended), can tolerate three drive failures.


#==================================================================================================#
#                           VDEVs - What is a VDEV? - OpenZFS Documantation                        #
#==================================================================================================#

A vdev (virtual device) is a fundamental building block of ZFS storage pools. It represents a logical grouping of physical storage devices, such as hard drives, SSDs, or partitions.

OpenZFS supports several types of vdevs. Top-level vdevs carry data and provide redundancy:

- Striped Disk(s): A vdev consisting of one or more physical devices striped together (like RAID 0). It provides no redundancy and will lead to data loss if a drive fails.

- Mirror: A vdev that stores the same data on two or more drives for redundancy.

- RAIDZ: A vdev that uses parity to provide fault tolerance, similar to traditional RAID 5/6. There are three levels of RAIDZ:

- RAIDZ1: Single parity, similar to RAID 5. Requires at least 2 disks (3+ recommended), can tolerate one drive failure.

- RAIDZ2: Double parity, similar to RAID 6. Requires at least 3 disks (5+ recommended), can tolerate two drive failures.

- RAIDZ3: Triple parity. Requires at least 4 disks (7+ recommended), can tolerate three drive failures.


#==================================================================================================#



Auxiliary vdevs provide specific functionality:

    Spare: A drive that acts as a hot spare, automatically replacing a failed drive in another vdev.

    Cache (L2ARC): A Level 2 ARC vdev used for caching frequently accessed data to improve random read performance.

    Log (SLOG): A separate log vdev (SLOG) used to store the ZFS Intent Log (ZIL) for improved synchronous write performance.

    Special: A vdev dedicated to storing metadata, and optionally small file blocks and the Dedup Table (DDT).

    Dedup: A vdev dedicated strictly to storing the Deduplication Table (DDT).

