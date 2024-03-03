#!/bin/zsh
#
# To run the script, place it in root project directory, open a terminal and run:
#
# chmod +x scriptmandartfrompng.sh
#
# ./scriptmandartfrompng.sh

# If a .png does not have a corresponding .mandart file, 
# Then create a .mandart from from the png meta data comment field.
# And put the .mandart file in the same directory as the .png file.

SOURCE_DIR="to-be-sorted"

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
            description=$(exiftool -Description "$png_file")
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
create_mandart_from_png


: <<comment

{
  "dFIterMin" : 0,
  "hues" : [
    {
      "b" : 0,
      "color" : {
        "blue" : 0,
        "green" : 0.9999999403953552,
        "red" : 0
      },
      "g" : 255,
      "id" : "8FF7DFC2-85BC-403A-B1A8-D9BCF36A0039",
      "num" : 1,
      "r" : 0
    },
    {
      "b" : 0,
      "color" : {
        "blue" : 0,
        "green" : 0.9999999403953552,
        "red" : 0.9999999403953552
      },
      "g" : 255,
      "id" : "73E571A0-0E01-4FBD-AE4E-A354F28C9303",
      "num" : 2,
      "r" : 255
    },
    {
      "b" : 0,
      "color" : {
        "blue" : 0,
        "green" : 0,
        "red" : 0.9999999403953552
      },
      "g" : 0,
      "id" : "F6D2BA3B-9A23-484E-AD0B-04EFAD596777",
      "num" : 3,
      "r" : 255
    },
    {
      "b" : 0,
      "color" : {
        "blue" : 0,
        "green" : 0,
        "red" : 0
      },
      "g" : 0,
      "id" : "C146933A-090A-4EC6-9663-83DC2B11E149",
      "num" : 4,
      "r" : 0
    },
    {
      "b" : 255,
      "color" : {
        "blue" : 0.9999999403953552,
        "green" : 0,
        "red" : 0.9999999403953552
      },
      "g" : 0,
      "id" : "9F2ED832-7C39-43E4-93F3-5FF90A170F57",
      "num" : 5,
      "r" : 255
    },
    {
      "b" : 255,
      "color" : {
        "blue" : 0.9999999403953552,
        "green" : 0,
        "red" : 0
      },
      "g" : 0,
      "id" : "F1484C87-1857-4771-9C23-E94B6E037AF7",
      "num" : 6,
      "r" : 0
    },
    {
      "b" : 255,
      "color" : {
        "blue" : 0.9999999403953552,
        "green" : 0.9999999403953552,
        "red" : 0
      },
      "g" : 255,
      "id" : "3DC1A378-094D-467D-8D3F-4FAD1ECD3393",
      "num" : 7,
      "r" : 0
    },
    {
      "b" : 255,
      "color" : {
        "blue" : 0.9999999403953552,
        "green" : 0.9999999403953552,
        "red" : 0.9999999403953552
      },
      "g" : 255,
      "id" : "48CE6C57-2E69-447C-935B-6D939FE452EF",
      "num" : 8,
      "r" : 255
    }
  ],
  "huesEstimatedPrintPreview" : [

  ],
  "huesOptimizedForPrinter" : [

  ],
  "id" : "FD6C455C-23DC-4AD3-A356-0CDC34FD473C",
  "imageHeight" : 1000,
  "imageWidth" : 1400,
  "iterationsMax" : 500000,
  "leftNumber" : 1,
  "nBlocks" : 55,
  "nImage" : 0,
  "rSqLimit" : 400,
  "scale" : 50000000,
  "spacingColorFar" : 7,
  "spacingColorNear" : 20,
  "theta" : 0,
  "xCenter" : -0.554239,
  "yCenter" : 0.562056,
  "yY" : 0
}%   

comment