#!/bin/zsh
# chmod +x z_script_index_files.sh
# ./z_script_index_files.sh

LOG_FILE="zlog_script_index_files.log"
MAPPED_DIR="brucehjohnson/MAPPED"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

generate_index_page() {
    local FOLDER_NAME=$1
    local INDEX_MD="${FOLDER_NAME}/index.md"

    # Header of the index page
    cat > $INDEX_MD <<EOF
# $FOLDER_NAME

Contributed by:

- [github.com/brucehjohnson](https://github.com/brucehjohnson)

Discoveries folder:

- [MandArt-Discoveries/brucehjohnson](https://github.com/denisecase/MandArt-Discoveries/tree/main/brucehjohnson)

-----

These are taken from the $FOLDER_NAME region. 

EOF

    # Function to generate the download link if .mandart file exists
    generate_link() {
        local file_name=$(basename "$1")
        if [ -f "$1" ]; then
            echo "<a href=\"$file_name\" download=\"$file_name\">Click here to download</a><br>"
        else
            echo "Not available for download"
        fi
    }

    # Iterate over png files and generate Markdown snippet for each
    for png_file in $(find $FOLDER_NAME -type f -name "*.png" | sort); do
        local base_name=$(basename "$png_file" .png)
        local mandart_file_name="${base_name}.mandart"
        local png_file_name="${base_name}.png"

        # Append file section to the index page
        cat >> $INDEX_MD <<EOF

## $base_name

$(generate_link "${FOLDER_NAME}/${mandart_file_name}")
!["$base_name"]($png_file_name)

EOF
    done

    log_message "Index page generated for $FOLDER_NAME"
}

main() {
    # Check if the MAPPED_DIR exists
    if [ ! -d "$MAPPED_DIR" ]; then
        echo "The directory $MAPPED_DIR does not exist."
        exit 1
    fi

    # Process all the folders in the MAPPED_DIR
    for folder in $MAPPED_DIR/*; do
        if [ -d "$folder" ]; then
            echo "Generating index for $folder"
            log_message "Generating index for $folder"
            # if there is an index.md file, remove it
            if [ -f "$folder/index.md" ]; then
                rm "$folder/index.md"
            fi
            # if there is an index.html file, remove it
            if [ -f "$folder/index.html" ]; then
                rm "$folder/index.html"
            fi
            generate_index_page "$folder"
        fi
    done
}

main
