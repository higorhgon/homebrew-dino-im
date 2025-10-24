# Known Issues - Dino on macOS

## Emoji Rendering Crash (macOS Sequoia 26.0.1)

### Problem
Dino crashes with a segmentation fault when trying to render emojis on macOS Sequoia. The crash occurs in the CoreText emoji rendering pipeline when accessed through GTK4/Cairo/Pango.

**Crash signature:**
```
Exception Type: EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x000000000bad4007
Crashed in: CoreText -> ImageIO -> PNG loading
```

### Root Cause
This is a system-level bug in macOS Sequoia's CoreText framework when integrated with GTK4's Cairo backend. The issue occurs specifically when:
- GTK4 uses Cairo for rendering
- Cairo calls CoreText for font/glyph rendering  
- CoreText attempts to load Apple Color Emoji font
- The PNG image loading for emoji glyphs triggers an invalid memory access

### Attempted Workarounds (Did Not Work)
- ❌ Setting `PANGO_CAIRO_BACKEND=fc` environment variable
- ❌ Disabling Apple Color Emoji via fontconfig
- ❌ Installing alternative emoji fonts (Noto Color Emoji)
- ❌ Font cache manipulation

These approaches don't work because the crash occurs at a lower system level before font selection takes effect.

### Current Status
**This is a blocking issue on macOS Sequoia.** The application will crash whenever emoji rendering is attempted.

### Potential Solutions

#### Short-term (Workarounds)
1. **Avoid using emojis** - Use text-based emoticons instead
2. **Use an older macOS version** - The issue appears specific to Sequoia
3. **Wait for updates** - Either macOS, GTK4, or Cairo may release a fix

#### Long-term (Requires Code Changes)
1. **Native macOS Emoji Picker Integration**
   - Intercept emoji button clicks
   - Call macOS native emoji picker (Ctrl+Cmd+Space)
   - Insert selected emoji as text without rendering
   - This bypasses the CoreText rendering path entirely

2. **Alternative Rendering Path**
   - Use image-based emoji rendering instead of font-based
   - Load emoji as PNG/SVG resources
   - Bypass CoreText completely

3. **Upstream Fixes**
   - Report to GTK developers
   - Report to Cairo developers
   - Report to Apple (if macOS bug)

### For Developers
If you want to implement the native emoji picker solution:

```vala
#if MACOS
// Detect emoji button click
button.clicked.connect(() => {
    // Call native emoji picker
    Posix.system("osascript -e 'tell application \"System Events\" to keystroke space using {command down, control down}'");
});
#endif
```

This would be the cleanest solution until the underlying CoreText issue is resolved.

### Related Issues
- Similar crashes reported in other GTK4 apps on macOS Sequoia
- CoreText API changes in macOS 26.0.1 may be responsible
- Waiting for GTK4 4.20.3+ or Cairo 1.18.5+ for potential fixes

### Recommendation
**Do not use Dino on macOS Sequoia if emoji support is required.** Either:
- Use an alternative XMPP client that doesn't have this issue
- Run Dino in a Linux VM or container
- Wait for upstream fixes
