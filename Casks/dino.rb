cask "dino" do
  version "0.4.4"
  sha256 "d4b921bd46bc2c8c4e4abd20674f11a63ea4fb65b101c589406956282a0ad010"

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
  
  postflight do
    app_path = "#{appdir}/Dino.app"
    svg_icon = "#{app_path}/Contents/Resources/icons/scalable/apps/im.dino.Dino.svg"
    icns_icon = "#{app_path}/Contents/Resources/AppIcon.icns"
    
    # Convert SVG to ICNS using macOS tools
    system_command "/usr/bin/qlmanage",
                   args: ["-t", "-s", "512", "-o", "#{app_path}/Contents/Resources", svg_icon],
                   print_stderr: false
    
    # Rename the generated PNG
    png_file = "#{app_path}/Contents/Resources/im.dino.Dino.svg.png"
    if File.exist?(png_file)
      iconset_dir = "#{app_path}/Contents/Resources/AppIcon.iconset"
      system_command "/bin/mkdir",
                     args: ["-p", iconset_dir]
      
      # Create iconset with different sizes
      [16, 32, 64, 128, 256, 512].each do |size|
        system_command "/usr/bin/sips",
                       args: ["-z", size.to_s, size.to_s, png_file, "--out",
                              "#{iconset_dir}/icon_#{size}x#{size}.png"],
                       print_stderr: false
        if size <= 256
          system_command "/usr/bin/sips",
                         args: ["-z", (size * 2).to_s, (size * 2).to_s, png_file, "--out",
                                "#{iconset_dir}/icon_#{size}x#{size}@2x.png"],
                         print_stderr: false
        end
      end
      
      # Convert iconset to icns
      system_command "/usr/bin/iconutil",
                     args: ["-c", "icns", iconset_dir, "-o", icns_icon]
      
      # Clean up temporary files
      system_command "/bin/rm",
                     args: ["-rf", iconset_dir, png_file]
    end
    
    # Update Info.plist to reference the icon
    system_command "/usr/bin/plutil",
                   args: ["-insert", "CFBundleIconFile", "-string", "AppIcon",
                          "#{app_path}/Contents/Info.plist"]
    
    # Force macOS to recognize the changes
    system_command "/usr/bin/touch",
                   args: [app_path]
    system_command "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
                   args: ["-f", app_path]
  end

  zap trash: [
    "~/.local/share/dino",
    "~/.config/dino",
    "~/Library/Preferences/im.dino.Dino.plist",
  ]

  caveats <<~EOS
    Dino requires GTK4 and libadwaita to be installed via Homebrew.
    
    To trust self-signed XMPP certificates, you may need to add them to:
      /usr/local/etc/ca-certificates/cert.pem
    
    For more information, visit: https://dino.im
  EOS
end
