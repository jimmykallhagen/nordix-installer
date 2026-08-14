#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
MASTER_LIST="${CONFIG_DIR}/drives.conf"
OUTPUT_FILE="$CONFIG_DIR/selected-l2arc-drives.conf"
OUTPUT_FILE_LAYOUT="${CONFIG_DIR}/l2arc-layout.conf"

source $SCRIPT_DIR/../gum-lib/gum.conf
source $CONFIG_DIR/drives.conf

clear
echo -ne "\e]10;${G_BASE_COLOR}\a"

gum_box 'ZFS L2ARC - Level 2 Read Cache'

if gum_confirm 'Do you want to add an L2ARC vdev to your zpool?'; then

gum_spin_timer "Proceeding with L2ARC setup"

# Build list of already used drive by-ids
USED_IDS_FILE=$(mktemp)
cat "${CONFIG_DIR}/selected_boot_drive.conf" \
    "${CONFIG_DIR}/selected_drives.conf" \
    "${CONFIG_DIR}/selected-special-drives.conf" 2>/dev/null > "$USED_IDS_FILE"
# Extract just the by-id part
USED_BYIDS=$(cut -d'=' -f2 "$USED_IDS_FILE" | cut -d' ' -f1 | grep -v '^$' | sort -u)

# Build available drives map excluding used ones
declare -A drive_map
options=()
count=1
while true; do
    var_name="DRIVE_${count}"
    drive_value="${!var_name}"
    [[ -z "$drive_value" ]] && break
    by_id="${drive_value%% *}"
    human_readable="${drive_value#* }"
    # Skip if already used
    if echo "$USED_BYIDS" | grep -Fxq "$by_id"; then
        ((count++))
        continue
    fi
    drive_map["$human_readable"]="$by_id"
    options+=("$human_readable")
    ((count++))
done
rm -f "$USED_IDS_FILE"

if [[ ${#options[@]} -eq 0 ]]; then
    gum_box_sleep "No free drives left for L2ARC"
    exit 1
fi

# Layout selection
OPTIONS=(
"L2ARC - Single    : 1 drive, no redundancy"
"L2ARC - Stripe    : 2+ drives, maximum speed, no redundancy"
"L2ARC - Mirror    : 2 drives, fault tolerant"
"Exit without L2ARC"
)

gum_box "Choose Layout For L2ARC"
while true; do
    clear
    gum_box "Choose Layout For L2ARC"
    _L2ARC=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose "Press Enter to choose")
    [[ -z "$_L2ARC" ]] && { gum_box_sleep "Please select a layout!" ; continue; }
    [[ "$_L2ARC" == "Exit without L2ARC" ]] && exit 0

    case "$_L2ARC" in
        "L2ARC - Single    : 1 drive, no redundancy") _L2ARC="l2arc-single" ;;
        "L2ARC - Stripe    : 2+ drives, maximum speed, no redundancy") _L2ARC="l2arc-stripe" ;;
        "L2ARC - Mirror    : 2 drives, fault tolerant") _L2ARC="l2arc-mirror" ;;
    esac

    if gum_confirm "Confirm L2ARC layout: ${_L2ARC}?"; then
        echo "$_L2ARC" > "${OUTPUT_FILE_LAYOUT}"
        break
    fi
done

get_min_max_drives() {
    case "$_L2ARC" in
        "l2arc-single") echo "1 1" ;;
        "l2arc-stripe") echo "2 999" ;;
        "l2arc-mirror") echo "2 2" ;;
    esac
}
read MIN_DRIVES MAX_DRIVES <<< $(get_min_max_drives)
echo "Layout: $_L2ARC requires minimum $MIN_DRIVES and maximum $MAX_DRIVES drives"

selected_l2arc_drives=""
while true; do
    clear
    gum_box "$_L2ARC (requires $MIN_DRIVES-$MAX_DRIVES drives)"
    if [[ -z "$selected_l2arc_drives" ]]; then
        selected_l2arc_drives=$(printf "%s\n" "${options[@]}" | gum_choose_no_limit "Select Drives for L2ARC")
    fi
    [[ -z "$selected_l2arc_drives" ]] && { gum_box_sleep "Please select at least one drive!"; continue; }

    drive_count=0
    while IFS= read -r line; do [[ -n "$line" ]] && ((drive_count++)); done <<< "$selected_l2arc_drives"

    if [[ $drive_count -lt $MIN_DRIVES ]]; then
        gum_box_sleep "Error: $_L2ARC requires at least $MIN_DRIVES drives (you selected $drive_count)"
        selected_l2arc_drives=""
        continue
    fi
    if [[ $MAX_DRIVES != "999" && $drive_count -gt $MAX_DRIVES ]]; then
        gum_box_sleep "Error: $_L2ARC allows maximum $MAX_DRIVES drives (you selected $drive_count)"
        selected_l2arc_drives=""
        continue
    fi

    if gum_confirm "Confirm selected $drive_count drives for L2ARC?"; then
        break
    fi
    selected_l2arc_drives=""
done

# Write selection
> "${OUTPUT_FILE}"
disk_count=1
while IFS= read -r choice; do
    echo "DRIVE_${disk_count}=${drive_map[$choice]}" >> "$OUTPUT_FILE"
    ((disk_count++))
done <<< "$selected_l2arc_drives"

# Update remaining drives list for next steps
grep -v -Ff <(cut -d'=' -f2 "${OUTPUT_FILE}") "${MASTER_LIST}" | \
awk -F'=' 'BEGIN { i=1 } { printf "DRIVE_%d=%s\n", i, $2; i++ }' > "${CONFIG_DIR}/device_list_l2arc.conf"

clear
gum_spin_timer 'L2ARC configuration complete'
exit 0

else
clear
gum_spin_timer "L2ARC can be added later"
exit 1
fi
