# GitHub Release Instructions

## Files Ready for Release

✅ **Dino-macOS.tar.gz** (2.5 MB)  
✅ **SHA256:** `1769d6a44b9b496d44c8ac12a120e26f4a004f68e6a42771b5ef8a634130b55a`

## Steps to Create GitHub Release

### 1. Create the Release on GitHub

Go to: https://github.com/higorhgon/homebrew-dino-im/releases/new

**Tag version:** `v0.4.4`  
**Release title:** `Dino v0.4.4 - macOS (Emoji Crash Fix)`  
**Description:** Copy content from `RELEASE_NOTES.md`

### 2. Upload the Tarball

Drag and drop or select: `Dino-macOS.tar.gz`

### 3. Publish the Release

Click "Publish release"

### 4. Update the Cask Formula

After publishing, get the download URL:
```
https://github.com/higorhgon/homebrew-dino-im/releases/download/v0.4.4/Dino-macOS.tar.gz
```

Edit `Casks/dino.rb`:

```ruby
cask "dino" do
  version "0.4.4"
  sha256 "1769d6a44b9b496d44c8ac12a120e26f4a004f68e6a42771b5ef8a634130b55a"

  url "https://github.com/higorhgon/homebrew-dino-im/releases/download/v#{version}/Dino-macOS.tar.gz"
  # ... rest of the file
end
```

### 5. Commit and Push the Cask Update

```bash
cd ~/homebrew-tap
git add Casks/dino.rb
git commit -m "Update Dino cask to v0.4.4 (emoji crash fix)

- New SHA256: 1769d6a44b9b496d44c8ac12a120e26f4a004f68e6a42771b5ef8a634130b55a
- Fixed emoji rendering crash on macOS
- Updated download URL for v0.4.4 release"
git push origin main
```

### 6. Test the Installation

```bash
# Uninstall old version if installed
brew uninstall --cask dino

# Install new version
brew install --cask higorhgon/dino-im/dino

# Verify
/Applications/Dino.app/Contents/MacOS/dino --version
```

## Alternative: Create Release via Command Line

If you prefer using GitHub CLI:

```bash
# Install GitHub CLI if not already installed
brew install gh

# Authenticate
gh auth login

# Create release
gh release create v0.4.4 \
  --title "Dino v0.4.4 - macOS (Emoji Crash Fix)" \
  --notes-file RELEASE_NOTES.md \
  Dino-macOS.tar.gz

# The release will be created and the file uploaded automatically
```

## Verification Checklist

- [ ] Release created on GitHub with v0.4.4 tag
- [ ] Dino-macOS.tar.gz uploaded to release
- [ ] Release notes include SHA256 checksum
- [ ] Casks/dino.rb updated with new version and SHA256
- [ ] Changes committed and pushed
- [ ] Installation tested with `brew install --cask`
- [ ] App launches without crashes
- [ ] Emoji rendering works without crashes

## Announcement Text (Optional)

For social media or community announcements:

```
🎉 Dino v0.4.4 for macOS is now available!

🐛 Fixed: Emoji rendering crash (SIGSEGV in CoreText/ImageIO)
🐛 Fixed: Notification crash with avatar images

Install via Homebrew:
brew install --cask higorhgon/dino-im/dino

More info: https://github.com/higorhgon/homebrew-dino-im
```

## Support Resources

- Report issues: https://github.com/higorhgon/dino/issues
- Tap repository: https://github.com/higorhgon/homebrew-dino-im
- Original Dino: https://dino.im
