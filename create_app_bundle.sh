#!/bin/bash
set -e

# Script to create Dino.app bundle from build directory
# Usage: ./create_app_bundle.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DINO_SOURCE="${HOME}/dino"
DINO_BUILD="${DINO_SOURCE}/build"
APP_NAME="Dino.app"
OUTPUT_DIR="${SCRIPT_DIR}"

if [ ! -d "${DINO_BUILD}" ]; then
    echo "Error: Build directory not found at ${DINO_BUILD}"
    echo "Please build Dino first with: cd ~/dino && meson compile -C build"
    exit 1
fi

if [ ! -f "${DINO_BUILD}/main/dino" ]; then
    echo "Error: dino binary not found in build directory"
    exit 1
fi

echo "Creating Dino.app bundle..."

# Remove old bundle if exists
rm -rf "${OUTPUT_DIR}/${APP_NAME}"

# Create bundle structure
mkdir -p "${OUTPUT_DIR}/${APP_NAME}/Contents/MacOS"
mkdir -p "${OUTPUT_DIR}/${APP_NAME}/Contents/Resources"
mkdir -p "${OUTPUT_DIR}/${APP_NAME}/Contents/Frameworks"
mkdir -p "${OUTPUT_DIR}/${APP_NAME}/Contents/lib/dino/plugins"
mkdir -p "${OUTPUT_DIR}/${APP_NAME}/Contents/share"

echo "Copying main binary..."
cp "${DINO_BUILD}/main/dino" "${OUTPUT_DIR}/${APP_NAME}/Contents/MacOS/dino-bin"
chmod +x "${OUTPUT_DIR}/${APP_NAME}/Contents/MacOS/dino-bin"

echo "Copying libraries..."
cp "${DINO_BUILD}/libdino/libdino.0.dylib" "${OUTPUT_DIR}/${APP_NAME}/Contents/Frameworks/"
cp "${DINO_BUILD}/xmpp-vala/libxmpp-vala.0.dylib" "${OUTPUT_DIR}/${APP_NAME}/Contents/Frameworks/"
cp "${DINO_BUILD}/qlite/libqlite.0.dylib" "${OUTPUT_DIR}/${APP_NAME}/Contents/Frameworks/"

echo "Copying plugins..."
for plugin in http-files ice omemo openpgp rtp; do
    if [ -f "${DINO_BUILD}/plugins/${plugin}/${plugin}.dylib" ]; then
        cp "${DINO_BUILD}/plugins/${plugin}/${plugin}.dylib" \
           "${OUTPUT_DIR}/${APP_NAME}/Contents/lib/dino/plugins/"
        echo "  - ${plugin}.dylib"
    fi
done

# Copy notification-sound plugin if it exists
if [ -f "${DINO_BUILD}/plugins/notification-sound/notification-sound.dylib" ]; then
    cp "${DINO_BUILD}/plugins/notification-sound/notification-sound.dylib" \
       "${OUTPUT_DIR}/${APP_NAME}/Contents/lib/dino/plugins/"
    echo "  - notification-sound.dylib"
fi

echo "Copying resources..."
# Copy icons
if [ -d "${DINO_SOURCE}/main/data/icons" ]; then
    cp -r "${DINO_SOURCE}/main/data/icons" "${OUTPUT_DIR}/${APP_NAME}/Contents/Resources/"
fi

