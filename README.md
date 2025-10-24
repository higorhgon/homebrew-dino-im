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

## Requirements

- macOS Sonoma (14.0) or later
- Homebrew installed

## Building from Source

If you want to build Dino yourself:

```bash
# Install dependencies
brew install gdk-pixbuf glib gtk4 libadwaita vala meson ninja pkg-config \
  sqlite gnutls libgcrypt srtp gstreamer icu4c gpgme libnice qrencode libsoup libcanberra

# Clone and build
git clone https://github.com/dino/dino.git
cd dino
PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:/usr/local/opt/icu4c/lib/pkgconfig:/usr/local/Homebrew/Library/Homebrew/os/mac/pkgconfig/26:$PKG_CONFIG_PATH" meson setup build
meson compile -C build
```

## Self-Signed Certificates

If your XMPP server uses a self-signed certificate, you'll need to add it to the system certificate bundle:

```bash
sudo cat /path/to/your-cert.crt >> /usr/local/etc/ca-certificates/cert.pem
```

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
- [Dino Issues](https://github.com/dino/dino/issues)
- [This Tap Issues](https://github.com/higorhgon/homebrew-dino-im/issues)

## License

- Dino is licensed under GPL-3.0
- This tap is provided as-is for convenience
