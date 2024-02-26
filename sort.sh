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

populate_yCenterLookup() {
    yCenterLookup=() # Clear existing entries if any

    # Initialize code at -20 for the lowest yCenter value and increment
    local code=-20
    for index in $(seq 0 40); do  # 41 steps total, covering -20 to 20
        if [ "$code" -lt 0 ]; then
            # Format negative codes with two digits and a leading '-'
            yCenterLookup[$index]=$(printf "%03d" $code)
        elif [ "$code" -eq 0 ]; then
            # Special handling for 0 to align with desired format
            yCenterLookup[$index]="00"
        else
            # Ensure positive codes are stored with two digits
            yCenterLookup[$index]=$(printf "%02d" $code)
        fi
        ((code++))  # Increment code for next index
    done
}


test_xCenters() {
    local test_passed=true
    # add one expected value for the start of each new letter 
    local xValues=(-2.25 -2.1875 -2.125 -2.0625 -2.0 -1.9375 -1.875 -1.8125 -1.75 -1.6875 -1.625 -1.5625 -1.5 -1.4375 -1.375 -1.3125 -1.25 -1.1875 -1.125 -1.0625 -1.0 -0.9375 -0.875 -0.8125 -0.75 -0.6875 -0.625 -0.5625 -0.5 -0.4375 -0.375 -0.3125 -0.25 -0.1875 -0.125 -0.0625 0.0 0.0625 0.125 0.1875 0.25 0.3125 0.375 0.4375 0.5 0.5625 0.625 0.6875 0.75)
    local expectedLetters=(a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V)

    for i in "${!xValues[@]}"; do
        local expected="${expectedLetters[$i]}"
        local actualIndex=$(calculate_x_index ${xValues[$i]} 0.0625 -2.25 1)
        local actual=${xCenterLookup[$actualIndex]}
        
        if [ "$actual" != "$expected" ]; then
            echo "Test xCenter with value ${xValues[$i]} failed: expected $expected, got $actual"
            test_passed=false
        else
            echo "Test xCenter with value ${xValues[$i]} passed: expected $expected, got $actual"
        fi
    done

    if [ "$test_passed" = true ]; then
        echo "************************"
        echo "All xCenter tests passed."
        echo "************************"

    else
        echo "Some xCenter tests failed."
    fi
}

test_yCenters() {
    local test_passed=true
    # add one expected value for the start of each new letter 
    local yValues=(-1.25 $(seq -1.1875 0.0625 1.1875) 1.25)
    local expectedCodes=(-20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -09 -08 -07 -06 -05 -04 -03 -02 -01 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20)

    for i in "${!yValues[@]}"; do
        local expected="${expectedCodes[$i]}"
        local actualIndex=$(calculate_y_index ${yValues[$i]} 0.0625 -1.25 1)
        local actual=${yCenterLookup[$actualIndex]}

        if [ "$actual" != "$expected" ]; then
            echo "Test yCenter with value ${yValues[$i]} failed: expected $expected, got $actual"
            test_passed=false
        else
            echo "Test yCenter with value ${yValues[$i]} passed: expected $expected, got $actual"
        fi
    done

    if [ "$test_passed" = true ]; then
        echo "************************"
        echo "All yCenter tests passed."
        echo "************************"
    else
        echo "Some yCenter tests failed."
    fi
}

test_folder_names() {
    local test_passed=true

    # Predefined test cases with expected folder names
    declare -a testCases=(
        "-2.25,-1.25,a_-20"
        "0.75,1.25,V_20"
        "0.0,0,K_00"
        "-1.75,-0.75,i_-12"
    )

    for testCase in "${testCases[@]}"; do
        IFS=',' read -r xCenter yCenter expectedFolder <<< "$testCase"

        # Calculate indices
        local xIndex=$(calculate_x_index $xCenter 0.0625 -2.25 1)
        local yIndex=$(calculate_y_index $yCenter 0.0625 -1.25 1)
        
        # Validate indices are within the valid range
        if (( xIndex < 1 || xIndex > 48 || yIndex < 0 || yIndex > 40 )); then
            echo "Error: xCenter $xCenter or yCenter $yCenter is out of range."
            test_passed=false
            continue # Skip this test case and move to the next
        fi

        # Lookup
        local xLetter=${xCenterLookup[$xIndex]}
        local yCode=${yCenterLookup[$yIndex]}

        # Construct folder name
        local folderName="${xLetter}_${yCode}"

        if [ "$folderName" != "$expectedFolder" ]; then
            echo "Test folder name with xCenter $xCenter and yCenter $yCenter failed: expected $expectedFolder, got $folderName"
            test_passed=false
        else
            echo "Test folder name with xCenter $xCenter and yCenter $yCenter passed: expected $expectedFolder, got $folderName"
        fi
    done

    if [ "$test_passed" = true ]; then
        echo "All folder name tests passed."
    else
        echo "Some folder name tests failed."
    fi
}


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
        if (( xIndex < 1 || xIndex > 48 || yIndex < 0 || yIndex > 40 )); then
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
test_xCenters
test_yCenters
test_folder_names
main

