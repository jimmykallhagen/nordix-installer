#!/bin/env bash
# Orcestrator for Nordix Installer
# this is why i have started to study RUST, bash is hard on this type of projects!!!
#
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/info/nordix-welcome"
source "${SCRIPT_DIR}/gum-lib/gum.conf"
source "${SCRIPT_DIR}/install/zfs-module"
source "${SCRIPT_DIR}/info/zfs-info"
source "${SCRIPT_DIR}/info/zfs-info-advanced"
source "${SCRIPT_DIR}/choose-scripts/select-extra-vdev.sh"

IMPORT_DEVICES="${SCRIPT_DIR}/scripts/import-devices.sh"
ERASE_DEVICES="${SCRIPT_DIR}/scripts/erase-drive.sh"
FORMATTING="${SCRIPT_DIR}/scripts/formatting.sh"
EXTRA_VDEV="${SCRIPT_DIR}/scripts/special-vdev.sh"

BOOT_DEVICE="${SCRIPT_DIR}/choose-scripts/select-boot-drive.sh"
ZPOOL_LAYOUT="${SCRIPT_DIR}/choose-scripts/select-zpool-type.sh"
SPECIAL_VDEV="${SCRIPT_DIR}/choose-scripts/select-special.sh"
SLOG_VDEV="${SCRIPT_DIR}/choose-scripts/select-slog.sh"
L2ARC_VDEV="${SCRIPT_DIR}/choose-scripts/select-l2arc.sh"


echo -ne "\e]10;${G_BASE_COLOR}\a"
clear

######################- PART1 -###########################
#
#
# Zpool creation loop

while true; do
#-----------------------------
# ZFS Introduction
#-----------------------------
##======================================================##
# Show intro and give the user the choice of
# installing ZFS or not
# source info/nordix-welcome

zfs_intro
##======================================================##

#-----------------------------
# Install ZFS modules
#-----------------------------
##======================================================##
# Install ZFS modules
# the method will be change
# and i will host the modules myself
# source install/zfs-module

zfs_module
##======================================================##

#----------------------------
# Import Devices
#----------------------------
##======================================================##
# Import devices, get humanreadable and /dev/disk/by-id
# source scripts/import-devices.sh

$IMPORT_DEVICES
##======================================================##

#-----------------------------
# Show Nordix ZFS guide
#-----------------------------
##======================================================##
# Show the Nordix ZFS guide
# source info/zfs-info

zfs_info
##======================================================##

# ** IMPORTANT THAT ALL SELECTED DEVICES I IN CORRECT ORDER **
# ** IMPORTANT THAT ALL SELECTED DEVICES I IN CORRECT ORDER **
# ** IMPORTANT THAT ALL SELECTED DEVICES I IN CORRECT ORDER **

#----------------------------
# Select Boot Drive
#----------------------------
##======================================================##
# Select the boot drive
# source scripts/select-boot-drive.sh

$BOOT_DEVICE
##======================================================##

#----------------------------
# ZPOOL setup
#----------------------------
##======================================================##
# Select zpool layout and devices
# source scripts/select-zpool-layout.sh

$ZPOOL_LAYOUT
##======================================================##

#----------------------------
# Advanced vdev selection
#----------------------------
##======================================================##
# Ask the user if they want to select extra vdevs
# for Slog, Special, L2ARC
# source choose-scripts/select-extra-vdev.sh
# source choose-scripts/select-slog.sh
# source choose-scripts/select-special.sh
# source choose-scripts/select-l2arc.sh

clear
gum_box_sleep "Select extra vdevs for Slog, Special, L2ARC?"

# ask the user if they want to use Slog, Special, L2ARC
extra_vdevs

if [[ "$EXTRA_VDEVS" == "yes" ]]; then
    while true; do
        # source scripts/special-vdev.sh
        $SPECIAL_VDEV
        # source scripts/l2arc-vdev.sh
        $L2ARC_VDEV
        # source scripts/slog-vdev.sh
        $SLOG_VDEV
        if gum_confirm "Do you want to run the extra vdev selection again?"; then
            break
        fi
    done
fi
##======================================================##

#----------------------------------
# Erase format and Zpool creation
#----------------------------------
##======================================================##

clear
gum_box "All data on the selected devices will be erased"
if gum_confirm "Do you want to create the zpool?"; then
    # source scripts/erase-drive.sh

    gum_spin "Erasing devices..." $ERASE_DEVICES
    # source scripts/formatting.sh
    gum_spin "Formatting devices..." $FORMATTING
    # source scripts/special-vdev.sh
    gum_spin "Adding extra vdev... if you selected it" $EXTRA_VDEV
    # break the loop
    break
fi

# Check if the zpool have been created
clear
gum_box "Checking if the zpool have been created..."
    zpool import -f nordix
    sleep 1

    if zfs list nordix | grep nordix; then
       continue
    else
        gum_box "Cant find any Zpool, trying to import the zpool again..."
        zpool export nordix
        sleep 4
        zpool import -f nordix
        sleep 4

        if zfs list nordix | grep nordix; then
            clear
            gum_box "Phew close call! found it!"
            continue
        else
            clear
            gum_box "Something went wrong with the zpool creation"
            gum_box "Please contact Nordix and report the issue"

            if gum_confirm "Do you want to reboot and try again? if not, the PC will power off"; then
                reboot
            else
                poweroff
            fi
        fi
    fi
}
##======================================================##
# Done!
##======================================================##

