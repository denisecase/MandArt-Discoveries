#!/bin/zsh
#
# To run the script, place it in root project directory, open a terminal and run:
#
# chmod +x scriptinstalls.sh
#
# ./scriptinstalls.sh


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

# Check if exiftool is installed, install if not, or upgrade it
if brew list exiftool &>/dev/null; then
    #echo "bc is already installed. Upgrading..."
    brew upgrade exiftool
else
    echo "Installing exiftool..."
    brew install exiftool
fi