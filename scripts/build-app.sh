#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-1.1.0}"
SIGN_IDENTITY="${2:-}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT/.build/release"
APP_DIR="$ROOT/Clipper.app"

echo "==> Building release binary"
swift build -c release --package-path "$ROOT"

echo "==> Creating app bundle"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/"{MacOS,Resources}

cp "$BUILD_DIR/Clipper" "$APP_DIR/Contents/MacOS/Clipper"
chmod +x "$APP_DIR/Contents/MacOS/Clipper"

# Generate SF Symbol icon
ICON_DIR="$APP_DIR/Contents/Resources/Clipper.iconset"
mkdir -p "$ICON_DIR"

swift - <<'SWIFT' "$ICON_DIR"
import AppKit

let iconset = CommandLine.arguments[1]
let symbolName = "doc.on.clipboard"
let sizes: [CGFloat] = [16, 32, 128, 256, 512]

for size in sizes {
    let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)!
    let config = NSImage.SymbolConfiguration(pointSize: size, weight: .regular)
    let configured = image.withSymbolConfiguration(config)!
    
    let cgImage = configured.cgImage(forProposedRect: nil, context: nil, hints: nil)!
    let bitmap = NSBitmapImageRep(cgImage: cgImage)
    bitmap.size = NSSize(width: size, height: size)
    
    let pngData = bitmap.representation(using: .png, properties: [:])!
    
    let file = "\(iconset)/icon_\(Int(size))x\(Int(size)).png"
    try! pngData.write(to: URL(fileURLWithPath: file))
    
    let file2x = "\(iconset)/icon_\(Int(size))x\(Int(size))@2x.png"
    try! pngData.write(to: URL(fileURLWithPath: file2x))
}
print("Iconset generated")
SWIFT

if iconutil -c icns -o "$APP_DIR/Contents/Resources/Clipper.icns" "$ICON_DIR" 2>/dev/null; then
  echo "Custom icon created"
else
  echo "Skipping custom icon (iconutil failed)"
fi
rm -rf "$ICON_DIR"

# Copy Info.plist
cp "$ROOT/Sources/Clipper/Info.plist" "$APP_DIR/Contents/Info.plist"

# Signing
if [[ -n "$SIGN_IDENTITY" ]]; then
  echo "==> Signing with: $SIGN_IDENTITY"
  codesign --force --deep --options runtime --timestamp --sign "$SIGN_IDENTITY" "$APP_DIR"
else
  echo "==> Ad-hoc signing"
  codesign --force --deep --sign - "$APP_DIR"
fi

echo "==> Creating DMG"
cd "$ROOT"
hdiutil create -volname "Clipper" -srcfolder Clipper.app -ov -format UDZO "Clipper-$VERSION.dmg"
rm -rf Clipper.app

echo "==> Done: Clipper-$VERSION.dmg"
shasum -a 256 "Clipper-$VERSION.dmg" | tee "Clipper-$VERSION.dmg.sha256"
