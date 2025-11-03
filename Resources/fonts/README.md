# Emoji Fonts

This directory contains emoji fonts bundled with the Dino.app.

## Noto Color Emoji

- **File**: `NotoColorEmoji.ttf`
- **Source**: [Google Noto Emoji](https://github.com/googlefonts/noto-emoji)
- **License**: SIL Open Font License 1.1
- **Purpose**: Provides comprehensive emoji support for the macOS app bundle

The font is bundled to ensure consistent emoji rendering across all systems, 
independent of the user's installed fonts.

### Updating the Font

To update to the latest version:

```bash
curl -L "https://github.com/googlefonts/noto-emoji/raw/main/fonts/NotoColorEmoji.ttf" \
  -o Resources/fonts/NotoColorEmoji.ttf
```
