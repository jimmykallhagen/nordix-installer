#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${SCRIPT_DIR}/../config/extra-pkg-gaming.conf"


clear

BACKTITLE="Nordix Installer"

handle_interrupt() {
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --colors --color-mode 2 \
        --title "\Zb\Z1Cannot Exit" \
        --msgbox "You cant exit here" 5 25
    exec "${BASH_SOURCE[0]}" "$@"
}
trap handle_interrupt INT TERM QUIT HUP

OPTIONS=(
    "Steam - Game launcher"
    "Umu Launcher - The Unified Launcher for Windows Games on Linux, to run Proton with fixes outside of Steam"
    "Gamescope Session - SteamOS gaming session ported from ChimeraOS"
    "Lutris - Cross-platform game launcher and manager"
    "Lutris Gamepad UI - Turns your Lutris game library into a console like experience, including game session"
    "Heroic - An Open source Launcher for Epic, Amazon and GOG Games"
    "ProtonPlus - Install and manage custom Proton and wine versions for Steam, Lutris and Heroic"
    "Gamescope - SteamOS compositor for gaming sessions"
    "Goverlay - Gaming overlay for Steam, Lutris, Heroic and more"
    "Vesktop - A standalone Electron-based Discord app with Vencord & improved Linux support"
    "0.A.D - A free, open-source reimplementation of the classic Age of Empires II"
    "Xonotic - A free, open-source reimplementation of the classic Quake III Arena"
    "SuperTuxKart - A free, open-source racing game"
)

while true; do
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --colors --color-mode 2 \
        --title "\ZbExtra Packages" \
        --msgbox "Extra package selection: Gaming" 5 35

    menu_args=()
    i=1
    for opt in "${OPTIONS[@]}"; do
        [[ -z "$opt" ]] && continue
        menu_args+=("$i" "\Zb\Z1$opt" "OFF")
        ((i++))
    done

    selected_tags=$(dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "\Zb\Z0Extra Packages" \
        --colors --color-mode 2 \
        --stdout --checklist "\Zb\Z4| Game launchers - Gaming sessions - Utilities - Discord - Proton" 0 121 13 "${menu_args[@]}")


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
        dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "Info" \
            --msgbox "Maybe next time" 5 30
        break
    fi

    confirm_text=$(printf "%s\n" "${selected_opts[@]}")
    if dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "\ZbConfirm Packages" \
            --yes-label "I want PKG" \
            --yesno "Confirm package(s):\n$confirm_text" 15 70 2>&1 >/dev/tty; then
        > "${OUTPUT_FILE}"
        for line in "${selected_opts[@]}"; do
            case "$line" in
                "Steam - Game launcher")                                                                                     echo "steam" >> "${OUTPUT_FILE}" ;;
                "Umu Launcher - The Unified Launcher for Windows Games on Linux, to run Proton with fixes outside of Steam") echo "umu-launcher" >> "${OUTPUT_FILE}" ;;
                "Gamescope Session Steam - SteamOS gaming session ported from ChimeraOS")                                    echo "gamescope-session-steam-git" >> "${OUTPUT_FILE}" ;;
                "Lutris - Cross-platform game launcher and manager")                                                         echo "lutris" >> "${OUTPUT_FILE}" ;;
                "Lutris Gamepad UI - Turns your Lutris game library into a console like experience, including game session") echo "lutris-gamepad-ui-git" >> "${OUTPUT_FILE}" ;;
                "Heroic - An Open source Launcher for Epic, Amazon and GOG Games")                                           echo "heroic-games-launcher-bin" >> "${OUTPUT_FILE}" ;;
                "ProtonPlus - Install and manage custom Proton and wine versions for Steam, Lutris and Heroic")              echo "protonplus" >> "${OUTPUT_FILE}" ;;
                "Gamescope - SteamOS compositor for gaming sessions")                                                        echo "gamescope" >> "${OUTPUT_FILE}" ;;
                "Goverlay - Gaming overlay for Steam, Lutris, Heroic and more")                                              echo "goverlay" >> "${OUTPUT_FILE}" ;;
                "Vesktop - A standalone Electron-based Discord app with Vencord & improved Linux support")                   echo "vesktop" >> "${OUTPUT_FILE}" ;;
                "0.A.D - A free, open-source reimplementation of the classic Age of Empires II")                             echo "0ad" >> "${OUTPUT_FILE}" ;;
                "Xonotic - A free, open-source reimplementation of the classic Quake III Arena")                             echo "xonotic" >> "${OUTPUT_FILE}" ;;
                "SuperTuxKart - A free, open-source racing game")                                                            echo "supertuxkart" >> "${OUTPUT_FILE}" ;;
            esac
        done
        break
    fi
done
