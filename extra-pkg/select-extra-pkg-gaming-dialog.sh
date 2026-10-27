#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../gum-lib/gum.conf"
OUTPUT_FILE="${SCRIPT_DIR}/../config/extra-pkg-gaming.conf"
unset CHOICE

echo -ne "\e]10;${G_BASE_COLOR}\a"

BACKTITLE="Nordix Installer"

handle_interrupt() {
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "Cannot Exit" \
        --msgbox "You cant exit here" 5 25
    exec "${BASH_SOURCE[0]}" "$@"
}
trap handle_interrupt INT TERM QUIT HUP

OPTIONS=(
    "Steam - Game launcher"
    "Gamescope Session - SteamOS gaming session ported from ChimeraOS"
    "Lutris - Cross-platform game launcher and manager"
    "Lutris Gamepad UI - Turns your Lutris game library into a console like experience, including game session"
    "Heroic - An Open source Launcher for Epic, Amazon and GOG Games"
    "ProtonPlus - Install and manage custom Proton and wine versions for Steam, Lutris and Heroic"
    "Gamescope - SteamOS compositor for gaming sessions"
    "Goverlay - Gaming overlay for Steam, Lutris, Heroic and more"
    "Vesktop - A standalone Electron-based Discord app with Vencord & improved Linux support"
    "Exit"
)

while true; do
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "Extra Packages" \
        --msgbox "Extra package selection: Gaming" 5 35

    menu_args=()
    i=1
    for opt in "${OPTIONS[@]}"; do
        [[ -z "$opt" ]] && continue
        menu_args+=("$i" "$opt" "OFF")
        ((i++))
    done

    selected_tags=$(dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "Extra Packages" \
        --stdout --checklist "Game launchers, Gaming sessions, Utilities, Discord, Proton" 18 120 9 "${menu_args[@]}")
    ret=$?

    if [ $ret -ne 0 ]; then
        dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "Info" \
            --msgbox "Maybe next time" 5 30
        break
    fi

    opt_list=()
    for o in "${OPTIONS[@]}"; do
        [[ -z "$o" ]] && continue
        opt_list+=("$o")
    done

    selected_opts=()
    exit_selected=false
    for tag in $selected_tags; do
        opt="${opt_list[$((tag-1))]}"
        if [[ "$opt" == "Exit" ]]; then
            exit_selected=true
        else
            selected_opts+=("$opt")
        fi
    done

    if $exit_selected || [ ${#selected_opts[@]} -eq 0 ]; then
        dialog --clear --backtitle "$BACKTITLE" --title "Info" --msgbox "Maybe next time" 6 40
        break
    fi

    confirm_text=$(printf "%s\n" "${selected_opts[@]}" | head -c 200)
    if dialog --clear --backtitle "$BACKTITLE" --title "Confirm" --yesno "Confirm package(s):\n$confirm_text" 15 70 2>&1 >/dev/tty; then
        > "${OUTPUT_FILE}"
        for line in "${selected_opts[@]}"; do
            case "$line" in
                "Steam - Game launcher")                                                                                     echo "PKG-G1=steam" >> "${OUTPUT_FILE}" ;;
                "Gamescope Session - SteamOS gaming session ported from ChimeraOS")                                          echo "PKG-G2=gamescope-session-steam" >> "${OUTPUT_FILE}" ;;
                "Lutris - Cross-platform game launcher and manager")                                                         echo "PKG-G3=lutris" >> "${OUTPUT_FILE}" ;;
                "Lutris Gamepad UI - Turns your Lutris game library into a console like experience, including game session") echo "PKG-G4=lutris-gamepad-ui" >> "${OUTPUT_FILE}" ;;
                "Heroic - An Open source Launcher for Epic, Amazon and GOG Games")                                           echo "PKG-G5=heroic" >> "${OUTPUT_FILE}" ;;
                "ProtonPlus - Install and manage custom Proton and wine versions for Steam, Lutris and Heroic")              echo "PKG-G6=protonplus" >> "${OUTPUT_FILE}" ;;
                "Gamescope - SteamOS compositor for gaming sessions")                                                        echo "PKG-G7=gamescope" >> "${OUTPUT_FILE}" ;;
                "Goverlay - Gaming overlay for Steam, Lutris, Heroic and more")                                              echo "PKG-G8=goverlay" >> "${OUTPUT_FILE}" ;;
                "Vesktop - A standalone Electron-based Discord app with Vencord & improved Linux support")                   echo "PKG-G9=vesktop" >> "${OUTPUT_FILE}" ;;
            esac
        done
        break
    fi
done
