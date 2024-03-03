#!/bin/zsh

# chmod +x z_map_xy_to_folder.sh
# ./z_map_xy_to_folder.sh


# Source lookup scripts
source ./z_lookupx.sh
source ./z_lookupy.sh

LOG_FILE="zlog_map_xy_to_folder.log"

# Log message function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Export this function
get_folder_for_xy() {
    local xCenter="$1"
    local yCenter="$2"

    # Use the lookup functions to get the codes
    local xBucket=$(get_xCenter_bucket "$xCenter")
    local yBucket=$(get_yCenter_bucket "$yCenter")

    # Construct the folder name using xBucket and yBucket
    local folderName="${xBucket}${yBucket}"

    # Return the folder name
    echo "$folderName"
}

# Test function with a list of file paths
test_files() {
    log_message "Running test_files() function"
    echo "Running test_files() function"

    local files=(
        "to-be-sorted/AAB1.mandart"
        "to-be-sorted/AAB2.mandart"
    )

    for file in "${files[@]}"; do
        # Determine the file type and extract xCenter and yCenter
        if [[ "$file" =~ \.mandart$ ]]; then
            xCenter=$(jq -r '.xCenter' "$file")      
            yCenter=$(jq -r '.yCenter' "$file")
        elif [[ "$file" =~ \.png$ ]]; then
            # For PNG files, assume get_description_from_png returns a string from which xCenter and yCenter can be parsed
            description=$(get_description_from_png "$file")
            xCenter=$(echo "$description" | awk '/xCenter/ {print $NF}')
            yCenter=$(echo "$description" | awk '/yCenter/ {print $NF}')
        else
            log_message "Unsupported file type for $file"
            continue
        fi

        folder=$(get_folder_for_xy "$xCenter" "$yCenter")
        if [ -n "$folder" ]; then
            log_message "File: $file -> Folder: $folder (Success)"
            echo "File: $file -> Folder: $folder (Success)"
        else
            log_message "Error: Failed to get folder for file: $file"
            echo "Error: Failed to get folder for file: $file"
        fi
    done

    log_message "Completed test_files() function"
}

#test_files
