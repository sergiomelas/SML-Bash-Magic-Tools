#!/bin/bash

echo  " "
echo  " ##################################################################"
echo  " #                                                                #"
echo  " #                       sml magic tools                          #"
echo  " #                --- UNINSTALLATION UTILITY ---                  #"
echo  " #       Developed for for bash by sergio melas 2021-26           #"
echo  " #                                                                #"
echo  " ##################################################################"
echo  " "

# Get the directory where the script is stored
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 1. Login
echo "Login as administrator to uninstall"
sudo ls >/dev/null
echo ""

# 2. Identify and Remove tools
if [ ! -d "./Payload" ]; then
    echo "Error: ./Payload directory not found. Cannot determine which files to remove."
    exit 1
fi

echo "Removing scripts from /usr/local/bin..."

for file in ./Payload/*.sh; do
    # Get filename (e.g., peek.sh)
    filename=$(basename "$file")

    # Get the command name used during install (e.g., peek)
    command_name="${filename%.sh}"
    dest_path="/usr/local/bin/$command_name"

    # Check if the file exists before trying to delete
    if [ -f "$dest_path" ]; then
        echo "Removing: $dest_path"
        sudo rm "$dest_path"
    else
        echo "ℹ️  Notice: '$command_name' was not found in /usr/local/bin. Skipping."
    fi
done

echo ""
echo "Uninstallation complete!"
echo "All SML magic tools have been removed."
