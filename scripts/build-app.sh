#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-0.2.0}"
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

# SF Symbol → icns via `swift -` JIT is unreliable (AppKit symbols missing).
# Prefer a prebuilt icns if present; otherwise ship without a custom icon.
if [[ -f "$ROOT/Sources/Clipper/Clipper.icns" ]]; then
  cp "$ROOT/Sources/Clipper/Clipper.icns" "$APP_DIR/Contents/Resources/Clipper.icns"
  echo "Using Sources/Clipper/Clipper.icns"
else
  echo "Skipping custom icon (no Clipper.icns; menu bar uses SF Symbol at runtime)"
fi

cp "$ROOT/Sources/Clipper/Info.plist" "$APP_DIR/Contents/Info.plist"

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
