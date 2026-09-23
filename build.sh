#!/bin/bash
set -e

if [ -f .env ]; then
    set -a
    source .env
    set +a
else
    exit 1
fi

APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
DMG_STAGING="${BUILD_DIR}/dmg_staging"

rm -rf "${BUILD_DIR}" "${DIST_DIR}/${DMG_NAME}" "${DIST_DIR}/${APP_NAME}.app"

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

    iconutil -c icns "${ICONSET_DIR}" -o "${APP_DIR}/Contents/Resources/${ICON_ICNS_NAME}.icns"
fi

$CXX $CXXFLAGS $FRAMEWORKS "$SRC_FILE" -o "${APP_DIR}/Contents/MacOS/${EXECUTABLE_NAME}"

cat <<EOF > "${APP_DIR}/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.plist">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${EXECUTABLE_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${APP_BUNDLE_ID}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${APP_VERSION}</string>
    <key>CFBundleIconFile</key>
    <string>${ICON_ICNS_NAME}</string>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
EOF

mkdir -p "${DMG_STAGING}"
cp -R "${APP_DIR}" "${DMG_STAGING}/"
ln -s /Applications "${DMG_STAGING}/Applications"

hdiutil create -volname "${APP_NAME}" \
               -srcfolder "${DMG_STAGING}" \
               -ov -format UDZO "${DMG_NAME}"

mkdir -p "${DIST_DIR}"
mv "${APP_DIR}" "${DIST_DIR}/"
mv "${DMG_NAME}" "${DIST_DIR}/"
rm -rf "${BUILD_DIR}"