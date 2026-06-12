#!/bin/bash
# Stops WindowManager and removes the LaunchAgent and installed binary.
set -euo pipefail

LABEL="com.local.window-manager"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
BINARY="$HOME/.local/bin/window-manager"

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
rm -f "$PLIST" "$BINARY"
echo "Uninstalled. You can also remove the stale entry from"
echo "System Settings > Privacy & Security > Accessibility."
