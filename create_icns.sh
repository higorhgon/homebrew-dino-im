#!/bin/bash
set -e

# Script to convert SVG to ICNS for macOS app bundle
# This creates the AppIcon.icns file needed for the app bundle

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SVG_FILE="${SCRIPT_DIR}/Resources/im.dino.Dino.svg"
OUTPUT_ICNS="${SCRIPT_DIR}/Resources/AppIcon.icns"

if [ ! -f "${SVG_FILE}" ]; then
    echo "Error: SVG icon not found at ${SVG_FILE}"
    exit 1
fi

echo "Creating AppIcon.icns from SVG..."

# Create temporary iconset directory
ICONSET_DIR=$(mktemp -d)/AppIcon.iconset
mkdir -p "${ICONSET_DIR}"

# Generate all required icon sizes with white background
for size in 16 32 128 256 512; do
    size2x=$((size * 2))
    echo "  Generating ${size}x${size} icons..."
    
    # Standard resolution - convert SVG to PNG with white background
    rsvg-convert -w ${size} -h ${size} "${SVG_FILE}" -o "${ICONSET_DIR}/temp_${size}.png"
    convert "${ICONSET_DIR}/temp_${size}.png" -background white -alpha remove -alpha off "${ICONSET_DIR}/icon_${size}x${size}.png"
    rm "${ICONSET_DIR}/temp_${size}.png"
    
    # Retina resolution - convert SVG to PNG with white background
    rsvg-convert -w ${size2x} -h ${size2x} "${SVG_FILE}" -o "${ICONSET_DIR}/temp_${size2x}.png"
    convert "${ICONSET_DIR}/temp_${size2x}.png" -background white -alpha remove -alpha off "${ICONSET_DIR}/icon_${size}x${size}@2x.png"
    rm "${ICONSET_DIR}/temp_${size2x}.png"
done

# Convert iconset to icns
echo "  Converting iconset to ICNS..."
iconutil -c icns "${ICONSET_DIR}" -o "${OUTPUT_ICNS}"

# Clean up
rm -rf "$(dirname ${ICONSET_DIR})"

echo "✓ AppIcon.icns created successfully at ${OUTPUT_ICNS}"
