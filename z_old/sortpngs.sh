#!/bin/zsh
#
# To run the script, place it in root project directory, open a terminal and run:
#
# chmod +x sortpngs.sh
#
# ./sortpngs.sh

SOURCE_DIR="to-be-sorted"

get_description_from_png(png_file) {
    metadata=$(exiftool "$png_file")
    description=$(exiftool -Description "$png_file" )
    return $description
}

extract_xCenter_from_png(png_file) {
    description=$(get_description_from_png "$png_file")
    xCenter=$(extract_value "xCenter")
    return $xCenter
} 

extract_yCenter_from_png(png_file) {
    description=$(get_description_from_png "$png_file")
    yCenter=$(extract_value "yCenter")
    return $yCenter
}

# Function to extract a value for a given key from the description
extract_value() {
    local key="$1"
    # Replace . with newline, then use awk to find the line with the key and print the value
    local value=$(echo "$description" | tr '.' '\n' | awk -v key="$key" '$0 ~ key {gsub(/.* is /, ""); print; exit}')
    echo "$value"
}

# Function to create .mandart file from .png metadata
create_mandart_from_png() {
    for png_file in "$SOURCE_DIR"/*.png; do
        echo "Processing $png_file"

        # Extract the filename without extension
        base_name=$(basename "$png_file" .png)
        
        # Define the new .mandart file path
        mandart_file="${png_file%.*}.mandart"
        
        # Check if the .mandart file already exists
        if [ ! -f "$mandart_file" ]; then
            metadata=$(exiftool "$png_file")
            description=$(exiftool -Description "$png_file" )
 
            dFIterMin=$(extract_value "dFIterMin")
            id=$(extract_value "id")
            imageHeight=$(extract_value "imageHeight")
            imageWidth=$(extract_value "imageWidth")
            iterationsMax=$(extract_value "iterationsMax")
            leftNumber=$(extract_value "leftNumber")
            nBlocks=$(extract_value "nBlocks")
            rSqLimit=$(extract_value "rSqLimit")
            scale=$(extract_value "scale")
            spacingColorFar=$(extract_value "spacingColorFar")
            spacingColorNear=$(extract_value "spacingColorNear")
            theta=$(extract_value "theta")
            xCenter=$(extract_value "xCenter")
            yCenter=$(extract_value "yCenter")
            yY=$(extract_value "yY")

            echo "xCenter: $xCenter"
            echo "yCenter: $yCenter"
            echo "imageWidth: $imageWidth"
            echo "imageHeight: $imageHeight"

            
          # Construct the .mandart JSON content
            json_content=$(cat <<-EOF
{
  "xCenter": $xCenter,
  "yCenter": $yCenter,
  "imageWidth": $imageWidth,
  "imageHeight": $imageHeight,
  "iterationsMax": $iterationsMax,
  "scale": $scale,
  "spacingColorFar": $spacingColorFar,
  "spacingColorNear": $spacingColorNear,
  "rSqLimit": $rSqLimit,
  "theta": $theta,
  "nBlocks": $nBlocks,
  "leftNumber": $leftNumber,
  "nImage": $nImage,
  "yY": $yY,
  "id": $id,
  "dFIterMin": $dFIterMin
}
EOF
)

            # Write the JSON content to the .mandart file
            echo "$json_content" > "$mandart_file"
            echo "Created $mandart_file"
       else
           echo "$mandart_file already exists."
       fi
    done
}


# Run the function to create .mandart files from .png metadata
# create_mandart_from_png

