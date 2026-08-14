#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf
source $SCRIPT_DIR/../config/drives.conf
MASTER_LIST="${CONFIG_DIR}/additional_drives.conf"

ZFS_INFO_ADVANCED="${SCRIPT_DIR}/../info/zfs-info-advanced"
CONFIG_DIR="${SCRIPT_DIR}/../config"
OUTPUTFILE_LAYOUT="${CONFIG_DIR}/selected-additional-layout.conf"
OUTPUTFILE_DEVICES_LIST="${CONFIG_DIR}/additional-device-list.conf"
OUTPUTFILE_LAYOUT_SLOG="${CONFIG_DIR}/slog-layout.conf"
OUTPUTFILE_SLOG_DEVICES="${CONFIG_DIR}/additional-devices-slog.conf"

# Set base color for the installer
echo -ne "\e]10;${G_BASE_COLOR}\a"


# Function for slog, select layout and devices and dont show already selected devices
function_slog() {
clear

# options for slog
local OPTIONS=(
"SLOG - Single    : 1 drive, no redundancy"
"SLOG - Stripe    : 2+ drives, maximum speed, no redundancy (Similar to RAID0)"
"SLOG - Mirror    : 2 drives, fault tolerant (Similar to RAID 1)"
"Exit without SLOG"
)
gum_box "Starting SLOG layout selection"
gum_spin_timer "Gathering some SLOG's layout....."

while true; do
    clear
    gum_box "Choose Layout For SLOG"
    #  show the list of zpools layouts with gum_choose
    _SLOG=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose "Press Enter to choose")

    # handling ESC/no choise
    if [[ -z "$_SLOG" ]]; then
        clear
        gum_box_sleep "Please select a layout!" && true
        continue
    fi
    if [[ "$_SLOG" == "Exit without SLOG" ]]; then
        clear
        #gum_spin_timer "Leaving SLOG..."
        #gum_spin_timer "Maybe next time."
        return
    fi
    # Map the choice to a variable and break the loop
    case "$CHOICE_SLOG" in
        "SLOG - Single    : 1 drive, no redundancy")                                       _SLOG="slog-single" ;;
        "SLOG - Stripe    : 2+ drives, maximum speed, no redundancy (Similar to RAID0)")   _SLOG="slog-stripe" ;;
        "SLOG - Mirror    : 2 drives, fault tolerant (Similar to RAID 1)")                 _SLOG="slog-mirror" ;;
    esac

    # Confirm the selected layout
    if gum_confirm "Confirm SLOG Layout: ${_SLOG}?"; then
        # write slog layout to file
        echo "${_SLOG}" > "${OUTPUTFILE_LAYOUT_SLOG}"
        break
    fi
done


  local LIST_DEVICE=$(grep -v -Ff <(cut -d'=' -f2 "${OUTPUTFILE_DEVICES_LIST}") "${MASTER_LIST}" | \
  awk -F'=' 'BEGIN { i=1 } { printf "DRIVE_%d=%s\n", i, $2; i++ }')

losource <(echo "$LIST_DEVICE")

	local declare -A drive_map=()
	local options_devices=()
	local count=1
	while true; do
		local var_name="DRIVE_${count}"
		local drive_value="${!var_name}"

		if [[ -z "$drive_value" ]]; then
			break
		fi

		#  by-id
		local by_id="${drive_value%% *}"                     # "/dev/disk/by-id/ata-Samsung..."
		local human_readable="${drive_value#* }"             # "Samsung SSD 860 EVO - 465.8G"

		local drive_map["${human_readable}"]="${by_id}"
		options_devices+=("${human_readable}")

		((count++))
		done


get_min_max_drives_slog() {
    case ${_SLOG} in
        "slog-single")       echo "1 1" ;;   # max 1 drive
        "slog-stripe")       echo "2 999" ;; # min 2, no real max
        "slog-mirror")   echo "2 2" ;;   # exactly 2 drives
    esac
}
read MIN_DRIVES MAX_DRIVES <<< $(get_min_max_drives_slog)

echo "Layout: ${_SLOG} requires minimum $MIN_DRIVES and maximum $MAX_DRIVES drives"

# Read previously selected drives count (if any)
declare -a drive_choices=()
while IFS= read -r choice; do
    drive_choices+=("$choice")
done <<< "$selected_drives"

