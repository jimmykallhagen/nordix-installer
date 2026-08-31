#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf
OUTPUT_FILE="$SCRIPT_DIR/../config/extra-package.conf"
unset CHOICE

# Set base color for the installer
echo -ne "\e]10;${G_BASE_COLOR}\a"

clear
gum_sin_sleep "Looking for some gaming packages..."

while true; do
    clear
    gum_box "Extra package selection: Gaming"

# Choose package
OPTIONS=(
    "Steam - Gamelauncher"
    "Gamescope Session Steam - ChimeraOS port of SteamOS gaming session."
    "Lutris - Game launcher and Game launcher manager, a cross-platform gaming frontend"
    "Lutris Gamepad UI - Turns your Lutris game library into a console like experience, including game session"
    "Heroic - An Open source Launcher for Epic, Amazon and GOG Games"
    "ProtonUP-QT - Install and manage GE-Proton, Luxtorpeda & more for Steam, Lutris and Heroic"
    "ProtonPlus - Install and manage custom Proton and wine versions for Steam, Lutris and Heroic"
    "Gamemode - Run games with Gamemode to improve performance"
    "Gamescope - SteamOS compositor for gaming sessions"
    ""
    'Exit'
)

    # show the list of packages with gum_choose
    CHOICE=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose_no_limit "Press Space to choose - Enter to confirm")

    # handling ESC/no choice
    if [[ -z "$CHOICE" ]]; then
        gum_box_sleep "Please select an option with Space!" && true
        continue
    fi

    # Filter out Exit from selection
    CHOICE_FILTERED=$(printf "%s\n" "$CHOICE" | grep -vx "Exit" || true)

    # If user only selected Exit or nothing remains after filtering
    if [[ -z "$CHOICE_FILTERED" ]]; then
        gum_box_sleep "Maybe next time"
        break
    fi

    # Confirm the selected package(s)
    if gum_confirm "Confirm package(s): ${CHOICE_FILTERED}?"; then
        # Clear output file before writing - overwrite each run
        > "${OUTPUT_FILE}"
        # Process each selected choice line by line
        while IFS= read -r line; do
            case "$line" in
                "Steam - Gamelauncher")   echo "PKG-G1=steam" >> "${OUTPUT_FILE}"  ;;
                "Gamescope Session Steam - ChimeraOS port of SteamOS gaming session.")   echo "PKG-G2=gamescope-session-steam" >> "${OUTPUT_FILE}"  ;;
                "Lutris - Game launcher and Game launcher manager, a cross-platform gaming frontend")   echo "PKG-G3=lutris" >> "${OUTPUT_FILE}"  ;;
                "Lutris Gamepad UI - Turns your Lutris game library into a console like experience, including game session")   echo "PKG-G4=lutris-gamepad-ui" >> "${OUTPUT_FILE}"  ;;
                "Heroic - An Open source Launcher for Epic, Amazon and GOG Games")   echo "PKG-G5=heroic" >> "${OUTPUT_FILE}"  ;;
                "ProtonUP-QT - Install and manage GE-Proton, Luxtorpeda & more for Steam, Lutris and Heroic")   echo "PKG-G6=protonup-qt" >> "${OUTPUT_FILE}"  ;;
                "ProtonPlus - Install and manage custom Proton and wine versions for Steam, Lutris and Heroic")   echo "PKG-G7=protonplus" >> "${OUTPUT_FILE}"  ;;
                "Gamemode - Run games with Gamemode to improve performance")   echo "PKG-G8=gamemode" >> "${OUTPUT_FILE}"  ;;
                "Gamescope - SteamOS compositor for gaming sessions")   echo "PKG-G9=gamescope" >> "${OUTPUT_FILE}"  ;;
            esac
        done <<< "$CHOICE_FILTERED"
        break
    fi
done
