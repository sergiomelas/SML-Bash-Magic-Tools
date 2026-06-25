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

# Install Desktop Launcher Shortcut
DESKTOP_SRC="$(pwd)/Payload/System_Crash.desktop"
if [ -f "$DESKTOP_SRC" ]; then
    echo " -> Installing Launcher: System_Crash.desktop"
    cp "$DESKTOP_SRC" "/usr/share/applications/System_Crash.desktop"
    chmod 644 "/usr/share/applications/System_Crash.desktop"
    chown root:root "/usr/share/applications/System_Crash.desktop"
fi

# Install Vector Icon Asset
ICON_SRC="$(pwd)/Payload/bombermaaan.svg"
if [ -f "$ICON_SRC" ]; then
    echo " -> Installing Desktop Icon: bombermaaan.svg"
    mkdir -p "/usr/share/icons/hicolor/scalable/apps"
    cp "$ICON_SRC" "/usr/share/icons/hicolor/scalable/apps/bombermaaan.svg"
    chmod 644 "/usr/share/icons/hicolor/scalable/apps/bombermaaan.svg"
    chown root:root "/usr/share/icons/hicolor/scalable/apps/bombermaaan.svg"

    # Update the system icon theme cache registry
    if command -v gtk-update-icon-cache &> /dev/null; then
        echo " -> Updating system icon cache registry..."
        gtk-update-icon-cache -f -t /usr/share/icons/hicolor &>/dev/null || true
    fi
fi

echo -e "\nSML Magic Tools activated."
