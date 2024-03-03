#!/bin/zsh

# chmod +x z_lookupy.sh
# ./z_lookupy.sh

# yCenter
# y values range from -1.25 to 1.25 in steps of 0.25/4.0
# y values map to two-digit codes from 01 to 20 (and from -20 to -01)
# e.g. y = 0.000001 -> 00
# e.g. y = 0.7501 -> 13
# e.g. y = -0.7501 -> -13

LOG_FILE="zlog_lookupy.log"

# Log message function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Export this function
get_yCenter_bucket() {
    local yCenter="$1"
    local numbers=(-20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -09 -08 -07 -06 -05 -04 -03 -02 -01 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20)
    local step=0.0625
    local min=-1.25
    local max=1.25
    local index
    local bucket

    if (( $(echo "$yCenter < $min" | bc -l) )); then
        log_message "Error: yCenter value $yCenter is below the minimum allowed value of $min."
        echo "Error: $yCenter is below the minimum allowed value of $min."
        return 1
    elif (( $(echo "$yCenter > $max" | bc -l) )); then
        log_message "Error: yCenter value $yCenter exceeds the maximum allowed value of $max."
        echo "Error: $yCenter exceeds the maximum allowed value of $max."
        return 1
    fi

    # Calculate index for positive and negative yCenter values
    if (( $(echo "$yCenter < 0" | bc -l) )); then
        index=$(echo "($yCenter - $min) / $step" | bc -l | awk '{printf "%d", $1}')
        bucket=$((index + 1)) # Adjust index for array access
        bucket=$((20 - bucket + 1)) # Map to negative range
        bucket=$(printf "%02d" $bucket) # Ensure two-digit format, possibly with leading zero
        bucket="-$bucket"
    else
        index=$(echo "($yCenter / $step)" | bc -l | awk '{printf "%d", $1}')
        bucket=$((index + 1)) # Adjust index for array access
        bucket=$(printf "%02d" $bucket) # Ensure two-digit format
    fi

    # The return value is the bucket, but only if it's 2 or 3 characters long
    if [[ ${#bucket} -eq 2 || ${#bucket} -eq 3 ]]; then
        echo "$bucket"
    else
        log_message "Error: Calculated bucket $bucket for yCenter $yCenter is not 2 or 3 characters long."
        echo "Error: Calculated bucket $bucket for yCenter $yCenter is not 2 or 3 characters long."
        return 1
    fi
}


# Main method for testing
main() {
    # Test values including edge cases
    local test_values=(-1.26 -1.25 -1.0 0.0 0.0624 0.0625 1.24 1.25)

    echo "Number buckets for yCenter values:"
    for value in "${test_values[@]}"; do
        bucket=$(get_yCenter_bucket "$value")
        if [[ $? -eq 0 ]]; then
            echo "yCenter: $value -> Bucket: $bucket"
        else
            echo "Error calculating bucket for yCenter: $value"
        fi
    done
}

#main
