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

# Log message function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Export this function
get_xCenter_bucket() {
    local xCenter="$1"
    local letters=('a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V')
    local step=0.0625
    local min=-2.25
    local max=0.75

    if (( $(echo "$xCenter < $min" | bc -l) )); then
        return 1
    elif (( $(echo "$xCenter >= $max" | bc -l) )); then
        return 1
    fi

    # Handle values within min to min + step as "a"
    if (( $(echo "$xCenter >= $min && $xCenter < $min + $step" | bc -l) )); then
        return
    fi

    # Calculate the index for other values
    local index=$(echo "($xCenter - $min) / $step" | bc -l | awk '{printf "%d", $1}')
    
    if ((index < 0 || index >= ${#letters[@]})); then
        return 1
    fi

    local bucket=${letters[index]}
    echo "$bucket"
}


main() {
    log_message "Running main() function"

    # Test values including edge cases
    local test_values=(-2.26 -2.25 -2.24999 -1.0 0.0 0.749 0.75)
    for value in "${test_values[@]}"; do
        log_message "Testing value: $value"
        bucket=$(get_xCenter_bucket "$value")
        if [ -n "$bucket" ]; then
            log_message "Value $value maps to bucket $bucket"
            echo "Value: $value -> Bucket: $bucket"
        else
            log_message "Error: Value $value does not map to a valid bucket"
            echo "Error: Value $value does not map to a valid bucket"
        fi
    done

    log_message "Completed main() function"
}

#main
