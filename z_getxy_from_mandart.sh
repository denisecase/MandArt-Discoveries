#!/bin/zsh

# chmoe +x z_getxy_from_mandart.sh
# ./z_getxy_from_mandart.sh

LOG_FILE="zlog_getxy_from_mandart.log"
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Export this function
getx_from_mandart() {
    local mandart_file="$1"
    local xCenter=$(jq -r '.xCenter' "$mandart_file")
    echo "$xCenter"
} 

# Export this function
gety_from_mandart() {
    local mandart_file="$1"
    local yCenter=$(jq -r '.yCenter' "$mandart_file")
    echo "$yCenter"
} 

main() {
    log_message "Starting main() function"
    echo "Starting main() function"

    local mandart_file="to-be-sorted/AAB1.mandart"
    log_message "Processing mandart file: $mandart_file"
    echo "Processing mandart file: $mandart_file"

    local xCenter=$(getx_from_mandart "$mandart_file")
    local yCenter=$(gety_from_mandart "$mandart_file")

    log_message "Read xCenter: $xCenter"
    echo "Read xCenter: $xCenter"
    log_message "Read yCenter: $yCenter"
    echo "Read yCenter: $yCenter"

    log_message "Completed main() function"
    echo "Completed main() function"
}

#main
