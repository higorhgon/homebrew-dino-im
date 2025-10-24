cask "dino" do
  version "0.4.4"
  sha256 "a7089b6cc583999cd2a461489b40d2d5984950eac1c778119f1291177dc5b73f"

  url "https://github.com/higorhgon/homebrew-dino-im/releases/download/v#{version}/Dino-macOS.tar.gz"
  name "Dino"
  desc "Modern XMPP/Jabber chat client"
  homepage "https://dino.im"

  depends_on macos: ">= :sonoma"
  
  # Homebrew dependencies
  depends_on formula: "gdk-pixbuf"
  depends_on formula: "glib"
  depends_on formula: "gtk4"
  depends_on formula: "libadwaita"
  depends_on formula: "vala"
  depends_on formula: "sqlite"
  depends_on formula: "gnutls"
  depends_on formula: "libgcrypt"
  depends_on formula: "srtp"
  depends_on formula: "gstreamer"
  depends_on formula: "icu4c@77"
  depends_on formula: "gpgme"
  depends_on formula: "libnice"
  depends_on formula: "qrencode"
  depends_on formula: "libsoup"
  depends_on formula: "libcanberra"

  app "Dino.app"

  zap trash: [
    "~/.local/share/dino",
    "~/.config/dino",
    "~/Library/Preferences/im.dino.Dino.plist",
  ]

  caveats <<~EOS
    Dino requires GTK4 and libadwaita to be installed via Homebrew.
    
    ⚠️  CRITICAL KNOWN ISSUE - Emoji Crash:
    The app may crash when displaying emoji due to a GTK4/macOS CoreText bug.
    
    WORKAROUND: Set this environment variable before running:
      export PANGOCAIRO_BACKEND=fc
    
    Or edit ~/Library/Preferences/im.dino.Dino.plist and add:
      <key>PANGOCAIRO_BACKEND</key>
      <string>fc</string>
    
    This forces Pango to use FontConfig instead of CoreText for rendering.
    
    To trust self-signed XMPP certificates, add them to:
      /usr/local/etc/ca-certificates/cert.pem
    
    For more information, visit: https://dino.im
  EOS
end
