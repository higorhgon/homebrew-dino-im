# Homebrew Tap for Dino

This is a [Homebrew](https://brew.sh) tap for [Dino](https://dino.im), a modern XMPP/Jabber chat client for macOS.

## Installation

```bash
brew install --cask higorhgon/dino-im/dino
```

## What is Dino?

Dino is a modern open-source chat client for the XMPP/Jabber protocol. It aims to be easy to use while providing advanced features like:

- End-to-end encryption (OMEMO, OpenPGP)
- Audio/Video calls
- File transfers
- Group chats (MUC)
- Message corrections and reactions
- Modern GTK4 interface with libadwaita

This tap distributes a macOS-optimized version with fixes for notification crashes.

## Features of this macOS Build

- ✅ Fixed notification crash that occurred with avatar images
- ✅ All plugins enabled (HTTP file upload, ICE, OMEMO, OpenPGP, RTP)
- ✅ Native macOS .app bundle
- ✅ Automatic dependency management via Homebrew

## Requirements

- macOS Sonoma (14.0) or later
- Homebrew installed

## Building from Source

If you want to build Dino yourself:

```bash
# Install dependencies
brew install gdk-pixbuf glib gtk4 libadwaita vala meson ninja pkg-config \
  sqlite gnutls libgcrypt srtp gstreamer icu4c gpgme libnice qrencode libsoup libcanberra

# Clone the macOS-fixed version
git clone https://github.com/higorhgon/dino.git
cd dino

# Build with proper PKG_CONFIG_PATH for macOS
PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:/usr/local/opt/icu4c/lib/pkgconfig:/usr/local/Homebrew/Library/Homebrew/os/mac/pkgconfig/26:$PKG_CONFIG_PATH" meson setup build
meson compile -C build

# Run directly
./build/main/dino
```

**Note:** This fork includes a fix for the notification crash on macOS. The upstream Dino repository may crash when displaying notifications with avatar images.

## Self-Signed Certificates

If your XMPP server uses a self-signed certificate, you'll need to add it to the system certificate bundle:

```bash
# Extract certificate
openssl s_client -connect your_xmpp_server:5222 -starttls xmpp </dev/null
   2>/dev/null | openssl x509 -text | sed -ne '/-BEGIN CERTIFICATE-/,/-END
   CERTIFICATE-/p' > /path/to/your-cert.crt

# Verify it
openssl x509 -in /path/to/your-cert.crt -text -noout | grep -A2 "Subject:"

# Add to trusted certificates
sudo cat /path/to/your-cert.crt >> /usr/local/etc/ca-certificates/cert.pem
```

*Note*: After adding the certificate, restart Dino for changes to take effect.

## Uninstall

```bash
brew uninstall --cask dino
```

To remove all data:
```bash
brew uninstall --zap --cask dino
```

## Issues

If you encounter any issues, please report them at:
- [macOS Build Issues](https://github.com/higorhgon/dino/issues) - For macOS-specific problems
- [Upstream Dino Issues](https://github.com/dino/dino/issues) - For general Dino issues
- [This Tap Issues](https://github.com/higorhgon/homebrew-dino-im/issues) - For Homebrew installation issues

## Credits

- Original Dino: https://github.com/dino/dino
- macOS fixes and packaging: https://github.com/higorhgon/dino

## License

- Dino is licensed under GPL-3.0
- This tap is provided as-is for convenience
