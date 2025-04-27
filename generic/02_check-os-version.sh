#!/bin/zsh

#############################################
# 02_check-os-version.sh
# Verifies minimum macOS version requirement
#############################################

# 📂 Load logging module
LOGGING_SCRIPT="/usr/local/MDMAssets/Scripts/logging.sh"

if [ -f "$LOGGING_SCRIPT" ]; then
    source "$LOGGING_SCRIPT"
    log "✅ Logging module loaded successfully."
else
    echo "❌ ERROR: Logging module not found. Exiting."
    exit 1
fi

# ✏️ SETTINGS
MINIMUM_VERSION="13.0"

# 🚀 Start version check
log "🚀 Starting macOS version check..."

# 🔍 Get current macOS version
CURRENT_VERSION=$(sw_vers -productVersion)
log "Detected macOS version: $CURRENT_VERSION"
log "Required minimum version: $MINIMUM_VERSION"

# 📈 Compare versions
autoload is-at-least
if ! command -v is-at-least >/dev/null 2>&1; then
    log "❌ is-at-least function not available. Exiting."
    exit 1
fi

if is-at-least "$MINIMUM_VERSION" "$CURRENT_VERSION"; then
    log "✅ macOS version is sufficient."
else
    log "❌ macOS version too low. Exiting."
    exit 1
fi

# 🎯 Script completed
log "🏁 macOS version verification completed successfully."
exit 0
