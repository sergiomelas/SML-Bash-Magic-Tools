#!/bin/bash
##################################################################
# @Name:         remove.sh
# @Package:      sml-magic-tools
# @Description:  System Cleanup Utility (Standalone/DEB)
# @Author:       Sergio Melas <sergiomelas@gmail.com>
# @Version:      1.0.0
##################################################################

echo " "
echo " ##################################################################"
echo " #                                                                #"
echo " #                       sml magic tools                          #"
echo " #             --- UNINSTALLATION UTILITY ---                     #"
echo " #                                                                #"
echo " ##################################################################"
echo " "

# List of all 11 core utilities
TOOLS=(codecksml crashsml dbgsml journalsml killsml logssml orphansml peeksml pidsml searchjsml searchlsml throttlesml tracesml)

# Root check for manual execution
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root (use sudo ./remove.sh)"
    exit 1
fi

echo "Scanning system paths for SML binaries..."

for tool in "${TOOLS[@]}"; do
    # Check both standard binary directories
    for dir in "/usr/bin" "/usr/local/bin"; do
        target="${dir}/${tool}"
        if [ -f "$target" ]; then
            echo " -> Removing: $target"
            rm -f "$target"
        fi
    done
done

# Remove Desktop Launcher Shortcut
if [ -f "/usr/share/applications/System_Crash.desktop" ]; then
    echo " -> Removing Launcher: /usr/share/applications/System_Crash.desktop"
    rm -f "/usr/share/applications/System_Crash.desktop"
fi

# Remove Vector Icon Asset
if [ -f "/usr/share/icons/hicolor/scalable/apps/bombermaaan.svg" ]; then
    echo " -> Removing Desktop Icon: /usr/share/icons/hicolor/scalable/apps/bombermaaan.svg"
    rm -f "/usr/share/icons/hicolor/scalable/apps/bombermaaan.svg"

    # Update system icon theme cache registry
    if command -v gtk-update-icon-cache &> /dev/null; then
        echo " -> Updating system icon cache registry..."
        gtk-update-icon-cache -f -t /usr/share/icons/hicolor &>/dev/null || true
    fi
fi

# Cleanup the shared directory used by the Debian package
if [ -d "/usr/share/sml-magic-tools" ]; then
    echo " -> Removing shared data: /usr/share/sml-magic-tools"
    rm -rf "/usr/share/sml-magic-tools"
fi

echo -e "\nSML Magic Tools have been successfully removed."