# Copy locale files if they exist
if [ -d "${DINO_BUILD}/main/po" ]; then
    mkdir -p "${OUTPUT_DIR}/${APP_NAME}/Contents/share/locale"
    for po_dir in "${DINO_BUILD}/main/po"/*; do
        if [ -d "$po_dir" ]; then
            lang=$(basename "$po_dir")
            if [ -f "$po_dir/LC_MESSAGES/dino.mo" ]; then
                mkdir -p "${OUTPUT_DIR}/${APP_NAME}/Contents/share/locale/${lang}/LC_MESSAGES"
                cp "$po_dir/LC_MESSAGES/dino.mo" \
                   "${OUTPUT_DIR}/${APP_NAME}/Contents/share/locale/${lang}/LC_MESSAGES/"
                echo "  - locale: ${lang}"
            fi
        fi
    done
fi

# Create app icon (use a simple placeholder if no icon exists)
echo "Creating app icon..."
if [ ! -f "${OUTPUT_DIR}/${APP_NAME}/Contents/Resources/AppIcon.icns" ]; then
    # Try to find the icon in the source
    if [ -f "${DINO_SOURCE}/main/data/icons/scalable/apps/im.dino.Dino.svg" ]; then
        # For now, just note that icon conversion would be needed
        echo "  Note: SVG icon found, but ICNS conversion requires additional tools"
        echo "  You can convert manually with: iconutil or third-party tools"
    fi
fi

echo "Creating launcher script..."
cat > "${OUTPUT_DIR}/${APP_NAME}/Contents/MacOS/dino" << 'LAUNCHER_EOF'
#!/bin/bash
DIR="$(cd "$(dirname "$0")/.." && pwd)"
export DYLD_LIBRARY_PATH="$DIR/Frameworks:/usr/local/lib:$DYLD_LIBRARY_PATH"
export XDG_DATA_DIRS="$DIR/Resources:/usr/local/share:$XDG_DATA_DIRS"
export DINO_PLUGIN_DIR="$DIR/lib/dino/plugins"
export GST_PLUGIN_PATH="/usr/local/lib/gstreamer-1.0:$GST_PLUGIN_PATH"
exec "$DIR/MacOS/dino-bin" "$@"
LAUNCHER_EOF
chmod +x "${OUTPUT_DIR}/${APP_NAME}/Contents/MacOS/dino"

echo "Creating Info.plist..."
cat > "${OUTPUT_DIR}/${APP_NAME}/Contents/Info.plist" << 'PLIST_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>dino</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
	<key>CFBundleIdentifier</key>
	<string>im.dino.Dino</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>Dino</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>0.4.4</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>14.0</string>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>NSHumanReadableCopyright</key>
	<string>Copyright © 2016-2025 Dino contributors</string>
</dict>
</plist>
PLIST_EOF

echo "Updating library paths..."
# Fix library references using install_name_tool
FRAMEWORKS_DIR="${OUTPUT_DIR}/${APP_NAME}/Contents/Frameworks"

# Update dino-bin
install_name_tool -change "libdino.0.dylib" "@executable_path/../Frameworks/libdino.0.dylib" \
    "${OUTPUT_DIR}/${APP_NAME}/Contents/MacOS/dino-bin" 2>/dev/null || true
install_name_tool -change "libxmpp-vala.0.dylib" "@executable_path/../Frameworks/libxmpp-vala.0.dylib" \
    "${OUTPUT_DIR}/${APP_NAME}/Contents/MacOS/dino-bin" 2>/dev/null || true
install_name_tool -change "libqlite.0.dylib" "@executable_path/../Frameworks/libqlite.0.dylib" \
    "${OUTPUT_DIR}/${APP_NAME}/Contents/MacOS/dino-bin" 2>/dev/null || true

# Update libdino
install_name_tool -id "@executable_path/../Frameworks/libdino.0.dylib" \
    "${FRAMEWORKS_DIR}/libdino.0.dylib" 2>/dev/null || true
install_name_tool -change "libxmpp-vala.0.dylib" "@executable_path/../Frameworks/libxmpp-vala.0.dylib" \
    "${FRAMEWORKS_DIR}/libdino.0.dylib" 2>/dev/null || true
install_name_tool -change "libqlite.0.dylib" "@executable_path/../Frameworks/libqlite.0.dylib" \
    "${FRAMEWORKS_DIR}/libdino.0.dylib" 2>/dev/null || true

# Update libxmpp-vala
install_name_tool -id "@executable_path/../Frameworks/libxmpp-vala.0.dylib" \
    "${FRAMEWORKS_DIR}/libxmpp-vala.0.dylib" 2>/dev/null || true

# Update libqlite
install_name_tool -id "@executable_path/../Frameworks/libqlite.0.dylib" \
    "${FRAMEWORKS_DIR}/libqlite.0.dylib" 2>/dev/null || true

# Update plugins
for plugin_path in "${OUTPUT_DIR}/${APP_NAME}/Contents/lib/dino/plugins"/*.dylib; do
    if [ -f "$plugin_path" ]; then
        plugin_name=$(basename "$plugin_path")
        install_name_tool -change "libdino.0.dylib" "@executable_path/../Frameworks/libdino.0.dylib" \
            "$plugin_path" 2>/dev/null || true
        install_name_tool -change "libxmpp-vala.0.dylib" "@executable_path/../Frameworks/libxmpp-vala.0.dylib" \
            "$plugin_path" 2>/dev/null || true
        install_name_tool -change "libqlite.0.dylib" "@executable_path/../Frameworks/libqlite.0.dylib" \
            "$plugin_path" 2>/dev/null || true
        echo "  - Updated ${plugin_name}"
    fi
done

echo ""
echo "✓ Dino.app bundle created successfully!"
echo ""
echo "Location: ${OUTPUT_DIR}/${APP_NAME}"
echo ""
echo "To test the app:"
echo "  open ${OUTPUT_DIR}/${APP_NAME}"
echo ""
echo "To install:"
echo "  cp -r ${OUTPUT_DIR}/${APP_NAME} /Applications/"
echo ""
echo "To create a tarball for distribution:"
echo "  cd ${OUTPUT_DIR} && tar czf Dino-macOS.tar.gz ${APP_NAME}"
echo ""
