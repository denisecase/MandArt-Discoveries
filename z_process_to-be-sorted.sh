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

# Enable nullglob and globdots for this script
setopt nullglob
setopt globdots

# Directory containing .mandart and .png files and RECURSE INTO SUBDIRECTORIES
SOURCE_DIR="to-be-sorted"

# Directory in which to create new subfolders & move files into these new subfolders
BHJ_DIR="brucehjohnson"

mock_safely_move_file() {
    local test_file="$1"
    local dir_name="$2"
    echo "Would move $test_file to $dir_name"
}

# safely_move_file() {
#     local test_file="$1"
#     local dir_name="$2"
#     local base_name=$(basename "$test_file")
#     local dest_path="$dir_name/$base_name"
#     local counter=1

#     # Check if the destination file already exists
#     while [ -f "$dest_path" ]; do
#         # If file exists, generate a new file name with _DUP_<counter> before the file extension
#         local new_base_name="${base_name%.*}_DUP_$counter.${base_name##*.}"
#         dest_path="$dir_name/$new_base_name"
#         ((counter++))
#     done

#     mv "$test_file" "$dest_path"
#     echo "Moved $test_file to $dest_path"
# }

process_png_file() {
    local png_file="$1"
    local xCenter=$(getx_from_png "$png_file")
    local yCenter=$(gety_from_png "$png_file")
    local folder=$(get_folder_for_xy "$xCenter" "$yCenter")
    mock_safely_move_file "$png_file" "$BHJ_DIR/$folder"
}

main() {
    echo "Starting z_process_to-be-sorted.sh"
    log_message "Starting z_process_to-be-sorted.sh"

    # Recurse through SOURCE_DIR and process each .mandart file
    while IFS= read -r file; do
        log_message "Processing file: $file"
        # Get the x and y coordinates from .mandart file
        xCenter=$(getx_from_mandart "$file")
        yCenter=$(gety_from_mandart "$file")

        # Exit if error or xCenter and yCenter are empty
        if [ -z "$xCenter" ] || [ -z "$yCenter" ]; then
            log_message "Error: xCenter or yCenter is empty"
            exit
        fi
        
        # Debug output to check xCenter and yCenter values
        log_message "xCenter from .mandart: $xCenter"
        log_message "yCenter from .mandart: $yCenter"

        # Get the folder mapping
        folder=$(get_folder_for_xy "$xCenter" "$yCenter")
        log_message "file: $file -> folder: $folder"
        echo "file: $file -> folder: $folder"
        mock_safely_move_file "$file" "$BHJ_DIR/$folder"

        # if there is a matching .png file, then safely move it also
        if [[ -f "${file%.*}.png" ]]; then
            mock_safely_move_file "$file" "$BHJ_DIR/$folder"
        fi
        
    done < <(find "$SOURCE_DIR" -type f -iname "*.mandart")

    # After processing the mandart files and any associated .png files
    # Then process any .png files left in the SOURCE_DIR

    # Recurse through SOURCE_DIR and process each .png file
    while IFS= read -r file; do
        log_message "Processing file: $file"
        process_png_file "$file"
    done < <(find "$SOURCE_DIR" -type f -iname "*.png")

    log_message "Completed main() function"
}

main
