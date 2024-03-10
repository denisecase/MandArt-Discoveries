#!/bin/zsh

LOG_FILE="zlog_lookupx.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# delete log file if it exists
if [ -f "$LOG_FILE" ]; then
    rm "$LOG_FILE"
fi

test_values=(-2.26 -2.25 -2.24999 -1.0 0.0 0.749 0.75 -2.25 -2.00 -1.75 -1.50 -1.25 -1.00 -0.75 -0.50 -0.25 0.00 0.25 0.50 0.75 -2.25 -2.0 0.0 0.05 0.10 0.15 0.20 0.249999)
primary_bucket_bounds=(-2.25 -2.0 -1.75 -1.5 -1.25 -1.0 -0.75 -0.5 -0.25 0.0 0.25 0.5 0.75)
primary_bucket_letters=('A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L')  
secondary_bucket_letters=('a' 'b' 'c' 'd')
secondary_bucket_bounds=(0.0  0.0625 0.125 0.1875)
test_secondary=(-2.25 -2.0 0.0 0.05 0.10 0.15 0.20 0.249999)
test_secondary_answers=('a' 'a' 'a' 'a' 'b' 'c' 'd' 'd')

get_xCenter_primary_bucket() {
    local xCenter="$1"
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

determine_secondary_bucket() {
    local xCenter="$1"
    local primary_lower_bound="$2"

    for ((i=0; i<${#primary_bucket_bounds[@]}; i++)); do
        # Check if xCenter falls within the current bounds
        if (( $(echo "$xCenter >= ${primary_bucket_bounds[$i]}" | bc -l) )) && \
           (( $(echo "$xCenter < ${primary_bucket_bounds[$i+1]}" | bc -l) )); then
            # Assign the corresponding letter to the primary_bucket variable
            primary_lower_bound=${primary_bucket_bounds[$i]}
            break
        fi
    done

    # Calculate the offset from the primary bucket's lower bound
    local offset=$(echo "$xCenter - $primary_lower_bound" | bc -l)

    # Determine the secondary bucket based on the offset
    local secondary_bucket=""

    if [ "$(echo "$offset >= 0 && $offset < 0.0625" | bc)" -eq 1 ]; then
        echo "a"
    elif [ "$(echo "$offset >= 0.0625 && $offset < 0.1250" | bc)" -eq 1 ]; then
        echo "b"
    elif [ "$(echo "$offset >= 0.1250 && $offset < 0.1875" | bc)" -eq 1 ]; then
        echo "c"
    elif [ "$(echo "$offset >= 0.1875 && $offset <= 0.25" | bc)" -eq 1 ]; then
        echo "d"
    else
        # This condition theoretically should never be met if the input is within expected bounds
        echo "Error: Offset calculation error"
    fi
}



get_xCenter_bucket() {
    local xCenter="$1"
    local primary_bucket=$(get_xCenter_primary_bucket "$xCenter")

    if [ -z "$primary_bucket" ]; then
        echo "Error: Primary bucket not found for $xCenter"
        return 1
    fi

    local primary_index=$((i))
    local primary_lower_bound=${primary_bucket_bounds[$primary_index]}
    local secondary_bucket=$(determine_secondary_bucket "$xCenter" "$primary_lower_bound")
    echo "$primary_bucket$secondary_bucket"
}


main() {
    log_message "Running main() function"
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

# Execute the main function
main
