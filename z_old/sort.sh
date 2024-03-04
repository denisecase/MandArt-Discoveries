#!/bin/zsh
 on the xCenter and yCenter values in the .mandart JSON files.
#
# To run the script, place it in root project directory, open a terminal and run:
# chmod +x sort.sh
# ./sort.sh
#
#!/bin/zsh

# in the same directory as this script
source ./z_map.sh

LOG_FILE="zlog_sort.log"

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

safely_move_file() {
    local test_file="$1"
    local dir_name="$2"
    local base_name=$(basename "$test_file")
    local dest_path="$dir_name/$base_name"
    local counter=1

    # Check if the destination file already exists
    while [ -f "$dest_path" ]; do
        # If file exists, generate a new file name with _DUP_<counter> before the file extension
        local new_base_name="${base_name%.*}_DUP_$counter.${base_name##*.}"
        dest_path="$dir_name/$new_base_name"
        ((counter++))
    done

    mv "$test_file" "$dest_path"
    echo "Moved $test_file to $dest_path"
}

process_file() {
    local file="$1"

    # Determine if it's a .mandart or .png file and extract xCenter and yCenter
    if [[ "$file" =~ \.mandart$ ]]; then
        xCenter=$(jq '.xCenter' "$file")
        yCenter=$(jq '.yCenter' "$file")
    else
        description=$(get_description_from_png "$file")
        xCenter=$(echo "$description" | awk '/xCenter/ {print $NF}')
        yCenter=$(echo "$description" | awk '/yCenter/ {print $NF}')
    fi

    # Get bucket letters/numbers
    local xBucket=$(get_xCenter_bucket "$xCenter")
    local yBucket=$(get_yCenter_bucket "$yCenter")
    local dir_name="$BHJ_DIR/${xBucket}_${yBucket}"

    mkdir -p "$dir_name"
    mock_safely_move_file "$file" "$dir_name"
}

main() {
    # Recurse through SOURCE_DIR and process each .mandart and .png file
    find "$SOURCE_DIR" -type f \( -iname "*.mandart" -o -iname "*.png" \) | while read file; do
        process_file "$file"
    done
}

main
