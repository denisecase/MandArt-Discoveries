#!/bin/bash

# To run the script, place it in root project directory, open a terminal and run:
#
# chmod +x remspaces.sh
#
# ./remspaces.sh

# Define your directories
directories=("tbs" "temp" "to-be-processed" "to-be-processed2" "XXXto-be-sorted")

# Function to preprocess file names
preprocess_file_names() {
    local dir=$1
    echo "Preprocessing files in $dir..."
    # Find all files in the directory
    find "$dir" -type f | while read file; do
        # Extract directory path and base name
        dir_path=$(dirname "$file")
        base_name=$(basename "$file")
        
        # Remove spaces and enforce two-digit numbering for the file name
        # This regex targets names with a digit sequence, adding a leading zero if necessary
        new_name=$(echo "$base_name" | sed -e 's/ //g' -e 's/\([a-zA-Z]\)\([0-9]\)\./\10\2./' -e 's/\([a-zA-Z]\+\)\([0-9]\{2,\}\)\./\1\2./')
        
        # Only rename if changes are made to avoid unnecessary operations
        if [[ "$base_name" != "$new_name" ]]; then
            mv -n "$file" "$dir_path/$new_name"
            echo "Renamed $file to $dir_path/$new_name"
        fi
    done
}

# Preprocess each directory
for dir in "${directories[@]}"; do
    preprocess_file_names "$dir"
done
