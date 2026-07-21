#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT/build"
ARCHIVE_PATH="$BUILD_DIR/AltKeeper.xcarchive"
IPA_PATH="$BUILD_DIR/AltKeeper-unsigned.ipa"

echo "==> Archiveren (unsigned)..."
xcodebuild \
  -project "$ROOT/AltKeeper.xcodeproj" \
  -scheme AltKeeper \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE_PATH" \
  archive \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  DEVELOPMENT_TEAM=""

APP_PATH="$(find "$ARCHIVE_PATH/Products/Applications" -name '*.app' -maxdepth 1 | head -1)"
if [[ -z "$APP_PATH" ]]; then
  echo "Fout: .app niet gevonden in archive." >&2
  exit 1
fi

echo "==> IPA aanmaken..."
rm -rf "$BUILD_DIR/Payload" "$IPA_PATH"
mkdir -p "$BUILD_DIR/Payload"
cp -R "$APP_PATH" "$BUILD_DIR/Payload/"
(
  cd "$BUILD_DIR"
  zip -qr "AltKeeper-unsigned.ipa" Payload
)

echo "Klaar: $IPA_PATH"
