#!/bin/bash
##################################################################
# @Name:         install.sh
# @Package:      sml-magic-tools
# @Description:  Installation & Activation helper (Standalone/DEB)
# @Author:       Sergio Melas <sergiomelas@gmail.com>
# @Version:      1.0.0
##################################################################

echo " "
echo " ##################################################################"
echo " #                                                                #"
echo " #                       sml magic tools                          #"
echo " #        Developed for bash by sergio melas 2021-26              #"
echo " #                                                                #"
echo " ##################################################################"
echo " "

# Detect Environment
# If the share directory exists, we assume a Debian package context
if [ -d "/usr/share/sml-magic-tools" ]; then
    IS_DEB=true
    TARGET_DIR="/usr/bin"
else
    IS_DEB=false
    TARGET_DIR="/usr/local/bin"
fi

if [ "$IS_DEB" = false ]; then
    echo "Status: Manual install detected. Copying from $(pwd)/Payload..."

    # Check for root privileges for manual installation
    [ "$EUID" -ne 0 ] && { echo "Error: Please run with sudo"; exit 1; }

    # Iterate through Payload, stripping .sh extensions for command usage
    for file in "$(pwd)/Payload/"*.sh; do
        [ -e "$file" ] || continue
        name=$(basename "$file" .sh)

        echo " -> Installing: ${name}"
        cp "$file" "${TARGET_DIR}/${name}"
        chmod 755 "${TARGET_DIR}/${name}"
        chown root:root "${TARGET_DIR}/${name}"
    done
else
    echo "Status: Debian package environment detected. Finalizing..."
fi

echo -e "\nSML Magic Tools activated."
