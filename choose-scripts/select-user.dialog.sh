#!/bin/bash
# Step: create user account and password.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/../config/user.conf"
unset USER_NAME USER_PASSWD CTRL_USER_PASSWD

# Cant run Ctrl + C to exit
handle_interrupt() {
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --colors --color-mode 2 \
        --title "Cannot Exit" \
        --msgbox "\Z1You cant exit here" 5 25
    exec "${BASH_SOURCE[0]}" "$@"
}
trap handle_interrupt INT TERM QUIT HUP

BACKTITLE="Nordix Installer"

# Outer loop: restarts from username if the user cancels during password.
while true; do

# Username: loop until a valid username is confirmed.

       while true; do
        USER_NAME=$(dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "Create User Account" \
            --inputbox "Enter username (lowercase, no spaces):" 8 60 "nordix" \
            2>&1 > /dev/tty)

        if [ $? -ne 0 ] || [ -z "$USER_NAME" ]; then
            dialog --clear --title "Input required" \
                --msgbox  "A username is required. Please try again." 5 60 \
                2>&1 > /dev/tty
            continue
        fi

        if [[ ! "$USER_NAME" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
            dialog --clear --title "Invalid username" \
                --msgbox "Invalid username format.\n\nUse lowercase letters, numbers, underscore and hyphen.\nMust start with a letter or underscore."  5 65 \
                2>&1 > /dev/tty
            continue
        fi

        if dialog --clear \
            --title "Confirm username" \
            --yesno "Are you sure about this username?\n\n$USER_NAME"  5 50; then  2>&1 > /dev/tty; then

        else
            continue
        fi


   # A little personality, same as the gum version.
    if [ "$USER_NAME" != "nordix" ]; then
        dialog --clear \
            --title "Noted" \
            --colors --color-mode 2 \
            --msgbox "Well, if you really think it turned out well, \Zbthat's your choice..."  5 50
    else
        dialog --clear \
            --title "Nice!" \
            --msgbox "Exquisite choice of username."  5 50
    fi

        # Persist the username.
        echo "_USER_NAME=$USER_NAME" > "$OUTPUT_FILE"
        break
    done

    # -----------------------------------------------------------------------
    # Password: loop until a valid password is entered twice and matches.
    # Cancel here breaks out to the outer loop -> back to username.
    # -----------------------------------------------------------------------
    password_ok=0
    while true; do
        USER_PASSWD=$(dialog --clear --insecure  \
            --backtitle "$BACKTITLE" \
            --title "Create password" \
            --passwordbox "Create user password.\n\nMinimum 4 characters, no spaces.\n(User and root password will be the same.)" 10 65 \
            2>&1 > /dev/tty)

        if [ $? -ne 0 ] || [ -z "$USER_PASSWD" ]; then
            dialog --clear --title "Password" \
                --msgbox "Password is required."  5 50  \
                2>&1 > /dev/tty
        fi

        if [[ ! "$USER_PASSWD" =~ ^[^[:space:]]{4,}$ ]]; then
            dialog --clear --title "Invalid password" \
                --msgbox "Invalid password.\n\nMinimum 4 characters, no spaces."  7 60  \
                2>&1 > /dev/tty
            continue
        fi

        CTRL_USER_PASSWD=$(dialog --clear --insecure  \
            --backtitle "$BACKTITLE" \
            --title "Confirm password" \
            --passwordbox  "Please enter the password again for validation." 7 60 \
            2>&1 > /dev/tty)

        if [ $? -ne 0 ] || [ -z "$CTRL_USER_PASSWD" ]; then
            dialog --clear --title "Cancelled" \
                --msgbox "Password confirmation is required. Returning to username."  5 50  \
                2>&1 > /dev/tty
            break   # back to username
        fi

        if [[ ! "$CTRL_USER_PASSWD" =~ ^[^[:space:]]{4,}$ ]]; then
            dialog --clear --title "Invalid password" \
                --msgbox "Invalid password.\n\nMinimum 4 characters, no spaces."  5 50  \
                2>&1 > /dev/tty
            continue
        fi

        if [ "$CTRL_USER_PASSWD" != "$USER_PASSWD" ]; then
            dialog --clear --title "Passwords do not match" \
                --msgbox "Passwords do not match, try again!"  5 50  \
                2>&1 > /dev/tty
            continue
        fi

        password_ok=1
        break
    done

    # If password was set successfully, we're done with the whole step.
    if [ "$password_ok" -eq 1 ]; then
        echo "_USER_PASSWD=$USER_PASSWD" >> "$OUTPUT_FILE"
        break   # break outer loop -> step complete
    fi
    # Otherwise outer loop continues -> username dialog again.

done

dialog --clear --title "User created" \
    --msgbox "User: $USER_NAME with password is created."  5 60  \
    2>&1 > /dev/tty
