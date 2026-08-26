#!/bin/bash
# Nordix Installer
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"

# Gum functions and theme sourcing
source "${SCRIPT_DIR}/../gum-lib/gum.conf"

# Set terminal color
echo -ne "\e]10;${G_BASE_COLOR}\a"

# Global variables set during execution
HOSTNAME=""
USERNAME=""

USER_PASSWORD=""
SELECTED_LOCALE=""
SELECTED_KEYBOARD=""
SELECTED_TIMEZONE=""
SELECTED_DNS=""

##=================================================##
 # Declare                                         #
##=================================================##
# Define locale options
declare -A LOCALES=(
    ["1"]="en_US.UTF-8|English (US)"
    ["2"]="en_GB.UTF-8|English (UK)"
    ["3"]="sv_SE.UTF-8|Swedish - Svenska"
    ["4"]="nb_NO.UTF-8|Norwegian - Norsk"
    ["5"]="da_DK.UTF-8|Danish - Dansk"
    ["6"]="fi_FI.UTF-8|Finnish - Suomi"
    ["7"]="de_DE.UTF-8|German - Deutsch"
    ["8"]="fr_FR.UTF-8|French - Français"
    ["9"]="es_ES.UTF-8|Spanish - Español"
    ["10"]="it_IT.UTF-8|Italian - Italiano"
    ["11"]="pl_PL.UTF-
    |Polish - Polski"
    ["12"]="ru_RU.UTF-8|Russian - Русский"
    ["13"]="ja_JP.UTF-8|Japanese - 日本語"
    ["14"]="ko_KR.UTF-8|Korean - 한국어"
    ["15"]="zh_CN.UTF-8|Chinese - 中文"
    ["16"]="pt_BR.UTF-8|Portuguese - Português"
    ["17"]="nl_NL.UTF-8|Dutch - Nederlands"
)

# Define keyboard options
declare -A KEYBOARDS=(
    ["1"]="us|English (US)"
    ["2"]="gb|English (UK)"
    ["3"]="se|Swedish"
    ["4"]="no|Norwegian"
    ["5"]="dk|Danish"
    ["6"]="fi|Finnish"
    ["7"]="de|German"
    ["8"]="fr|French"
    ["9"]="es|Spanish"
    ["10"]="it|Italian"
    ["11"]="pl|Polish"
    ["12"]="ru|Russian"
    ["13"]="jp|Japanese"
    ["14"]="kr|Korean"
    ["15"]="cn|Chinese"
    ["16"]="br|Portuguese (Brazil)"
    ["17"]="nl|Dutch"
    ["18"]="ch|Swiss"
)

# Define timezone options
declare -A TIMEZONES=(
    ["1"]="Europe/Stockholm|Stockholm"
    ["2"]="Europe/Oslo|Oslo"
    ["3"]="Europe/Copenhagen|Copenhagen"
    ["4"]="Europe/Helsinki|Helsinki"
    ["5"]="Europe/London|London"
    ["6"]="Europe/Berlin|Berlin"
    ["7"]="Europe/Paris|Paris"
    ["8"]="Europe/Amsterdam|Amsterdam"
    ["9"]="America/New_York|New York"
    ["10"]="America/Chicago|Chicago"
    ["11"]="America/Denver|Denver"
    ["12"]="America/Los_Angeles|Los Angeles"
    ["13"]="Asia/Tokyo|Tokyo"
    ["14"]="Asia/Shanghai|Shanghai"
    ["15"]="Australia/Sydney|Sydney"
    ["16"]="UTC|UTC"
)

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
echo "$HOSTNAME" > "$CONFIG_DIR/hostname.conf"