######################- PART2 -###########################
#
#
# GPU - RAM - SIZE - DESKTOP INFO

SELECT_RAM_SIZE="$SCRIPT_DIR/choose-scripts/select-ram-size.sh"
SELECT_GPU="$SCRIPT_DIR/choose-scripts/select-gpu.sh"
source "$SCRIPT_DIR/config/ram-size.conf"
source "$SCRIPT_DIR/config/gpu.conf"
# Select desktop isnt devoloped yet
# today it is the new system: Umbreil
# Umbreil is brand new project, but very promising
# you can consider it experimental
# there for it will not be several desktop options
# it will be Nordix setups of Umbreil and  Noctalia shell
# Both Umbreil and Noctalia shell
# are developed by the same team - noctalia-dev
# It is to good to be true so GNOME will be installed as fallback
# or if you dont want to use a tiling window manager.
# In the future i plan to add more desktop options.

while true; do
    clear
    $SELECT_RAM_SIZE
# source choose-scripts/select-ram-size.sh
    gum_box "RAM size selected: $_ram"
    if gum_confirm "Continue?"; then
        break
    fi
done

while true; do
    clear
    $SELECT_GPU
# source choose-scripts/select-gpu.sh
    gum_box "GPU selected: $GPU"
    if gum_confirm "Continue?"; then
        break
    fi
done

# desktop selection info
gum_pager "
-*****************************************************-
-** Today Nordix is in the early stages of development **-
-*** I will never be finished if i keep adding features ***-
-** So for today you get Nordix with two desktop environments **-
-*************************************************************-

-------------------

Today Nordix will come with two desktop environments
 - Umbreil with Noctalia.
 - GNOME

-------------------

Umbreil is brand new project, highly potential and very promising,
but you can consider it experimental

-** Umbreil **-
gives you a smooth, complete tiling window manager experience,
that supports scratchpads, workspaces and shift layout on the go.
Layouts: Scrolling, Master and Dwindle layout.
All with beautifully blurr, animations, themes and more.

-** Noctalia **-
On top of Umbreil gives you a real desktop experience.

-** Preconfigured by Nordix **-
Just so you can start without the need to configure the setup.

Not everyone wants a tiling window manager, and umbreil is can be considered experimental.
So GNOME will be installed besides Umbreil.

##=======================##
 # Press ESC to continue #
##=======================##
"

# some trolling
gum_spin_timer "You have selected Umbreil and GNOME, hope you like it!"
##======================================================##
# Done!
##======================================================##

######################- PART4 -###########################
#
#
# Locale - timezone

##======================================================##
SET_LOCALE=$SCRIPT_DIR/choose-scripts/select-locale.sh
SET_TIMEZONE=$SCRIPT_DIR/choose-scripts/select-timezone.sh

# Give the user the option to select a locale
    $SET_LOCALE

# Give the user the option to select a timezone
    $SET_TIMEZONE
 ##======================================================##
 # Done!
 ##======================================================##

##########################################################
######################- PART5 -###########################
#
#
# Set Hostname - Create username - Create password

SET_HOSTNAME=$SCRIPT_DIR/choose-scripts/select-hostname.sh
SET_USERNAME=$SCRIPT_DIR/choose-scripts/select-user.sh

# set hostname
$SET_HOSTNAME
# set username
$SET_USERNAME
##======================================================##
# Done!
##======================================================##

##########################################################
# In case some one should notice
#
gum_spin_timer "Nordix comes with syntax highlighting as standard for nano!"
##########################################################


######################- PART6 -###########################
#
#
# INSTALLATION PART1
# prepare zfs

CREATE_ZFS_DATASET=$SCRIPT_DIR/scripts/create-dataset.sh

# Prepare the zpool before the main dataset script
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

# Export the zpool and import it into /mnt
zpool export nordix

# mount the zpool on /mnt (-R) with no mount options (-N),
# mount the dataset is something we need to do manually
zpool import -R /mnt -N nordix
sleep 0.5
zfs mount nordix/ROOT/default

# Give it some time!
sleep 1

# Check if the root dataset is mounted
if zfs get mounted nordix/ROOT/default | grep yes; then
    continue
else
  # Try to fix the mount issue
    gum_spin_timer "Hmm, some trubble mounting root dataset, trying to fix it..."
    zpool export nordix
    sleep 2
    zpool import -R /mnt -N -f nordix
    sleep 2
    zfs mount nordix/ROOT/default
   sleep 4

    if zfs get mounted nordix/ROOT/default; then
        gum_box "Phew close call, root is mounted!"
        continue
    else
        clear
        gum_box "Failed to mount root dataset..."
        gum_box "Please contact Nordix and report the issue"

        if gum_confirm "Do you want to reboot and try again? if not, the PC will power off"; then
            reboot
        else
            poweroff
            exit 1
        fi
    fi
fi


# create zfs dataset
$CREATE_ZFS_DATASET
