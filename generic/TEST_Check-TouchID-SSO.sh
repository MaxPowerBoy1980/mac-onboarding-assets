#!/bin/bash
# MOCK: Simulate `app-sso platform -s` output
app-sso() {
    # Simulate registration complete = true or false
    # Set SIMULATED_STATUS="true" or "false" to test both paths
    SIMULATED_STATUS="true"
    if [[ "$1" == "platform" && "$2" == "-s" ]]; then
        echo "$SIMULATED_STATUS"
    fi
}

DIALOG="/usr/local/bin/dialog"
ICON="/usr/local/MDMAssets/assets/arrow.up.forward.app.png"
LOGO="/usr/local/MDMAssets/assets/cp2.png"

loggedInUser=$(stat -f "%Su" /dev/console)
loggedInUID=$(id -u "$loggedInUser")

# STEP 0: Prompt user to begin registration
COMMAND_FILE="/var/tmp/dtu-register-status.json"
cat >"$COMMAND_FILE" <<EOF
{
  "title": "Register key for Touch-ID 🔐",
  "message": "Last step. Click Company Portal notification in upper right corner. Please Click Register! 👉",
  "infotext": "Videoguide available on your desktop. Kind Regards, DTU-IT support.",
  "progress": 0
}
EOF

launchctl asuser "$loggedInUID" sudo -u "$loggedInUser" "$DIALOG" \
    --commandfile "$COMMAND_FILE" \
    --height 320 \
    --width 600 \
    --moveable \
    --icon "$LOGO" &

# STEP 1: Wait 30 seconds before checking
sleep 5
ssoStatus=$(app-sso platform -s)

if [[ "$ssoStatus" == "true" ]]; then
    echo "✅ Secure Enclave registration complete (first check)."
    launchctl asuser "$loggedInUID" sudo -u "$loggedInUser" "$DIALOG" \
        --title "✅ You're all set!🔐" \
        --titlefont "Helvetica-Bold" \
        --titlealignment center \
        --message "You can now log in securely with Touch ID on this Mac. 🔐" \
        --infotext "Your DTU key has been successfully registered." \
        --height 280 \
        --width 600 \
        --moveable \
        --icon "/usr/local/MDMAssets/assets/touchid@2x.png"
    rm -f "$0"
    exit 0
fi

# STEP 2: Restart AppSSOAgent ONCE
echo "AppSSOAgent not ready — restarting once."
pkill AppSSOAgent
sleep 3
app-sso -l >/dev/null 2>&1

# STEP 3: Wait 60 seconds and check again
sleep 60
ssoStatus=$(app-sso platform -s)

if [[ "$ssoStatus" == "true" ]]; then
    echo "✅ Secure Enclave registration complete (after restart)."
    launchctl asuser "$loggedInUID" sudo -u "$loggedInUser" "$DIALOG" \
        --title "You're all set!" \
        --titlefont "Helvetica-Bold" \
        --titlealignment center \
        --message "You can now log in securely with Touch ID on this Mac. 🔐" \
        --infotext "Your DTU key has been successfully registered." \
        --height 280 \
        --width 600 \
        --moveable \
        --icon "$LOGO"
    rm -f "$0"
    exit 0
else
    echo "❌ Still not registered after retry — exiting. Will try again after reboot."
    exit 0
fi
