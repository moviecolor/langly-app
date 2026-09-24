#!/bin/bash
# verify_bgmode.sh — Gate: assert the built Langly .app/.ipa declares
# UIBackgroundModes = [audio]. Without this plist key, AVSpeechSynthesizer
# (Audio Mode) dies the moment the screen locks on a real device — the
# simulator does NOT enforce it, so this must be checked on the artifact.
#
# Usage:
#   scripts/verify_bgmode.sh [path-to-Langly.app-or-.ipa]
#   (defaults to the freshest Debug-iphoneos product in DerivedData)
set -euo pipefail

ARTIFACT="${1:-}"
if [[ -z "$ARTIFACT" ]]; then
  ARTIFACT="$(find "$HOME/Library/Developer/Xcode/DerivedData" -path '*/Build/Products/Debug-iphoneos/Langly.app' -maxdepth 8 2>/dev/null | head -1)"
fi
[[ -n "$ARTIFACT" ]] || { echo "❌ No artifact found"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [[ "$ARTIFACT" == *.app ]]; then
  PLIST="$ARTIFACT/Info.plist"
elif [[ "$ARTIFACT" == *.ipa ]]; then
  unzip -q "$ARTIFACT" 'Payload/Langly.app/Info.plist' -d "$TMP"
  PLIST="$TMP/Payload/Langly.app/Info.plist"
else
  echo "❌ Unsupported artifact (need .app or .ipa)"; exit 1
fi

if /usr/libexec/PlistBuddy -c "Print :UIBackgroundModes" "$PLIST" 2>/dev/null | grep -qx "    audio"; then
  echo "✅ $ARTIFACT declares UIBackgroundModes = [audio] (background audio OK on lock)"
else
  echo "❌ $ARTIFACT is MISSING UIBackgroundModes=[audio] — Audio Mode will stop on screen lock!"
  exit 1
fi