#!/bin/bash
set -e

echo "🔨 Building iOS Release App (without code signing)..."
flutter build ios --release --no-codesign

IPA_DIR="build/ios/ipa"
PAYLOAD_DIR="$IPA_DIR/Payload"
OUTPUT_IPA="$IPA_DIR/QuranCompanion.ipa"

echo "📦 Packaging IPA for SideStore..."
rm -rf "$IPA_DIR"
mkdir -p "$PAYLOAD_DIR"
cp -R build/ios/iphoneos/Runner.app "$PAYLOAD_DIR/"

cd "$IPA_DIR"
zip -r -9 QuranCompanion.ipa Payload > /dev/null
cd ../../..

echo "✅ IPA created successfully at: $(pwd)/$OUTPUT_IPA"
ls -lh "$OUTPUT_IPA"
