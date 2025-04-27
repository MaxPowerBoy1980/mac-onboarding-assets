#!/bin/zsh

#############################################
# 01_prepare-environment.sh
# Sets up initial device environment
#############################################

# Load logging function
SCRIPT_DIR="$(dirname "$0")"
if [ -f "$SCRIPT_DIR/logging.sh" ]; then
    source "$SCRIPT_DIR/logging.sh"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] : logging.sh not found! Exiting."
    exit 1
fi

log "🚀 Starting prepare-environment script."

#############################################
# Collect Key System Information
#############################################

SERIAL_NUMBER=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $NF}')
MACOS_VERSION=$(sw_vers -productVersion)
MODEL_IDENTIFIER=$(sysctl -n hw.model)
LOGGED_IN_USER=$(stat -f%Su /dev/console)

log "Device Serial Number: $SERIAL_NUMBER"
log "macOS Version: $MACOS_VERSION"
log "Model Identifier: $MODEL_IDENTIFIER"
log "Logged-in User: $LOGGED_IN_USER"

#############################################
# Prepare Device Name
#############################################

if [ -n "$SERIAL_NUMBER" ]; then
    NEW_DEVICE_NAME="DTU-${SERIAL_NUMBER}"
    log "Setting device name to: $NEW_DEVICE_NAME"

    # Set ComputerName, LocalHostName, and HostName
    scutil --set ComputerName "$NEW_DEVICE_NAME"
    scutil --set LocalHostName "$NEW_DEVICE_NAME"
    scutil --set HostName "$NEW_DEVICE_NAME"

    log "✅ Device name successfully set."
else
    log "⚠️ Warning: Serial number not found, skipping device name configuration."
fi

#############################################
# Done
#############################################

log "🏁 Finished prepare-environment script."
exit 0
