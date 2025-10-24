# Dino v0.4.4 - macOS Release

## Download

**File:** Dino-macOS.tar.gz  
**Size:** 2.5 MB  
**SHA256:** `a7089b6cc583999cd2a461489b40d2d5984950eac1c778119f1291177dc5b73f`

## What's New in This Release

### 🐛 Bug Fixes

- **Fixed emoji rendering crash on macOS** - Resolved SIGSEGV crash in CoreText/ImageIO when rendering emoji characters
- **Fixed notification crash with avatars** - Previous fix for avatar-related crashes

### 🔧 Technical Details

The emoji crash was caused by GTK4/Cairo/CoreText integration issue when emoji glyphs were enlarged using Pango markup. The fix disables emoji size scaling specifically on macOS while maintaining the feature on other platforms.

**Crash details:**
- Exception Type: `EXC_BAD_ACCESS (SIGSEGV)`
- Exception Address: `0x000000000bad4007`
- Stack trace: ImageIO → PNGReadPlugin → CoreText → CTFontDrawGlyphs

**Solution:** Conditional compilation to disable emoji enlargement on macOS only.

## Installation

### Via Homebrew (Recommended)

```bash
brew install --cask higorhgon/dino-im/dino
```

### Manual Installation

1. Download `Dino-macOS.tar.gz` from this release
2. Verify SHA256 checksum:
   ```bash
   shasum -a 256 Dino-macOS.tar.gz
   ```
3. Extract and install:
   ```bash
   tar xzf Dino-macOS.tar.gz
   cp -r Dino.app /Applications/
   ```
4. Open from Applications folder or Spotlight

## Requirements

- macOS 14.0 (Sonoma) or later
- Homebrew with required dependencies:
  ```bash
  brew install gdk-pixbuf glib gtk4 libadwaita sqlite gnutls \
    libgcrypt srtp gstreamer icu4c gpgme libnice qrencode \
    libsoup libcanberra
  ```

## Features

- ✅ End-to-end encryption (OMEMO, OpenPGP)
- ✅ Audio/Video calls
- ✅ File transfers
- ✅ Group chats (MUC)
- ✅ Message corrections and reactions
- ✅ Modern GTK4 interface with libadwaita
- ✅ All plugins enabled (HTTP file upload, ICE, OMEMO, OpenPGP, RTP)

## Known Issues

- Emoji-only messages display at normal size (not enlarged) on macOS due to the crash fix
- Self-signed XMPP certificates require manual trust setup

## Building from Source

See the [homebrew-tap repository](https://github.com/higorhgon/homebrew-dino-im) for build instructions and the `create_app_bundle.sh` script.

## Credits

- Original Dino: https://github.com/dino/dino
- macOS fixes and packaging: https://github.com/higorhgon/dino

## Support

- Report macOS-specific issues: https://github.com/higorhgon/dino/issues
- Report general Dino issues: https://github.com/dino/dino/issues
- Homebrew tap issues: https://github.com/higorhgon/homebrew-dino-im/issues

---

**License:** GPL-3.0  
**Version:** 0.4.4 (based on Dino 0.5.0~git49)  
**Release Date:** 2025-10-24
