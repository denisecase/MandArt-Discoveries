#!/bin/zsh

# chmod +x z_lookupx.sh
# ./z_lookupx.sh

# xCenter 
# x values range from -2.25 to 0.75 in steps of 0.25/4.0
# x values map to letters a-z and A-V
# x = -2.25 -> a
# x = -2.24444 -> a
# x = 0.0001  -> K

LOG_FILE="zlog_lookupx.log"
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

get_xCenter_primary_bucket() {
    local xCenter="$1"
    local primary_bucket_bounds=(-2.25 -2.0 -1.75 -1.5 -1.25 -1.0 -0.75 -0.5 -0.25 0.0 0.25 0.5 0.75)
    local primary_bucket_letters=('A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L')  
    local primary_bucket=""
    for ((i=0; i<${#primary_bucket_bounds[@]}; i++)); do
        # Check if xCenter falls within the current bounds
        if (( $(echo "$xCenter >= ${primary_bucket_bounds[$i]}" | bc -l) )) && \
           (( $(echo "$xCenter < ${primary_bucket_bounds[$i+1]}" | bc -l) )); then
            # Assign the corresponding letter to the primary_bucket variable
            primary_bucket=${primary_bucket_letters[$i]}
            break
        fi
    done

    # Check if a valid primary bucket was found
    if [ -z "$primary_bucket" ]; then
        echo "Error: Unable to determine the primary bucket for xCenter $xCenter."
        return 1
    else
        echo "$primary_bucket"
    fi
}

get_xCenter_bucket() {
    local xCenter="$1"
    local primary_bucket=$(get_xCenter_primary_bucket "$xCenter")
    if [ -z "$primary_bucket" ]; then
        return 1
    fi

    local secondary_bucket=""
    local secondary_bucket_letters=('a' 'b' 'c' 'd')
    local primary_bucket_bounds=(-2.25 -2.0 -1.75 -1.5 -1.25 -1.0 -0.75 -0.5 -0.25 0.0 0.25 0.5 0.75)
    local primary_bucket_letters=('A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L')  
  
    # Calculate the secondary bucket based on the position within the primary bucket
    local primary_index=$(( $(printf "%d" \'$primary_bucket) - $(printf "%d" 'A') ))
    local primary_lower_bound=${primary_bucket_bounds[$primary_index]}
    local primary_upper_bound=${primary_bucket_bounds[$((primary_index + 1))]}
    local primary_width=$(echo "($primary_upper_bound - $primary_lower_bound)" | bc -l)
    local primary_quarter_width=$(echo "$primary_width / 4" | bc -l)
    local secondary_calculation=$(echo "($xCenter - $primary_lower_bound) / $primary_quarter_width" | bc -l)
    # Convert to 0-based index for array access
    local secondary_index=$(echo "$secondary_calculation / 1" | bc)

    # Adjust for 1-based array indexing in Zsh and clamp the secondary_index to be within 1-4
    secondary_index=$((secondary_index + 1))
    if (( secondary_index < 1 )); then
        secondary_index=1
    elif (( secondary_index > 4 )); then
        secondary_index=4
    fi

    # Map the index to the secondary bucket
    secondary_bucket=${secondary_bucket_letters[secondary_index]}

    local bucket="$primary_bucket$secondary_bucket"
    echo "$bucket"
}


main() {
    log_message "Running main() function"

    # Test values including edge cases
    local test_values=(-2.26 -2.25 -2.24999 -1.0 0.0 0.749 0.75 -2.25 -2.00 -1.75 -1.50 -1.25 -1.00 -0.75 -0.50 -0.25 0.00 0.25 0.50 0.75 )
    for value in "${test_values[@]}"; do
        log_message "Testing value: $value"
        bucket=$(get_xCenter_bucket "$value")
        if [ -n "$bucket" ]; then
            log_message "Value $value maps to bucket $bucket"
            echo "Value: $value maps to bucket: $bucket"
        else
            log_message "Error: Value $value does not map to a valid bucket"
            echo "Error: Value $value does not map to a valid bucket"
        fi
    done

    log_message "Completed main() function"
}

#main
