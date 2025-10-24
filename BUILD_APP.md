# Creating Dino.app Bundle

This script creates a macOS `.app` bundle from the Dino build directory.

## Prerequisites

1. Dino source code cloned to `~/dino`
2. Dino built with meson:
   ```bash
   cd ~/dino
   meson setup build
   meson compile -C build
   ```
3. All dependencies installed via Homebrew (GTK4, libadwaita, etc.)

## Usage

Simply run the script:

```bash
./create_app_bundle.sh
```

This will create `Dino.app` in the current directory.

## What the Script Does

1. **Creates bundle structure**: Sets up the standard macOS `.app` directory layout
2. **Copies binaries**: 
   - Main `dino` executable → `dino-bin`
   - Libraries (libdino, libxmpp-vala, libqlite)
   - All plugins (HTTP files, ICE, OMEMO, OpenPGP, RTP)
3. **Copies resources**:
   - Icons
   - Locale/translation files
4. **Creates launcher script**: Sets up environment variables for GTK4/Homebrew libraries
5. **Creates Info.plist**: macOS bundle metadata
6. **Fixes library paths**: Uses `install_name_tool` to update dylib references to use `@executable_path`

## Testing the App

```bash
# Test from command line
open Dino.app

# Or run directly
./Dino.app/Contents/MacOS/dino
```

## Installing

```bash
# Copy to Applications folder
cp -r Dino.app /Applications/

# Launch from Finder or Spotlight
open /Applications/Dino.app
```

## Creating Distribution Package

To create a tarball for distribution:

```bash
tar czf Dino-macOS.tar.gz Dino.app
```

Then upload `Dino-macOS.tar.gz` to GitHub releases.

## Notes

### Icon Conversion

The script does not automatically convert the SVG icon to ICNS format. To create a proper macOS icon:

```bash
# Method 1: Using iconutil (requires PNG sequence)
# Create icon.iconset directory with required sizes:
# icon_16x16.png, icon_32x32.png, icon_128x128.png, etc.
iconutil -c icns icon.iconset -o Dino.app/Contents/Resources/AppIcon.icns

# Method 2: Use third-party tools like:
# - Image2Icon
# - Icon Composer
# - Online converters
```

### Library Dependencies

The app still depends on Homebrew-installed libraries. Users need to have:
- GTK4
- libadwaita
- GStreamer
- Other dependencies installed via Homebrew

This is managed by the Cask formula which declares these dependencies.

### Updating the Cask

After creating a new bundle:

1. Create tarball:
   ```bash
   tar czf Dino-macOS.tar.gz Dino.app
   ```

2. Calculate SHA256:
   ```bash
   shasum -a 256 Dino-macOS.tar.gz
   ```

3. Upload to GitHub releases

4. Update `Casks/dino.rb`:
   - Update version number
   - Update sha256 hash
   - Update download URL

## Troubleshooting

### Library not found errors

If you get "Library not loaded" errors, check:

```bash
# View library dependencies
otool -L Dino.app/Contents/MacOS/dino-bin
otool -L Dino.app/Contents/Frameworks/*.dylib

# Verify Homebrew libraries are installed
brew list gtk4 libadwaita glib
```

### Plugin not loading

Check plugin directory:
```bash
ls -la Dino.app/Contents/lib/dino/plugins/
```

Verify environment variable in launcher script:
```bash
cat Dino.app/Contents/MacOS/dino
```

### GStreamer issues

Ensure GStreamer plugins are findable:
```bash
export GST_PLUGIN_PATH="/usr/local/lib/gstreamer-1.0:$GST_PLUGIN_PATH"
```

## Script Customization

To modify the script for different paths or configurations, edit:

- `DINO_SOURCE`: Path to Dino source directory (default: `~/dino`)
- `OUTPUT_DIR`: Where to create the app bundle (default: current directory)
- Version in Info.plist: Update `CFBundleShortVersionString`
