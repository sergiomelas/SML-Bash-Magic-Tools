#!/bin/bash
# SML Magic Tools - Clean Debian Builder
# Developed by Sergio Melas - 2026
set -e

# Identity Configuration
export DEBFULLNAME="Sergio Melas"
export DEBEMAIL="sergiomelas@gmail.com"
MAINTAINER="${DEBFULLNAME} <${DEBEMAIL}>"

echo " "
echo " ##################################################################"
echo " #                                                                #"
echo " #                       sml magic tools                          #"
echo " #          Master Builder V1.0 - Debian Integration              #"
echo " #                                                                #"
echo " ##################################################################"
echo " "


PKG_NAME="sml-magic-tools"
VERSION="1.0.2"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${BASE_DIR}/sml_build_tmp"

# 1. Setup Structure
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}/DEBIAN"
mkdir -p "${BUILD_DIR}/usr/bin"
mkdir -p "${BUILD_DIR}/usr/share/${PKG_NAME}"
mkdir -p "${BUILD_DIR}/usr/share/applications"
mkdir -p "${BUILD_DIR}/usr/share/icons/hicolor/scalable/apps"

# 2. Control File
cat <<EOF > "${BUILD_DIR}/DEBIAN/control"
Package: ${PKG_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: all
Maintainer: ${MAINTAINER}
Depends: strace, perl, procps, util-linux, systemd, diffutils, shellcheck, gzip, findutils, coreutils, gawk, libgtk-3-bin, zenity
Description: SML Magic Tools - Professional Bash Diagnostic Suite.
 Pure logic version - No banners.
EOF

# 3. Maintenance Wrappers
echo "#!/bin/bash
bash \"/usr/share/${PKG_NAME}/install.sh\"
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor &>/dev/null || true
fi
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database /usr/share/applications/ &>/dev/null || true
fi
exit 0" > "${BUILD_DIR}/DEBIAN/postinst"

echo "#!/bin/bash
bash \"/usr/share/${PKG_NAME}/remove.sh\"
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor &>/dev/null || true
fi
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database /usr/share/applications/ &>/dev/null || true
fi
exit 0" > "${BUILD_DIR}/DEBIAN/prerm"

# FORCE THE PERMISSIONS FOR DEBIAN PACKAGING DIRECTLY HERE:
chmod 755 "${BUILD_DIR}/DEBIAN/postinst" "${BUILD_DIR}/DEBIAN/prerm"

# 4. Direct Script Copy (No Injection)
echo "Packaging scripts from Payload/..."
for file in "${BASE_DIR}/Payload/"*.sh; do
    [ -e "$file" ] || continue
    filename=$(basename "$file")
    # This removes the .sh extension for the command name
    cmd_name="${filename%.sh}"
    dest="${BUILD_DIR}/usr/bin/${cmd_name}"

    # Simply copy the file and set permissions
    cp "$file" "$dest"
    chmod 755 "$dest"
    echo " -> Integrated: ${cmd_name}"
done

# 5. Package Helpers
cp "${BASE_DIR}/install.sh" "${BUILD_DIR}/usr/share/${PKG_NAME}/install.sh"
cp "${BASE_DIR}/remove.sh" "${BUILD_DIR}/usr/share/${PKG_NAME}/remove.sh"
chmod 755 "${BUILD_DIR}/usr/share/${PKG_NAME}/"*.sh

cp "${BASE_DIR}/Payload/System_Crash.desktop" "${BUILD_DIR}/usr/share/applications/System_Crash.desktop"
chmod 644 "${BUILD_DIR}/usr/share/applications/System_Crash.desktop"


cp "${BASE_DIR}/Payload/bombermaaan.svg" "${BUILD_DIR}/usr/share/icons/hicolor/scalable/apps/bombermaaan.svg"
chmod 644 "${BUILD_DIR}/usr/share/icons/hicolor/scalable/apps/bombermaaan.svg"



# 6. Build .deb
dpkg-deb --build "${BUILD_DIR}" "${BASE_DIR}/${PKG_NAME}_${VERSION}_all.deb"
rm -rf "${BUILD_DIR}"

echo "------------------------------------------------------"
echo "           SUCCESS: Clean build finished."
echo "------------------------------------------------------"