current_count=${#drive_choices[@]}

# Check if previous selection is valid, otherwise clear it
if [[ $current_count -lt $MIN_DRIVES || $current_count -gt $MAX_DRIVES ]]; then
    selected_drives=""
fi

while true; do
    clear
    gum_box "$_SLOG (requires $MIN_DRIVES-$MAX_DRIVES drives)"

    if [[ -z "$selected_drives" ]]; then
        selected_drives=$(printf "%s\n" "${options_devices[@]}" | gum_choose_no_limit "Select Drives For Your SLOG - Select WIth Space Confirm With Enter")
    fi

    # If no drive is selected, show an error and continue
    if [[ -z "$selected_drives" ]]; then
        gum_box_sleep "Please select at least one drive!"
        continue
    fi

    # Count selected drives
    drive_count=0
    while IFS= read -r line; do
        [[ -n "$line" ]] && ((drive_count++))
    done <<< "$selected_drives"

    # Validate drive count
    if [[ $drive_count -lt $MIN_DRIVES ]]; then
        gum_box_sleep "Error: $_SLOG layout requires at least $MIN_DRIVES drives (you selected $drive_count)"
        selected_drives=""  # Clear selection to retry
        continue
    fi

    if [[ $MAX_DRIVES != "999" && $drive_count -gt $MAX_DRIVES ]]; then
        gum_box_sleep "Error: $_SLOG layout allows maximum $MAX_DRIVES drives (you selected $drive_count)"
        selected_drives=""  # Clear selection to retry
        continue
    fi

    # Confirm drivers to be installed
    if gum_confirm "Confirm selected $drive_count drives: $selected_drives?"; then
        break
    fi
    selected_drives=""  # Clear selection to retry
done

# Clear the selected drives config
sed -i '/^DRIVE_/d'  "${OUTPUTFILE_LAYOUT_SLOG}"

# Write selected by-id to new config
> "${OUTPUTFILE_LAYOUT_SLOG}"
disk_count=1

while IFS= read -r choice; do
    echo "DRIVE_${disk_count}=${drive_map[$choice]}" >> "${OUTPUTFILE_SLOG_DEVICES}"
    ((disk_count++))
done <<< "$selected_drives"

cat "${OUTPUTFILE_SLOG_DEVICES}" | echo > "${OUTPUTFILE_DEVICES_LIST}"

}

while true; do
    clear

    gum_box "Advanced ZFS vdev Selection: Special Vdev, L2ARC, SLOG"
    # Build options dynamically based on what's already selected
    OPTIONS_ADVANCED=(
        "Nordix ZFS Additional vdev's help"
""
    )

    # Add available vdev types (not yet selected)
    [[ -z "${EXTRA_VDEVs[slog]}" ]] && OPTIONS_ADVANCED+=("SLOG")
    [[ -z "${EXTRA_VDEVs[l2arc]}" ]] && OPTIONS_ADVANCED+=("L2ARC")
    [[ -z "${EXTRA_VDEVs[special]}" ]] && OPTIONS_ADVANCED+=("Special Vdev")

    # Only show Continue if we have at least one selection
    if [[ ${#EXTRA_VDEVs[@]} -gt 0 ]]; then
        OPTIONS_ADVANCED+=("")
        OPTIONS_ADVANCED+=("Continue to drive selection")
    fi

    OPTIONS_ADVANCED+=("Continue without changes")

    CHOICE_ADVANCED=$(printf "%s\n" "${OPTIONS_ADVANCED[@]}" | gum_choose "Press Enter to choose (or Exit)")

    # handling ESC/no choise
    if [[ -z "$CHOICE_ADVANCED" ]]; then
        continue
    fi

    case "$CHOICE_ADVANCED" in
        "Nordix ZFS Additional vdev's help")
            clear
            gum_spin_timer "Gather info..." && true
            gum_pager < "${ZFS_INFO_ADVANCED}"
            gum_spin_timer "Now you know..."
            ;;
        "SLOG")
            gum_box "Select device(s) for SLOG (write log)"
            function_slog
            ;;
        "L2ARC")
            gum_box "Select device(s) for L2ARC (read cache)"
            l2rc_choice=$(printf "%s\n" "${options_devices[@]}" | gum_choose)
            if [[ -n "$l2arc_choice" ]]; then
                EXTRA_DEVICES[l2arc]="${drive_map[$l2rc_choice]}"
                EXTRA_VDEVs+=("l2arc")
                echo "L2ARC device: $l2rc_choice"
            fi
            ;;
        "Special Vdev")
            gum_box "Select device(s) for Special vdev (metadata/small files)"
            special_choice=$(printf "%s\n" "${options_devices[@]}" | gum_choose)
            if [[ -n "$special_choice" ]]; then
                EXTRA_DEVICES[special]="${drive_map[$special_choice]}"
                EXTRA_VDEVs+=("special")
                echo "Special device: $special_choice"
            fi
            ;;
        "Continue to drive selection")
            break  # Exit loop and continue with main drive selection
            ;;
        "Exit without changes")
            EXTRA_DEVICES=()
            EXTRA_VDEVs=()
            break  # Exit without selecting any extra vdevs
            ;;
    esac
done

# Store selected extra devices to config if any were chosen
if [[ ${#EXTRA_VDEVs[@]} -gt 0 ]]; then
    for vdev_type in "${EXTRA_VDEVs[@]}"; do
        echo "EXTRA_${vdev_type^^}=${EXTRA_DEVICES[$vdev_type]}" >> "OUTPUTFILE_LAYOUT"
    done
fi

gum_spin_timer "Proceeding to drive selection..."

while true; do
    clear
    gum_box "Choose Additional vdev's"
    #  show the list of zpools layouts with gum_choose
    CHOICE_ADVANCED=$(printf "%s\n" "${OPTIONS_ADVANCED[@]}" | gum_choose "Press Enter to choose")

    # handling ESC/no choise
    if [[ -z "$CHOICE_ADVANCED" ]]; then
        clear
        gum_box_sleep "Please select an additional vdev!" && true
        continue
    fi

    # show help
    if [[ "$CHOICE_ADVANCED" == "Nordix ZFS Additional vdev's help" ]]; then
        clear
        gum_spin_timer "Gather info..." && true
        zfs_info_advanced
        gum_spin_timer "Now you know..."
        continue
    fi
