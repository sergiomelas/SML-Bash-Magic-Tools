#!/bin/bash

echo  " "
echo  " ##################################################################"
echo  " #                       sml magic tools                          #"
echo  " #       Developed for for bash by sergio melas 2021-26           #"
echo  " #                                                                #"
echo  " #                Emai: sergiomelas@gmail.com                     #"
echo  " #                   Released unde GPV V2.0                       #"
echo  " #                                                                #"
echo  " ##################################################################"
echo  " "

# Get the directory where the script is stored
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change into that directory
cd "$SCRIPT_DIR"

# 1. Login
echo  "Login as administrator to install"
sudo ls >/dev/null
echo  ""

# 2. Install Dependencies
echo "Installing core dependencies..."
sudo apt-get update
#peeksml pidsml
sudo apt-get install -y strace perl procps
#killsml
sudo apt-get install -y util-linux
#trace sml
sudo apt-get install -y systemd diffutils




# 3. Install all .sh files from Payload
echo "Installing scripts from ./Payload..."

# Check if directory exists and has .sh files
if [ ! -d "./Payload" ] || [ -z "$(ls -A ./Payload/*.sh 2>/dev/null)" ]; then
    echo "Error: No .sh files found in ./Payload directory."
    exit 1
fi

for file in ./Payload/*.sh; do
    # Extract the filename from the path (e.g., peek.sh)
    filename=$(basename "$file")

    # Create the command name by removing the .sh extension (e.g., peek)
    command_name="${filename%.sh}"
    dest_path="/usr/local/bin/$command_name"

    # --- CHECK FOR EXISTING COMMAND ---
    if [ -f "$dest_path" ]; then
        echo "⚠️  SKIPPING: '$command_name' already exists in /usr/local/bin/"
    else
        echo "Installing: $filename -> $dest_path"

        # Global install steps
        sudo cp "$file" "$dest_path"
        sudo chmod 755 "$dest_path"
        sudo chown root:root "$dest_path"
    fi
done

echo ""
echo "Installation process complete!"
echo "New tools can now be run directly from any terminal."
