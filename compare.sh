#!/bin/zsh

# To run the script, place it in root project directory, open a terminal and run:
#
# chmod +x compare.sh
#
# ./compare.sh


: <<comment
# March 2024


This script will:

1. Compare files in the FRAME_PIX_DIR, TBS_DIR, TEMP_DIR, TBP_DIR, TBP2_DIR, 
and X_DIR directories against files in the SOURCE_DIR 
(which is the to-be-sorted folder in this case).


2. Move unique files (those not found in SOURCE_DIR) to the SOURCE_DIR.


3. Move duplicate files (those already found in SOURCE_DIR) to the CAN_DELETE_DIR.


4. The script uses a combination of find, md5sum, and awk to 
identify duplicates based on file content rather than file names, 
ensuring that even if two files have different names but identical content, 
one will be considered a duplicate of the other.

comment

# Setup: Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Please install Homebrew and run this script again."
    exit 1
fi

# Setup: Check if jq is installed, install if not, or upgrade it
if brew list jq &>/dev/null; then
    #echo "jq is already installed. Upgrading..."
    brew upgrade jq
else
    echo "Installing jq..."
    brew install jq
fi

# Setup: Check if bc is installed, install if not, or upgrade it
if brew list bc &>/dev/null; then
    #echo "bc is already installed. Upgrading..."
    brew upgrade bc
else
    echo "Installing bc..."
    brew install bc
fi

# Define directories
SOURCE_DIR="to-be-sorted"
BHJ_DIR="brucehjohnson"
FRAME_PIX_DIR="frame_pix"
TBS_DIR="tbs"
TEMP_DIR="temp"
TBP_DIR="to-be-processed"
TBP2_DIR="to-be-processed2"
X_DIR="XXXto-be-sorted"
CAN_DELETE_DIR="can-delete"

# Create a temporary file to store md5sums of files in the to-be-sorted directory
SOURCE_MD5_FILE=$(mktemp)
# Generate md5 for each file in the to-be-sorted directory and store it
find "$SOURCE_DIR" -type f -exec md5sum {} + > "$SOURCE_MD5_FILE"

# Function to echo the actions that will be taken
report_actions() {
    local dir=$1
    echo "Actions for directory: $dir"
    find "$dir" -type f \( -iname "*.png" -o -iname "*.mandart" \) | while read file; do
        if md5sum "$file" | grep -f "$SOURCE_MD5_FILE" > /dev/null; then
            echo "[DRY RUN] Duplicate found, would move to $CAN_DELETE_DIR: $file"
        else
            echo "[DRY RUN] Unique file, would move to $SOURCE_DIR: $file"
        fi
    done
}

# Function to actually move files based on the md5 comparison
process_directory() {
    local dir=$1
    find "$dir" -type f \( -iname "*.png" -o -iname "*.mandart" \) | while read file; do
        if md5sum "$file" | grep -f "$SOURCE_MD5_FILE" > /dev/null; then
            echo "Moving duplicate to $CAN_DELETE_DIR: $file"
            mv "$file" "$CAN_DELETE_DIR/"
        else
            echo "Moving unique file to $SOURCE_DIR: $file"
            mv "$file" "$SOURCE_DIR/"
        fi
    done
}

# Main function to orchestrate the script's operations
main() {
    # Ensure the can-delete directory exists
    mkdir -p "$CAN_DELETE_DIR"

    # Process each directory
    process_directory "$FRAME_PIX_DIR"
    process_directory "$TBS_DIR"
    process_directory "$TEMP_DIR"
    process_directory "$TBP_DIR"
    process_directory "$TBP2_DIR"
    process_directory "$X_DIR"

    # Clean up temporary file
    rm "$SOURCE_MD5_FILE"
}

# First, report the actions that will be taken
report_actions "$FRAME_PIX_DIR"
report_actions "$TBS_DIR"
report_actions "$TEMP_DIR"
report_actions "$TBP_DIR"
report_actions "$TBP2_DIR"
report_actions "$X_DIR"

Confirm with the user before proceeding
read -p "Proceed with file operations? (y/n) " confirm
if [[ "$confirm" == "y" ]]; then
    main
else
    echo "Operation aborted."
    rm "$SOURCE_MD5_FILE" # Clean up the temporary file if operation is not confirmed
fi
