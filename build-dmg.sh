#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  macRAR — DMG Builder
#  Run this after archiving in Xcode:
#    Product → Archive → Distribute App → Copy App → save to Desktop
#  Then run:
#    chmod +x build-dmg.sh && ./build-dmg.sh
# ─────────────────────────────────────────────────────────────

set -e

APP_NAME="macRAR"
DMG_NAME="macRAR-1.0"
VOLUME_NAME="macRAR"
SRC_APP="$HOME/Desktop/macRAR.app"
OUTPUT_DMG="$HOME/Desktop/${DMG_NAME}.dmg"
TMP_DIR=$(mktemp -d)
STAGING="$TMP_DIR/dmg-staging"

echo ""
echo "  📦 macRAR DMG Builder"
echo "  ─────────────────────────────────────"

# ── Sanity check ──────────────────────────────────────────────
if [ ! -d "$SRC_APP" ]; then
    echo ""
    echo "  ❌ Could not find macRAR.app on your Desktop."
    echo ""
    echo "  Please export it from Xcode first:"
    echo "    1. Product → Archive"
    echo "    2. Distribute App → Copy App"
    echo "    3. Save to Desktop"
    echo ""
    exit 1
fi

echo "  ✔ Found macRAR.app"

# ── Staging ───────────────────────────────────────────────────
mkdir -p "$STAGING"
echo "  → Copying app…"
cp -R "$SRC_APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

# ── Create temp writable DMG ─────────────────────────────────
TEMP_DMG="$TMP_DIR/temp.dmg"
echo "  → Creating disk image…"
hdiutil create \
    -srcfolder "$STAGING" \
    -volname "$VOLUME_NAME" \
    -fs HFS+ \
    -fsargs "-c c=64,a=16,b=16" \
    -format UDRW \
    -size 60m \
    "$TEMP_DMG" > /dev/null

# ── Mount ─────────────────────────────────────────────────────
echo "  → Mounting…"
MOUNT_DIR="$TMP_DIR/mount"
mkdir -p "$MOUNT_DIR"
hdiutil attach "$TEMP_DMG" -mountpoint "$MOUNT_DIR" -noautoopen -quiet

# ── Arrange icons with AppleScript ───────────────────────────
echo "  → Styling window…"
osascript << APPLESCRIPT
tell application "Finder"
    tell disk "$VOLUME_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set bounds of container window to {400, 100, 920, 440}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 100
        set position of item "$APP_NAME.app" of container window to {140, 180}
        set position of item "Applications" of container window to {380, 180}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
APPLESCRIPT

# ── Permissions & detach ──────────────────────────────────────
echo "  → Finalising…"
chmod -Rf go-w "$MOUNT_DIR"
sync
hdiutil detach "$MOUNT_DIR" -quiet
sleep 1

# ── Convert to compressed read-only DMG ──────────────────────
echo "  → Compressing…"
rm -f "$OUTPUT_DMG"
hdiutil convert "$TEMP_DMG" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "$OUTPUT_DMG" > /dev/null

# ── Cleanup ───────────────────────────────────────────────────
rm -rf "$TMP_DIR"

echo ""
echo "  ✅ Done!"
echo "  📀 ${DMG_NAME}.dmg saved to your Desktop"
echo ""
