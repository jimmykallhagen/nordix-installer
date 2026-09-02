
# The start of the installer
clear
gum_box "Welcome to the Nordix installer"
sleep 4

# proper way to do zfs setup right
clear
gum_box "ZFS installation"

if gum_confirm "Nordix uses ZFS as its primary filesystem.
Because the Linux kernel (GPLv2) and OpenZFS (CDDL) have different licenses,
ZFS is not included in the ISO image.
You have the right to build and use ZFS locally.
Nordix respects that this decision is yours, not ours.
To proceed, the installer needs to download, build, and load ZFS (zfs-dkms).
This requires an internet connection and takes a few minutes.
If you choose No, the installation will stop, since Nordix cannot function without ZFS.
Do you want to download and build ZFS now?"; then

    clear
    gum_spin_timer "ZFS installation confirmed..."
    gum_spin_timer "Proceeding with the Nordix installation..."
else
    gum_spin_timer "Installation cancelled. Exiting..."
    exit 1
fi
