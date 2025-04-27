#!/bin/zsh

#############################################
# 00_download-assets.sh
# Downloads MDMAssets ZIP and prepares environment
#############################################

# ✏️ SETTINGS
ASSET_URL="https://github.com/MaxPowerBoy1980/mac-onboarding-assets/raw/main/dtu/packages/mac-mdm-assets.zip"
ASSET_DIR="/usr/local/MDMAssets"
TMP_ZIP="/tmp/MDMAssets.zip"
LOGFILE="/Library/Logs/Microsoft/IntuneScripts/mdm-onboarding.log"

# 📂 Ensure log directory exists
mkdir -p "$(dirname "$LOGFILE")"

# ✏️ Fallback basic log function (before logging.sh is available)
basic_log() {
    local message="$(date '+%Y-%m-%d %H:%M:%S') [INFO] : $1"
    echo "$message" | tee -a "$LOGFILE"
}

basic_log "🚀 Starting MDM assets download..."

# 📂 Ensure clean target directory
if [[ -d "$ASSET_DIR" ]]; then
    basic_log "🧹 Cleaning old assets in $ASSET_DIR..."
    rm -rf "$ASSET_DIR"
fi
mkdir -p "$ASSET_DIR"

# 🌐 Download assets
basic_log "⬇️ Downloading assets from $ASSET_URL..."
curl -L --retry 3 --silent --show-error --output "$TMP_ZIP" "$ASSET_URL"

if [[ $? -ne 0 ]]; then
    basic_log "❌ ERROR: Failed to download assets."
    exit 1
fi

# 📦 Unpack
basic_log "📦 Unzipping assets to $ASSET_DIR..."
unzip -o "$TMP_ZIP" -d "$ASSET_DIR"

if [[ $? -ne 0 ]]; then
    basic_log "❌ ERROR: Failed to unzip assets."
    exit 1
fi

# 🧹 Clean up temporary ZIP
basic_log "🗑 Removing temporary ZIP file..."
rm -f "$TMP_ZIP"

# ✅ Source logging.sh if available
if [[ -f "$ASSET_DIR/Scripts/logging.sh" ]]; then
    source "$ASSET_DIR/Scripts/logging.sh"
    log "✅ Logging module loaded successfully."
else
    basic_log "⚠️ WARNING: logging.sh not found. Continuing with basic_log."
fi

# 🎯 Final confirmation
if typeset -f log >/dev/null; then
    log "✅ Assets downloaded, unpacked, and environment prepared."
else
    basic_log "✅ Assets downloaded, unpacked, and environment prepared."
fi
