#!/bin/bash

# Path to the user-scoped plist (as installed manually or by user context)
USER_PLIST="/Library/Managed Preferences/odaugaard/com.secondsonconsulting.baseline.plist"

# Path to system-wide managed preferences
DEST_PLIST="/Library/Managed Preferences/com.secondsonconsulting.baseline.plist"

# Copy with sudo to ensure correct ownership and path
if [ -f "$USER_PLIST" ]; then
    echo "Copying user-scoped Baseline config to system location..."
    sudo cp "$USER_PLIST" "$DEST_PLIST"
    sudo chown root:wheel "$DEST_PLIST"
    echo "Done."
else
    echo "User-scoped plist not found. Skipping copy."
fi
