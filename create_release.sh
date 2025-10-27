#!/bin/bash
set -e

# Script to create a complete Dino release package for macOS
# This script combines building, bundling, and packaging

VERSION="${1:-0.4.4}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "================================================"
echo "Dino macOS Release Builder v${VERSION}"
echo "================================================"
echo ""

# Step 1: Build Dino
echo "Step 1: Checking prerequisites..."
if [ ! -d "${HOME}/dino" ]; then
    echo "Error: Dino source not found at ~/dino"
    echo "Please clone: git clone https://github.com/higorhgon/dino.git ~/dino"
    exit 1
fi

if [ ! -f "${SCRIPT_DIR}/Resources/AppIcon.icns" ]; then
    echo "Error: AppIcon.icns not found"
    echo "Run: ./create_icns.sh"
    exit 1
fi
echo "  ✓ Prerequisites OK"
echo ""

echo "Step 2: Building Dino from source..."

cd "${HOME}/dino"
echo "  Rebuilding..."
meson compile -C build || {
    echo "Error: Build failed"
    exit 1
}
echo "  ✓ Build completed"
echo ""

# Step 3: Create app bundle
echo "Step 3: Creating Dino.app bundle..."
cd "${SCRIPT_DIR}"
./create_app_bundle.sh || {
    echo "Error: Bundle creation failed"
    exit 1
}
echo ""

# Step 4: Create tarball
echo "Step 4: Creating distribution tarball..."
if [ -f "Dino-macOS.tar.gz" ]; then
    echo "  Removing old tarball..."
    rm -f Dino-macOS.tar.gz
fi

tar czf Dino-macOS.tar.gz Dino.app
TARBALL_SIZE=$(ls -lh Dino-macOS.tar.gz | awk '{print $5}')
echo "  ✓ Created Dino-macOS.tar.gz (${TARBALL_SIZE})"
echo ""

# Step 5: Calculate checksums
echo "Step 5: Calculating checksums..."
SHA256=$(shasum -a 256 Dino-macOS.tar.gz | awk '{print $1}')
echo "  SHA256: ${SHA256}"
echo ""

# Step 6: Update Cask formula
echo "Step 6: Cask formula information..."
echo ""
echo "Update Casks/dino.rb with:"
echo "  version \"${VERSION}\""
echo "  sha256 \"${SHA256}\""
echo ""
echo "After uploading to GitHub release, update the URL to:"
echo "  url \"https://github.com/higorhgon/homebrew-dino-im/releases/download/v${VERSION}/Dino-macOS.tar.gz\""
echo ""

# Step 7: Test extraction
echo "Step 7: Testing tarball extraction..."
TEST_DIR="/tmp/dino_release_test_$$"
mkdir -p "${TEST_DIR}"
cd "${TEST_DIR}"
tar xzf "${SCRIPT_DIR}/Dino-macOS.tar.gz"
if [ -d "Dino.app" ]; then
    echo "  ✓ Tarball extracts correctly"
    VERSION_OUTPUT=$(./Dino.app/Contents/MacOS/dino --version 2>&1 || echo "Failed")
    echo "  ✓ Version check: ${VERSION_OUTPUT}"
else
    echo "  ✗ Tarball extraction failed"
fi
cd "${SCRIPT_DIR}"
rm -rf "${TEST_DIR}"
echo ""

# Summary
echo "================================================"
echo "Release package created successfully!"
echo "================================================"
echo ""
echo "Files created:"
echo "  - ${SCRIPT_DIR}/Dino.app/"
echo "  - ${SCRIPT_DIR}/Dino-macOS.tar.gz (${TARBALL_SIZE})"
echo ""
echo "Next steps:"
echo "  1. Test the app: open Dino.app"
echo "  2. Create GitHub release v${VERSION}"
echo "  3. Upload Dino-macOS.tar.gz"
echo "  4. Update Casks/dino.rb with new version and SHA256"
echo "  5. Copy RELEASE_NOTES.md content to GitHub release description"
echo "  6. Tag and push: git tag v${VERSION} && git push origin v${VERSION}"
echo ""
echo "SHA256 for Cask: ${SHA256}"
echo ""
