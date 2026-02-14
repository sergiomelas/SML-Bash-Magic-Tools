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
TOOLS=(codecksml dbgsml journalsml killsml logssml orphansml peeksml pidsml searchjsml searchlsml tracesml)

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

# Cleanup the shared directory used by the Debian package
if [ -d "/usr/share/sml-magic-tools" ]; then
    echo " -> Removing shared data: /usr/share/sml-magic-tools"
    rm -rf "/usr/share/sml-magic-tools"
fi

echo -e "\nSML Magic Tools have been successfully removed."
