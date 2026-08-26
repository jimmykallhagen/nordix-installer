#!/bin/bash
# Nordix Installer
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"

# Gum functions and theme sourcing
source "${SCRIPT_DIR}/../gum-lib/gum.conf"

# Set terminal color
echo -ne "\e]10;${G_BASE_COLOR}\a"


##=================================================##
# Set hostname
clear
gum_spin_timer "Set hostname"

while true; do
OPTIONS_HOSTNAME=(
    'Default - nordix'
    'Custom'
)
    clear
    gum_box "Choose hostname with Enter"
    # show hostname options
    CHOICE_HOST=$(printf "%s\n" "${OPTIONS_HOSTNAME[@]}" | gum_choose "Press Enter to choose")

    # handling ESC/no choise
    if [[ -z "$CHOICE_HOST" ]]; then
        clear
        gum_spin_timer "Please select a hostname!" && true
        continue
    fi

    # Map the choice to a variable and break the loop
    case "$CHOICE_HOST" in
        "Default - nordix")
            if gum_confirm "Confirm hostname nordix"; then
                HOSTNAME="nordix"
                break
            else
                gum_spin_timer "Hostname not confirmed. Returning to selection."
                continue
            fi
            ;;
        "Custom")
            clear
            gum_box_sleep "Enter hostname (lowercase letters, numbers, hyphens - no spaces)"
            read -rp "Hostname: " custom_hostname
            # Validate hostname
            if [[ "$custom_hostname" =~ ^[a-z][a-z0-9-]{2,62}$ ]]; then
                if gum_confirm "Confirm $custom_hostname"; then
                    HOSTNAME="$custom_hostname"
                    break
                else
                    gum_spin_timer "Hostname not confirmed. Returning to selection."
                    continue
                fi
            else
                gum_spin_timer "Invalid hostname format! Must start with a letter, only lowercase letters, numbers, hyphens, 3-63 chars. Returning to selection."

                continue
            fi
            ;;
    esac
done

# Save hostname to variable and file
gum_spin_timer "Hostname set to: $HOSTNAME"
# Persist to project file for later scripts
echo "HOST_NAME=\"$HOSTNAME\"" > "$CONFIG_DIR/hostname.conf"