# (base) denisecase@Denises-MacBook-Air MandArt-Discoveries % ./sort.sh
# Warning: jq 1.7.1 already installed
# Warning: bc 1.07.1 already installed
# xCenterLookup[1] = a
# xCenterLookup[2] = b
# xCenterLookup[3] = c
# xCenterLookup[4] = d
# xCenterLookup[5] = e
# xCenterLookup[6] = f
# xCenterLookup[7] = g
# xCenterLookup[8] = h
# xCenterLookup[9] = i
# xCenterLookup[10] = j
# xCenterLookup[11] = k
# xCenterLookup[12] = l
# xCenterLookup[13] = m
# xCenterLookup[14] = n
# xCenterLookup[15] = o
# xCenterLookup[16] = p
# xCenterLookup[17] = q
# xCenterLookup[18] = r
# xCenterLookup[19] = s
# xCenterLookup[20] = t
# xCenterLookup[21] = u
# xCenterLookup[22] = v
# xCenterLookup[23] = w
# xCenterLookup[24] = x
# xCenterLookup[25] = y
# xCenterLookup[26] = z
# xCenterLookup[27] = A
# xCenterLookup[28] = B
# xCenterLookup[29] = C
# xCenterLookup[30] = D
# xCenterLookup[31] = E
# xCenterLookup[32] = F
# xCenterLookup[33] = G
# xCenterLookup[34] = H
# xCenterLookup[35] = I
# xCenterLookup[36] = J
# xCenterLookup[37] = K
# xCenterLookup[38] = L
# xCenterLookup[39] = M
# xCenterLookup[40] = N
# xCenterLookup[41] = O
# xCenterLookup[42] = P
# xCenterLookup[43] = Q
# xCenterLookup[44] = R
# xCenterLookup[45] = S
# xCenterLookup[46] = T
# xCenterLookup[47] = U
# xCenterLookup[48] = V
# yCenterLookup[0] = -20
# yCenterLookup[1] = -19
# yCenterLookup[2] = -18
# yCenterLookup[3] = -17
# yCenterLookup[4] = -16
# yCenterLookup[5] = -15
# yCenterLookup[6] = -14
# yCenterLookup[7] = -13
# yCenterLookup[8] = -12
# yCenterLookup[9] = -11
# yCenterLookup[10] = -10
# yCenterLookup[11] = -09
# yCenterLookup[12] = -08
# yCenterLookup[13] = -07
# yCenterLookup[14] = -06
# yCenterLookup[15] = -05
# yCenterLookup[16] = -04
# yCenterLookup[17] = -03
# yCenterLookup[18] = -02
# yCenterLookup[19] = -01
# yCenterLookup[20] = 00
# yCenterLookup[21] = 01
# yCenterLookup[22] = 02
# yCenterLookup[23] = 03
# yCenterLookup[24] = 04
# yCenterLookup[25] = 05
# yCenterLookup[26] = 06
# yCenterLookup[27] = 07
# yCenterLookup[28] = 08
# yCenterLookup[29] = 09
# yCenterLookup[30] = 10
# yCenterLookup[31] = 11
# yCenterLookup[32] = 12
# yCenterLookup[33] = 13
# yCenterLookup[34] = 14
# yCenterLookup[35] = 15
# yCenterLookup[36] = 16
# yCenterLookup[37] = 17
# yCenterLookup[38] = 18
# yCenterLookup[39] = 19
# yCenterLookup[40] = 20
# Test xCenter with value -2.25 passed: expected a, got a
# Test xCenter with value -2.1875 passed: expected b, got b
# Test xCenter with value -2.125 passed: expected c, got c
# Test xCenter with value -2.0625 passed: expected d, got d
# Test xCenter with value -2.0 passed: expected e, got e
# Test xCenter with value -1.9375 passed: expected f, got f
# Test xCenter with value -1.875 passed: expected g, got g
# Test xCenter with value -1.8125 passed: expected h, got h
# Test xCenter with value -1.75 passed: expected i, got i
# Test xCenter with value -1.6875 passed: expected j, got j
# Test xCenter with value -1.625 passed: expected k, got k
# Test xCenter with value -1.5625 passed: expected l, got l
# Test xCenter with value -1.5 passed: expected m, got m
# Test xCenter with value -1.4375 passed: expected n, got n
# Test xCenter with value -1.375 passed: expected o, got o
# Test xCenter with value -1.3125 passed: expected p, got p
# Test xCenter with value -1.25 passed: expected q, got q
# Test xCenter with value -1.1875 passed: expected r, got r
# Test xCenter with value -1.125 passed: expected s, got s
# Test xCenter with value -1.0625 passed: expected t, got t
# Test xCenter with value -1.0 passed: expected u, got u
# Test xCenter with value -0.9375 passed: expected v, got v
# Test xCenter with value -0.875 passed: expected w, got w
# Test xCenter with value -0.8125 passed: expected x, got x
# Test xCenter with value -0.75 passed: expected y, got y
# Test xCenter with value -0.6875 passed: expected z, got z
# Test xCenter with value -0.625 passed: expected A, got A
# Test xCenter with value -0.5625 passed: expected B, got B
# Test xCenter with value -0.5 passed: expected C, got C
# Test xCenter with value -0.4375 passed: expected D, got D
# Test xCenter with value -0.375 passed: expected E, got E
# Test xCenter with value -0.3125 passed: expected F, got F
# Test xCenter with value -0.25 passed: expected G, got G
# Test xCenter with value -0.1875 passed: expected H, got H
# Test xCenter with value -0.125 passed: expected I, got I
# Test xCenter with value -0.0625 passed: expected J, got J
# Test xCenter with value 0.0 passed: expected K, got K
# Test xCenter with value 0.0625 passed: expected L, got L
# Test xCenter with value 0.125 passed: expected M, got M
# Test xCenter with value 0.1875 passed: expected N, got N
# Test xCenter with value 0.25 passed: expected O, got O
# Test xCenter with value 0.3125 passed: expected P, got P
# Test xCenter with value 0.375 passed: expected Q, got Q
# Test xCenter with value 0.4375 passed: expected R, got R
# Test xCenter with value 0.5 passed: expected S, got S
# Test xCenter with value 0.5625 passed: expected T, got T
# Test xCenter with value 0.625 passed: expected U, got U
# Test xCenter with value 0.6875 passed: expected V, got V
# Test xCenter with value 0.75 passed: expected , got 
# ************************
# All xCenter tests passed.
# ************************
# Test yCenter with value -1.25 passed: expected -20, got -20
# Test yCenter with value -1.1875 passed: expected -19, got -19
# Test yCenter with value -1.125 passed: expected -18, got -18
# Test yCenter with value -1.0625 passed: expected -17, got -17
# Test yCenter with value -1 passed: expected -16, got -16
# Test yCenter with value -0.9375 passed: expected -15, got -15
# Test yCenter with value -0.875 passed: expected -14, got -14
# Test yCenter with value -0.8125 passed: expected -13, got -13
# Test yCenter with value -0.75 passed: expected -12, got -12
# Test yCenter with value -0.6875 passed: expected -11, got -11
# Test yCenter with value -0.625 passed: expected -10, got -10
# Test yCenter with value -0.5625 passed: expected -09, got -09
# Test yCenter with value -0.5 passed: expected -08, got -08
# Test yCenter with value -0.4375 passed: expected -07, got -07
# Test yCenter with value -0.375 passed: expected -06, got -06
# Test yCenter with value -0.3125 passed: expected -05, got -05
# Test yCenter with value -0.25 passed: expected -04, got -04
# Test yCenter with value -0.1875 passed: expected -03, got -03
# Test yCenter with value -0.125 passed: expected -02, got -02
# Test yCenter with value -0.0625 passed: expected -01, got -01
# Test yCenter with value 0 passed: expected 00, got 00
# Test yCenter with value 0.0625 passed: expected 01, got 01
# Test yCenter with value 0.125 passed: expected 02, got 02
# Test yCenter with value 0.1875 passed: expected 03, got 03
# Test yCenter with value 0.25 passed: expected 04, got 04
# Test yCenter with value 0.3125 passed: expected 05, got 05
# Test yCenter with value 0.375 passed: expected 06, got 06
# Test yCenter with value 0.4375 passed: expected 07, got 07
# Test yCenter with value 0.5 passed: expected 08, got 08
# Test yCenter with value 0.5625 passed: expected 09, got 09
# Test yCenter with value 0.625 passed: expected 10, got 10
# Test yCenter with value 0.6875 passed: expected 11, got 11
# Test yCenter with value 0.75 passed: expected 12, got 12
# Test yCenter with value 0.8125 passed: expected 13, got 13
# Test yCenter with value 0.875 passed: expected 14, got 14
# Test yCenter with value 0.9375 passed: expected 15, got 15
# Test yCenter with value 1 passed: expected 16, got 16
# Test yCenter with value 1.0625 passed: expected 17, got 17
# Test yCenter with value 1.125 passed: expected 18, got 18
# Test yCenter with value 1.1875 passed: expected 19, got 19
# Test yCenter with value 1.25 passed: expected 20, got 20
# ************************
# All yCenter tests passed.
# ************************
# (base) denisecase@Denises-MacBook-Air MandArt-Discoveries % 