#!/bin/bash
# Builds WindowManager, installs it to a stable location, and registers a
# LaunchAgent so it runs in the background and starts at login.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL_DIR="$HOME/.local/bin"
BINARY="$INSTALL_DIR/window-manager"
LABEL="com.local.window-manager"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

echo "Building release binary..."
swift build -c release --package-path "$PROJECT_DIR"

echo "Installing to $BINARY..."
mkdir -p "$INSTALL_DIR"
# Stop a running instance so the binary can be replaced.
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
killall WindowManager window-manager 2>/dev/null || true
cp "$PROJECT_DIR/.build/release/WindowManager" "$BINARY"

echo "Writing LaunchAgent..."
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$BINARY</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ProcessType</key>
    <string>Interactive</string>
</dict>
</plist>
EOF

echo "Starting..."
launchctl bootstrap "gui/$(id -u)" "$PLIST"

echo
echo "Done. WindowManager now runs in the background and starts at login."
echo
echo "IMPORTANT: the installed copy is a new binary at a new path, so macOS"
echo "will ask for Accessibility permission again. Grant it for:"
echo "  $BINARY"
echo "(System Settings > Privacy & Security > Accessibility), then run:"
echo "  launchctl kickstart -k gui/\$(id -u)/$LABEL"
