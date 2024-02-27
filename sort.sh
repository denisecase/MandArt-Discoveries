#!/bin/bash

# This script is designed to sort .mandart and .png files into subdirectories 
# based on the xCenter and yCenter values in the .mandart JSON files.
#
# To run the script, place it in root project directory, open a terminal and run:
#
# chmod +x sort.sh
#
# ./sort.sh


# xCenter 
# x values range from -2.25 to 0.75 in steps of 0.25/4.0
# x values map to letters a-z and A-V
# x = -2.25 -> a
# x = -2.24444 -> a
# x = 0.0001  -> K

# yCenter
# y values range from -1.25 to 1.25 in steps of 0.25/4.0
# y values map to two-digit codes from 00 to 20 (and from -20 to 00)
# e.g. y = 0.000001 -> 00
# e.g. y = 0.7501 -> 13
# e.g. y = -0.7501 -> -13

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Please install Homebrew and run this script again."
    exit 1
fi

# Check if jq is installed, install if not, or upgrade it
if brew list jq &>/dev/null; then
    #echo "jq is already installed. Upgrading..."
    brew upgrade jq
else
    echo "Installing jq..."
    brew install jq
fi

# Check if bc is installed, install if not, or upgrade it
if brew list bc &>/dev/null; then
    #echo "bc is already installed. Upgrading..."
    brew upgrade bc
else
    echo "Installing bc..."
    brew install bc
fi

# Directory containing your .mandart and .png files - read files from this dir
SOURCE_DIR="to-be-sorted"

# Directory in which to create new subfolders & move files into these new subfolders 
BHJ_DIR="brucehjohnson"

# Calculate index for lookup table based on provided value and step size
calculate_x_index() {
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

populate_xCenterLookup() {
    xCenterLookup=() # Clear existing entries if any
    letters=(a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V)
    value=-2.25
    for i in {0..47}; do
        index=$(calculate_x_index $value 0.0625 -2.25 1)
        xCenterLookup[$index]=${letters[$i]}
        value=$(echo "$value + 0.0625" | bc)
    done
}

# Calculate index for lookup table based on provided value and step size
calculate_y_index() {
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

populate_yCenterLookup() {
    yCenterLookup=() # Clear existing entries if any
    numbers=(-20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -09 -08 -07 -06 -05 -04 -03 -02 -01 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20)
    value=-1.25
    for i in {0..39}; do
        index=$(calculate_x_index $value 0.0625 -1.25 1)
        yCenterLookup[$index]=${numbers[$i]}
        value=$(echo "$value + 0.0625" | bc)
    done
}

: <<comment
# Calculate index for lookup table based on provided value and step size
calculate_y_index() {
    local yValue=$1
    # Adjusting the calculation to ensure -1.25 maps directly to index 0 (code -20)
    local offset=$(echo "$yValue + 1.25" | bc)
    local stepSize=0.0625
    # Calculate index based on offset and step size
    local index=$(echo "scale=0; $offset / $stepSize" | bc)
    echo $index
}

populate_yCenterLookup() {
    yCenterLookup=() # Clear existing entries if any

    # Initialize code at -20 for the lowest yCenter value
    local code=-20
    for index in $(seq 0 40); do  # 41 steps total, covering -20 to 20
        if [ "$code" -ne 0 ]; then
            # Skip the index corresponding to '00'
            if [ "$code" -lt 0 ]; then
                # Format negative codes with two digits and a leading '-'
                yCenterLookup[$index]=$(printf "%03d" $code)
            else
                # Ensure positive codes are stored with two digits
                yCenterLookup[$index]=$(printf "%02d" $code)
            fi
        fi
        ((code++))  # Increment code for next index
    done
}
comment

echo yCenterLookup

main() {
    for json_file in $SOURCE_DIR/*.mandart; do
        echo "Processing $json_file"
        filename=$(basename -- "$json_file")

        # Extract xCenter and yCenter values
        xCenter=$(jq '.xCenter' "$json_file")
        yCenter=$(jq '.yCenter' "$json_file")

        # Calculate xIndex and yIndex for lookup
        xIndex=$(calculate_x_index $xCenter 0.0625 -2.25 1)
        yIndex=$(calculate_y_index $yCenter 0.0625 -1.25 1)

        # Validate indices are within the valid range
        if (( xIndex < 1 || xIndex > 48 || yIndex < 1 || yIndex > 40 )); then
            echo "Notice: xCenter $xCenter or yCenter $yCenter is out of range for $filename. Skipping..."
            continue # Skip to the next .mandart file without creating a folder or moving files
        fi

        # Lookup xLetter and yCode using valid indices
        xLetter=${xCenterLookup[$xIndex]}
        yCode=${yCenterLookup[$yIndex]}

        # Log the intended folder name for verification
        echo "Intended folder: ${xLetter}_${yCode}"

        # Create directory and move files (if indices are valid and this part of the code is reached)
        dir_name="$BHJ_DIR/${xLetter}_${yCode}"
        mkdir -p "$dir_name"
        mv "$json_file" "$dir_name"

        # Match and move corresponding .png file
        base_png_file="${filename%.mandart}"
        shopt -s nocaseglob # Enable case-insensitive globbing
        for png_path in $SOURCE_DIR/${base_png_file}.{png,PNG}; do
            if [ -f "$png_path" ]; then
                mv "$png_path" "$dir_name"
                echo "Moved $filename and $(basename -- "$png_path") to $dir_name"
            fi
        done
        shopt -u nocaseglob # Disable case-insensitive globbing
    done
}

display_lookups() {
    # Print the lookup tables one entry per line
    for i in "${!xCenterLookup[@]}"; do
        echo "xCenterLookup[$i] = ${xCenterLookup[$i]}"
    done
    # Print the lookup tables one entry per line
    for i in "${!yCenterLookup[@]}"; do
        echo "yCenterLookup[$i] = ${yCenterLookup[$i]}"
    done
}

# Call test functions before proceeding with the main script logic
populate_xCenterLookup
populate_yCenterLookup
display_lookups
#test_folder_names
main
