#!/bin/bash

# This script is designed to sort .json and .png files into subdirectories 
# based on the xCenter and yCenter values in the JSON files.
#
# To run the script, place it in root project directory, open a terminal and run:
#
# chmod +x sort.sh
#
# ./sort.sh

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Please install Homebrew and run this script again."
    exit 1
fi

# Check if jq is installed, install if not, or upgrade it
if brew list jq &>/dev/null; then
    echo "jq is already installed. Upgrading..."
    brew upgrade jq
else
    echo "Installing jq..."
    brew install jq
fi

# Check if bc is installed, install if not, or upgrade it
if brew list bc &>/dev/null; then
    echo "bc is already installed. Upgrading..."
    brew upgrade bc
else
    echo "Installing bc..."
    brew install bc
fi


# Directory containing your .mandart and .png files - read files from this dir
SOURCE_DIR="to-be-sorted"

# Directory in which to create new subfolders & move files into these new subfolders 
BHJ_DIR="brucehjohnson"

# xCenter 
# x values range from -2.25 to 0.75 in steps of 0.25/4.0
# x values map to letters a-z and A-V
# e.g. x = -2.2444444 -> a
# e.g. x = 0.0001  -> K

# yCenter
# y values range from -1.25 to 1.25 in steps of 0.25/4.0
# y values map to two-digit codes from 00 to 20 (and from -20 to 00)
# e.g. y = 0.000001 -> 00
# e.g. y = 0.7501 -> 13
# e.g. y = -0.7501 -> -13

# Calculate index for lookup tables based on provided value and step size
calculate_index() {
    value=$1
    step=$2
    min=$3
    scale=$4
    # Normalize value based on min and scale
    norm=$(echo "($value - $min) / $step" | bc -l)
    # Calculate index (1-based)
    index=$(echo "scale=0; ($norm / 1) + 1" | bc)
    echo $index
}

# Initialize lookup tables
declare -A xCenterLookup
declare -A yCenterLookup

# Populate xCenterLookup
letters=(a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V)
value=-2.25
for i in {0..51}; do
    index=$(calculate_index $value 0.0625 -2.25 1)
    xCenterLookup[$index]=${letters[$i]}
    value=$(echo "$value + 0.0625" | bc)
done

# Populate yCenterLookup
for i in {-20..20}; do
    index=$(calculate_index $i 0.25 -1.25 4)
    if [[ $i -lt 0 ]]; then
        yCenterLookup[$index]=$(printf "%02d" $((20 + $i + 1)))
    else
        yCenterLookup[$index]=$(printf "%02d" $i)
    fi
done


# Loop through all JSON files in the source directory
for json_file in $SOURCE_DIR/*.mandart; do
    # Extract filename without path
    filename=$(basename -- "$json_file")

    # Extract xCenter and yCenter values (assuming they are floats)
    xCenter=$(jq '.xCenter' "$json_file")
    yCenter=$(jq '.yCenter' "$json_file")

    # Calculate index for lookup
    xIndex=$(calculate_index $xCenter 0.0625 -2.25 1)
    yIndex=$(calculate_index $yCenter 0.25 -1.25 4)

    # Lookup the corresponding letter and code
    xLetter=${xCenterLookup[$xIndex]}
    yCode=${yCenterLookup[$yIndex]}

    # Create a directory name based on lookup results
    dir_name="$BHJ_DIR/${xLetter}_${yCode}"
    mkdir -p "$dir_name"

    # Construct the PNG file name from the JSON file name
    png_file="${filename%.json}.png"
    png_path="$SOURCE_DIR/${png_file}"

    # Move the JSON and PNG files to the created directory
    mv "$json_file" "$dir_name"
    if [ -f "$png_path" ]; then
        mv "$png_path" "$dir_name"
    fi

    echo "Moved $filename and $png_file to $dir_name"
done