#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf
unset RAM_SIZE CHOICE

MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_GB=$(( (MEM_KB + 1024 * 1024 / 2) / (1024 * 1024) ))

# Set base color for the installer
echo -ne '\e]10;${G_BASE_COLOR}\a'


clear

while true; do
    CHOICE=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose \
    "Choose Your RAM Size - To Get The Correct RAM Configuration, Nordix detected: ${MEM_GB}GB RAM")

    case "$CHOICE" in
        "RAM Size - 8GB")    RAM_SIZE="8GB" ;;
        "RAM Size - 16GB")   RAM_SIZE="16GB" ;;
        "RAM Size - 32GB")   RAM_SIZE="32GB" ;;
        "RAM Size - 64GB")   RAM_SIZE="64GB" ;;
        "RAM Size - 128GB")  RAM_SIZE="128GB" ;;
    esac

   if [[ -z "$CHOICE" ]]; then
        gum_box "Please select your RAM size!" && true
        continue
    fi
# Confirm drivers to be installed
    gum_confirm "Is This The Correct RAM Size: $RAM_SIZE?" && break

done



gum_spin_timer "Proceeding with ZFS configuration - RAM"



# Choose RAM size
OPTIONS=(
"RAM Size - 8GB"
"RAM Size - 16GB"
"RAM Size - 32GB"
"RAM Size - 64GB"
"RAM Size - 128GB"
)


while true; do
    clear
    gum_box "Choose RAM size with Enter"
    #  show the list of RAM size layouts with gum_choose
    CHOICE=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose "Press Enter to choose")

    # handling ESC/no choise
    if [[ -z "$CHOICE" ]]; then
        clear
        gum_box_sleep "Please select a RAM configuration!" && true
        continue
    fi

    # Map the choice to a variable and break the loop
    case "$CHOICE" in
        "RAM Size - 8GB")   RAM_SIZE="8GB" ;;
        "RAM Size - 16GB")  RAM_SIZE="16GB" ;;
        "RAM Size - 32GB")  RAM_SIZE="32GB" ;;
        "RAM Size - 64GB")  RAM_SIZE="64GB" ;;
        "RAM Size - 128GB") RAM_SIZE="128GB" ;;
    esac

    # Confirm the selected layout
    if gum_confirm "Confirm RAM Size: ${CHOICE}?"; then
        # write RAM size to file
        echo "_RAM=\"$RAM_SIZE\"" > "$SCRIPT_DIR/../config/ram-size.conf"
        break
    fi
done
