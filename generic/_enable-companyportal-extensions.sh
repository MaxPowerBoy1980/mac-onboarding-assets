#!/bin/bash

# Purpose: Enable Microsoft Company Portal extensions for SSO and Passkey Autofill

APP_PATH="/Applications/Company Portal.app"
SSO_EXTENSION="com.microsoft.CompanyPortalMac.ssoextension"
AUTOFILL_EXTENSION="com.microsoft.CompanyPortalMac.Mac-Autofill-Extension"
READY=0
EXIT_STATUS=0
# Prompt the user to register if needed
ssoStatus=$(app-sso platform -s)
REG_COMPLETED=$(getValueOf registrationCompleted || echo "false")

if [[ "$REG_COMPLETED" != "true" ]]; then
    log "Device is not registered. Prompting user."

    # Kill any existing dialog to prevent duplicates
    pkill -f "/usr/local/bin/dialog" 2>/dev/null

    # Force the registration dialog to appear
    pkill AppSSOAgent
    sleep 3
    app-sso -l >/dev/null 2>&1
fi

log() {
    echo "$(date) | $1"
}

log "Looking for $APP_PATH..."

# Wait until Company Portal is installed
while [[ $READY -ne 1 ]]; do
    if [[ -e "$APP_PATH" ]]; then
        READY=1
        log "Found $APP_PATH."
    else
        log "Not installed yet. Waiting 30 seconds..."
        sleep 30
    fi
done

# Get the UID of the logged-in user
uid=$(stat -f "%u" /dev/console)

# Verify pluginkit is available
if ! command -v pluginkit &>/dev/null; then
    log "ERROR: 'pluginkit' not available. Exiting."
    exit 1
fi

enable_extension() {
    local extension_id="$1"
    local extension_label="$2"

    log "Checking $extension_label ($extension_id)..."

    if launchctl asuser "$uid" pluginkit -m | grep "$extension_id" >/dev/null; then
        if launchctl asuser "$uid" pluginkit -m | grep "+    $extension_id" >/dev/null; then
            log "$extension_label already enabled."
        else
            log "Enabling $extension_label..."
            if launchctl asuser "$uid" pluginkit -e use -i "$extension_id"; then
                log "$extension_label enabled successfully."
                sleep 2
            else
                log "ERROR: Failed to enable $extension_label."
                EXIT_STATUS=1
            fi
        fi
    else
        log "ERROR: $extension_label ($extension_id) not found!"
        EXIT_STATUS=1
    fi
}

# Enable both extensions
enable_extension "$SSO_EXTENSION" "Company Portal SSO Extension"

ExtensionName4="com.microsoft.CompanyPortalMac.Mac-Autofill-Extension"
echo "$(date) | ExtensionName is $ExtensionName4"

if [ -z "$ExtensionName4" ]; then
    echo "$(date) | Error: ExtensionName4 is null or empty."
    echo "$(date) | Exiting script in 30 seconds"
    sleep 30
    exit 1
fi

echo "$(date) | Checking $ExtensionName4 status"
if launchctl asuser "$uid" bash -c "pluginkit -m | grep \"+    $ExtensionName4\""; then
    echo "$(date) | $ExtensionName4 already enabled"
else
    echo "$(date) | Enabling $ExtensionName4"
    echo "$(date) | Running launchctl asuser \"$uid\" bash -c 'pluginkit -e use -i \"'"$ExtensionName4"'\"'"
    launchctl asuser "$uid" bash -c 'pluginkit -e use -i "'"$ExtensionName4"'"'
    echo "$(date) | Command executed"
fi

if [[ $EXIT_STATUS -eq 0 ]]; then
    log "All extensions enabled successfully."
else
    log "One or more extensions failed to enable."
fi

exit $EXIT_STATUS
