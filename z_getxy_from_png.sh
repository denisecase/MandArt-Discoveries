#!/bin/zsh

# chmoe +x z_readxy_from_png.sh
# ./z_readxy_from_png.sh

LOG_FILE="zlog_getxy_from_png.log"
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Export this function
getx_from_png() {
    local png_file="$1"
    local description=$(get_description_from_png "$png_file")
    local xCenter=$(get_value_from_description "$description" "horizontal_xCenter")
    echo "$xCenter"
}

# Export this function
gety_from_png() {
    local png_file="$1"
    local description=$(get_description_from_png "$png_file")
    local yCenter=$(get_value_from_description "$description" "vertical_yCenter")
    echo "$yCenter"
}

get_metadata_from_png() {
    local png_file="$1"
    metadata=$(exiftool "$png_file")
    echo "$metadata"
}

get_description_from_metadata() {
    local metadata="$1"
    local description=$(echo "$metadata" | grep -oE 'Description\s*:\s*.+' | sed 's/Description\s*:\s*//')
    echo "$description"
}

get_description_from_png() {
    local png_file="$1"
    local metadata=$(get_metadata_from_png "$png_file")
    if [ -z "$metadata" ]; then
        log_message "Error: Failed to get metadata for $png_file"
        return
    fi
    local description=$(get_description_from_metadata "$metadata")
    echo "$description"
}

get_value_from_description() {
    local description="$1"
    local key="$2"
    local value=$(echo "$description" | grep -oE "\.$key\s*is\s*-?[0-9]+(\.[0-9]+)?")
    if [ -z "$value" ]; then
        log_message "Error: $key not found in description"
        return
    fi
    echo "$value" | awk '{print $NF}'
}

get_center_from_description() {
    local description="$1"
    local axis="$2"
    local key="${axis}_yCenter"  # Corrected to use "vertical_yCenter"
    local value=$(get_value_from_description "$description" "$key")
    if [ -z "$value" ]; then
        log_message "Error: $key not found in description"
        return
    fi
    echo "$value"
}




main() {
    log_message "Starting main() function"
    echo "Starting main() function"

    local f="to-be-sorted/Frame16.png"
    log_message "Processing png file: $f"
    echo "Processing png file: $f"

    local xCenter=$(getx_from_png "$f")
    log_message "Read xCenter: $xCenter"
    echo "Read xCenter: $xCenter"

    local yCenter=$(gety_from_png "$f")
    log_message "Read yCenter: $yCenter"
    echo "Read yCenter: $yCenter"

    log_message "Completed main() function"
    echo "Completed main() function"
}

#main
