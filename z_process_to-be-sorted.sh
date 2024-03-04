#!/bin/zsh
# chmod +x z_process_to-be-sorted.sh
# ./z_process_to-be-sorted.sh

#!/bin/zsh

# Source the lookup scripts
source ./z_map_xy_to_folder.sh 
source ./z_getxy_from_mandart.sh 
source ./z_getxy_from_png.sh 

LOG_FILE="zlog_process_to-be-sorted.log"
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# delete the logfile if it exists
if [ -f "$LOG_FILE" ]; then
    rm "$LOG_FILE"
fi

# Enable nullglob and globdots for this script
setopt nullglob
setopt globdots

# Directory cont
aining .mandart and .png files and RECURSE INTO SUBDIRECTORIES
SOURCE_DIR="to-be-sorted"

# Directory in which to create new subfolders & move files into these new subfolders
BHJ_DIR="brucehjohnson/MAPPED"
ERR_DIR="brucehjohnson/MAPPED_NOT"

mock_safely_move_file() {
    local test_file="$1"
    local dir_name="$2"
    echo "Would move $test_file to $dir_name"
}

safely_move_file() {
    local test_file="$1"
    local dir_name="$2"
    local base_name=$(basename "$test_file")
    local dest_path="$dir_name/$base_name"
    local counter=1

    # Ensure destination directory exists
    if [[ ! -d "$dir_name" ]]; then
        mkdir -p "$dir_name"
    fi

    # Check if the destination file already exists, generate a new file name to prevent overwriting
    while [ -f "$dest_path" ]; do
        local new_base_name="${base_name%.*}_$counter.${base_name##*.}"
        dest_path="$dir_name/$new_base_name"
        ((counter++))
    done

    mv "$test_file" "$dest_path"
    log_message "Moved $test_file to $dest_path"
}

process_png_file() {
    local png_file="$1"
    local xCenter=$(getx_from_png "$png_file")
    local yCenter=$(gety_from_png "$png_file")

    # Check if xCenter or yCenter is empty and move to ERR_DIR if either is missing
    if [ -z "$xCenter" ] || [ -z "$yCenter" ]; then
        log_message "Error: Missing xCenter or yCenter for $png_file"
        safely_move_file "$png_file" "$ERR_DIR"
        return
    fi

    local folder=$(get_folder_for_xy "$xCenter" "$yCenter")
    # Proceed with folder assignment and moving
    safely_move_file "$png_file" "$BHJ_DIR/$folder"
}

main() {
    echo "Starting z_process_to-be-sorted.sh"
    log_message "Starting z_process_to-be-sorted.sh"

    # Recurse through SOURCE_DIR and process each .mandart file
    find "$SOURCE_DIR" -type f -iname "*.mandart" | sort | while IFS= read -r file; do
        log_message "------"
        log_message "Processing file: $file"
        # Get the x and y coordinates from .mandart file
        xCenter=$(getx_from_mandart "$file")
        # Exit if error or xCenter is empty
        if [ -z "$xCenter" ]; then
            log_message "Error: xCenter is empty"
            exit
        fi

        yCenter=$(gety_from_mandart "$file")
        # Exit if error or yCenter is empty
        if [ -z "$yCenter" ]; then
            log_message "Error: yCenter is empty"
            exit
        fi
        
        # Debug output to check xCenter and yCenter values
        log_message "xCenter from .mandart: $xCenter"
        log_message "yCenter from .mandart: $yCenter"

        # Get the folder mapping
        folder=$(get_folder_for_xy "$xCenter" "$yCenter")
        log_message "file: $file -> folder: $folder"
        echo "file: $file -> folder: $folder"
        safely_move_file "$file" "$BHJ_DIR/$folder"

        # if there is a matching .png file, then safely move it also
        if [[ -f "${file%.*}.png" ]]; then
            png_fname = "${file%.*}.png"
            log_message "Found matching .png file: $png_fname"
            safely_move_file "$png_fname" "$BHJ_DIR/$folder"
        fi
        
    done 

    # After processing the mandart files and any associated .png files
    # Then process any .png files left in the SOURCE_DIR

    # Recurse through SOURCE_DIR and process each .png file
    find "$SOURCE_DIR" -type f -iname "*.png" | sort | while IFS= read -r file; do
        log_message "------"
        log_message "Processing file: $file"
        process_png_file "$file"
    done 

    log_message "Completed main() function"
}

main
