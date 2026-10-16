
install_user() {
# Install missing directories and adding BUilds as a default directory
mkdir -p /mnt/home/$_USER_NAME/{Builds,Public,Templates,Desktop}

cat > "/mnt/home/$_USER_NAME/.config/user-dirs.dirs" << 'EOF'
# This file is written by xdg-user-dirs-update
#
XDG_DESKTOP_DIR="$HOME/Desktop"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_TEMPLATES_DIR="$HOME/Templates"
XDG_PUBLICSHARE_DIR="$HOME/Public"
XDG_DOCUMENTS_DIR="$HOME/Documents"
XDG_MUSIC_DIR="$HOME/Music"
XDG_PICTURES_DIR="$HOME/Pictures"
XDG_VIDEOS_DIR="$HOME/Videos"
XDG_PROJECTS_DIR="$HOME/Projects"
EOF

# Create user
arch-chroot /mnt useradd -U -G wheel,audio,video,storage,optical,network -d "/home/$_USER_NAME" "$_USER_NAME"
arch-chroot /mnt chpasswd <<< "$_USER_NAME:$_USER_PASSWD"
arch-chroot /mnt chpasswd <<< "root:$_USER_PASSWD"

# set permissions on home directory
chmod 750 "/mnt/home/$_USER_NAME"
chown -R "$_USER_NAME:$_USER_NAME" "/mnt/home/$_USER_NAME"

sleep 2

clear
# some information about the home directory and the different from standard when you have a ZFS home
gum_box "Regardless of what language you choose
your home directory will have English names
To change it, you need to rename the directorys and change the mountpoint of the ZFS datasets that are mounted in home.
Example:

change the name in the mountpoint of this line mountpoint=/home/$_USER_NAME/Videos
in the command below for change name on the Videos directory

sudo zfs set mountpoint=/home/$_USER_NAME/Videos nordix/home/videos
"
echo ""

gum_box "After renaming a ZFS dataset's mountpoint under home,
edit ~/.config/user-dirs.dirs and update the matching XDG_*_DIR line
to point to your new folder name.

Command:
nano ~/.config/user-dirs.dirs

Then edit the file to your liking:
XDG_DESKTOP_DIR=\"\$HOME/Desktop\"
XDG_DOWNLOAD_DIR=\"\$HOME/Downloads\"
XDG_TEMPLATES_DIR=\"\$HOME/Templates\"
XDG_PUBLICSHARE_DIR=\"\$HOME/Public\"
XDG_DOCUMENTS_DIR=\"\$HOME/Documents\"
XDG_MUSIC_DIR=\"\$HOME/Music\"
XDG_PICTURES_DIR=\"\$HOME/Pictures\"
XDG_VIDEOS_DIR=\"\$HOME/Videos\"
XDG_PROJECTS_DIR=\"\$HOME/Projects\"
"
echo ""
read -rp "Press Enter to continue..." _

# ask user if they want to save this information to their home directory
#
if gum_confirm "Do you want to save this information to a file in your home directory?"; then
    cat > "/mnt/home/$_USER_NAME/Info-change-directory-name.md" << EOF
    # Change names of ZFS datasets under home

    > Regardless of what language you choose, your home directory will have English names.
    > To change it, you need to rename the directories and change the mountpoint of the ZFS datasets that are mounted in home.

    ---

    ## Example:

    Change the name in the mountpoint of this line mountpoint=/home/$_USER_NAME/Videos
    in the command below to change the name of the Videos directory

        sudo zfs set mountpoint=/home/$_USER_NAME/<change> nordix/home/videos

    After renaming a ZFS dataset's mountpoint under home,
    edit ~/.config/user-dirs.dirs and update the matching XDG_*_DIR line
    to point to your new folder name.

        nano ~/.config/user-dirs.dirs

    Then edit the file to your liking:

        XDG_DESKTOP_DIR="\$HOME/Desktop"
        XDG_DOWNLOAD_DIR="\$HOME/Downloads"
        XDG_TEMPLATES_DIR="\$HOME/Templates"
        XDG_PUBLICSHARE_DIR="\$HOME/Public"
        XDG_DOCUMENTS_DIR="\$HOME/Documents"
        XDG_MUSIC_DIR="\$HOME/Music"
        XDG_PICTURES_DIR="\$HOME/Pictures"
        XDG_VIDEOS_DIR="\$HOME/<change>"
        XDG_PROJECTS_DIR="\$HOME/Projects"
    EOF

    chown "$_USER_NAME:$_USER_NAME" "/mnt/home/$_USER_NAME/Info-change-directory-name.md"
fi

}
