#!/bin/bash
# SML Magic Tools - Clean Debian Builder
# Developed by Sergio Melas - 2026
set -e

echo " "
echo " ##################################################################"
echo " #                                                                #"
echo " #                       sml magic tools                          #"
echo " #          Master Builder V1.0 - Debian Integration              #"
echo " #                                                                #"
echo " ##################################################################"
echo " "


PKG_NAME="sml-magic-tools"
VERSION="1.0.0"
MAINTAINER="Sergio Melas <sergiomelas@gmail.com>"
BASE_DIR="$(pwd)"
BUILD_DIR="${BASE_DIR}/sml_build_tmp"

# 1. Setup Structure
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}/DEBIAN"
mkdir -p "${BUILD_DIR}/usr/bin"
mkdir -p "${BUILD_DIR}/usr/share/${PKG_NAME}"

# 2. Control File
cat <<EOF > "${BUILD_DIR}/DEBIAN/control"
Package: ${PKG_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: all
Maintainer: ${MAINTAINER}
Depends: strace, perl, procps, util-linux, systemd, diffutils, shellcheck, gzip, findutils, coreutils, gawk
Description: SML Magic Tools - Professional Bash Diagnostic Suite.
 Pure logic version - No banners.
EOF

# 3. Maintenance Wrappers
echo "#!/bin/bash
bash \"/usr/share/${PKG_NAME}/install.sh\"
exit 0" > "${BUILD_DIR}/DEBIAN/postinst"

echo "#!/bin/bash
bash \"/usr/share/${PKG_NAME}/remove.sh\"
exit 0" > "${BUILD_DIR}/DEBIAN/prerm"
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

# 6. Build .deb
dpkg-deb --build "${BUILD_DIR}" "${BASE_DIR}/${PKG_NAME}_${VERSION}_all.deb"
rm -rf "${BUILD_DIR}"

echo "------------------------------------------------------"
echo "           SUCCESS: Clean build finished."
echo "------------------------------------------------------"
