#!/bin/bash
set -e

APP_NAME="ClipHistory"
BUILD_DIR="build"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
DMG_NAME="${APP_NAME}.dmg"
ICON_PNG="icon.png"

rm -rf "${BUILD_DIR}" "${DMG_NAME}"

mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

if [ -f "$ICON_PNG" ]; then
    ICONSET_DIR="${BUILD_DIR}/icon.iconset"
    mkdir -p "${ICONSET_DIR}"

    sips -z 16 16     "$ICON_PNG" --out "${ICONSET_DIR}/icon_16x16.png"
    sips -z 32 32     "$ICON_PNG" --out "${ICONSET_DIR}/icon_16x16@2x.png"
    sips -z 32 32     "$ICON_PNG" --out "${ICONSET_DIR}/icon_32x32.png"
    sips -z 64 64     "$ICON_PNG" --out "${ICONSET_DIR}/icon_32x32@2x.png"
    sips -z 128 128   "$ICON_PNG" --out "${ICONSET_DIR}/icon_128x128.png"
    sips -z 256 256   "$ICON_PNG" --out "${ICONSET_DIR}/icon_128x128@2x.png"
    sips -z 256 256   "$ICON_PNG" --out "${ICONSET_DIR}/icon_256x256.png"
    sips -z 512 512   "$ICON_PNG" --out "${ICONSET_DIR}/icon_256x256@2x.png"
    sips -z 512 512   "$ICON_PNG" --out "${ICONSET_DIR}/icon_512x512.png"
    sips -z 1024 1024 "$ICON_PNG" --out "${ICONSET_DIR}/icon_512x512@2x.png"

    iconutil -c icns "${ICONSET_DIR}" -o "${APP_DIR}/Contents/Resources/AppIcon.icns"
fi

clang++ -O2 -std=c++17 \
    -framework Cocoa \
    -framework Foundation \
    main.mm -o "${APP_DIR}/Contents/MacOS/${APP_NAME}"

cat <<EOF > "${APP_DIR}/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>online.neko-hey.${APP_NAME}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.1</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
EOF

DMG_STAGING="build/dmg_staging"
mkdir -p "${DMG_STAGING}"
cp -R "${APP_DIR}" "${DMG_STAGING}/"
ln -s /Applications "${DMG_STAGING}/Applications"

hdiutil create -volname "${APP_NAME}" \
               -srcfolder "${DMG_STAGING}" \
               -ov -format UDZO "${DMG_NAME}"

rm -rf "${BUILD_DIR}"