#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BACKTITLE="Nordix Installer"

handle_interrupt() {
dialog --clear \
    --backtitle "$BACKTITLE" \
    --title "Cannot Exit" \
    --msgbox "You cant exit here" 5 25
    exec "${BASH_SOURCE[0]}" "$@"
}

trap handle_interrupt INT TERM QUIT HUP

dialog --clear \
    --backtitle "$BACKTITLE" \
    --title "ZFS Kernel Modules" \
    --msgbox "
#======================================================================================================#
# Nordix uses ZFS as its primary filesystem.
#======================================================================================================#
The Linux kernel (GPLv2) and OpenZFS (CDDL) have different licenses, there for Nordix isnt allowed to
distribute ZFS in the ISO image.

- You have the right to install and use ZFS.
- Just dont distribute it with the linux kernel.

#======================================================================================================#
For this to be correct, it most be the users own active choice to download and install the ZFS modules.

To proceed, the installer needs to download, build, and load ZFS (zfs-dkms).
- This requires an internet connection and takes a few minutes.
- If you choose No, the installation will stop, since Nordix cannot function without ZFS.
#======================================================================================================#
" 25 110


# Confirm with the user if they want to install ZFS kernel modules
dialog --clear \
    --backtitle "$BACKTITLE" \
    --title "Install ZFS Kernel Modules" \
    --yesno "Do you confirm download and install of ZFS Modules?" 5 55


# If not, ask again
if [ $? != 0 ]; then

# confirm if the user not want to download suport for zfs
if dialog --clear \
    --backtitle "$BACKTITLE" \
    --title "Cancel Install ZFS Kernel Modules" \
    --yesno "ZFS Installation aborted, the installer will now power off." 5 65; then
    poweroff
else

    dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "Phew, close call." \
         --msgbox  "ZFS confirmed. proceeding with downloading of ZFS modules" 5 65
fi
fi
