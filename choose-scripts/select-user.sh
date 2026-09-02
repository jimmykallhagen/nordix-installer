#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf
OUTPUT_FILE="$SCRIPT_DIR/../config/user.conf"
unset USER_NAME USER_PASSWD CTRL_USER_PASSWD

# Set base color for the installer
echo -ne "\e]10;${G_BASE_COLOR}\a"

clear
gum_spin_timer "Searching for a user..."

while true; do
clear
gum_box "Create User Account (lowercase, no spaces)"

# from varible to gum_input and back
USER_NAME=$(gum_input "Enter username: nordix")

    # handling ESC/no choise
    if [[ -z "$USER_NAME" ]]; then
        clear
        gum_box_sleep "Please select a username!"
        continue
    fi

# check the username
      if [[ ! "$USER_NAME" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
            gum_box_sleep "Invalid username format"
            gum_box_sleep "Use lowercase letters, numbers, underscore, hyphen"
            continue
        fi

# Some trolling
    if gum_confirm "Sure about this username?: ${USER_NAME}?"; then
if [[ "$USER_NAME" != nordix ]]; then
    gum_box_sleep "Well, if you really think it turned out well, that’s your choice..."
fi

if [[ "$USER_NAME" = nordix ]]; then
gum_box_sleep "Exquisite choice of username."
fi
        # write usr name to file
        #
        echo "_USER_NAME=$USER_NAME" > "${OUTPUT_FILE}"
        break
    fi
done

        while true; do
            clear
            gum_box_sleep "Create user password (user amd root password is the same)"
            gum_box "Minimum 4 characters, no spaces"
            USER_PASSWD=$(gum_input_hidden "Enter password:****")

            if [[ -z "$USER_PASSWD" ]]; then
                gum_box_sleep "Please create a password!" && true
                continue
            fi

            # Validation: no spaces and at least 4 chars
            if [[ ! "$USER_PASSWD" =~ ^[^[:space:]]{4,}$ ]]; then
                gum_box_sleep "Invalid password" && true
                gum_box_sleep "Minimum 4 chars, no spaces" && true
                continue
            fi

            clear
            gum_box "Please enter the password again for validation"
            CTRL_USER_PASSWD=$(gum_input_hidden "Repeat password:****")

            if [[ -z "$CTRL_USER_PASSWD" ]]; then
                gum_box_sleep "Please confirm password!" && true
                continue
            fi

            if [[ ! "$CTRL_USER_PASSWD" =~ ^[^[:space:]]{4,}$ ]]; then
                gum_box_sleep "Invalid password" && true
                gum_box_sleep "Minimum 4 chars, no spaces" && true
                continue
            fi

            if [[ "$CTRL_USER_PASSWD" != "$USER_PASSWD" ]]; then
                gum_box_sleep "Passwords do not match, try again!" && true
                continue

      else
                echo "_USER_PASSWD=$USER_PASSWD" >> "${OUTPUT_FILE}"
                break
fi
        done
        clear
        gum_box_sleep "User: $USER_NAME with password is created"
