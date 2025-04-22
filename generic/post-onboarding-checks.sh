#!/bin/bash

log() {
    echo "[INFO] $1"
}

# Downloads a file and shows progress as a mini dialog
DIALOG="/usr/local/bin/dialog"
ICON_COMPANYPORT_REGISTER="/usr/local/MDMAssets/assets/icon-companyportal-register.png"
ICON_CURSOR="/usr/local/MDMAssets/assets/image-macwindow.and.cursorarrow2x.png"
ICON_NOTIFICATIONS="/usr/local/MDMAssets/assets/image_notifications_cp.png"
ICON_KEY_CLOUD="/usr/local/MDMAssets/assets/icon-keycloud.png"
ICON_CHECKMARK="/usr/local/MDMAssets/assets/checkmark.seal2x.png"

CMD_FILE="/var/tmp/demo-dialog.cmd"

# Cleanup old command file
rm -f "$CMD_FILE"
touch "$CMD_FILE"

# Launch dialog in progress mode
"$DIALOG" \
    --title "Completing with Company Portal" \
    --message "Look for Company Portal notification in upper right corner, anc click register!👉" \
    --progress \
    --progresstext "Preparing setup..." \
    --width 600 \
    --height 360 \
    --ontop \
    --icon "${ICON_COMPANYPORT_REGISTER}" \
    --commandfile "$CMD_FILE" &

DIALOG_PID=$!

echo "[INFO] Dialog launched with PID: $DIALOG_PID"

# Wait until SwiftDialog is actively reading the command file
timeout=30
while ! lsof "$CMD_FILE" | grep -q "dialog"; do
    sleep 0.1
    ((timeout--))
    if [[ $timeout -le 0 ]]; then
        echo "[ERROR] Timeout waiting for SwiftDialog to start."
        break
    fi
done

sleep 3

# Check if PSSO is not completed
ssoStatus=$(app-sso platform -s)
if [[ -f /tmp/psso-registered ]]; then
    REG_COMPLETED="true"
else
    REG_COMPLETED="false"
fi

# Prompt user to click the Company Portal notification IF not already registered
if [[ "${REG_COMPLETED//$'\n'/}" != "true" ]]; then
    echo "[INFO] Displaying Company Portal notification dialog block..."
    {
        echo "title: Action Required"
        echo "message: To proceed - Please click the Company Portal notification in the top-right corner to continue setup. 🛎️"
        echo "icon: ${ICON_NOTIFICATIONS}"
        echo "progresstext: Waiting for you to click the notification..."
    } >>"$CMD_FILE"
fi

sleep 4

if [[ "${REG_COMPLETED//$'\n'/}" != "true" ]]; then

    # Still not registered after waiting. Log and update user-facing message before restarting AppSSOAgent.

    # Optional user-facing message update
    echo "title: Company Portal not yet registered..." >>"$CMD_FILE"
    echo "message: We’ll try to trigger the Company Portal notification for you — hang tight!⏳" >>"$CMD_FILE"
    echo "icon: SF=clock.arrow.circlepath" >>"$CMD_FILE"
    echo "progresstext: Rechecking..." >>"$CMD_FILE"
    #echo "progress: indeterminate" >>"$CMD_FILE"
    sleep 4

    # After sleep 4 and failed check
    app-sso -l >/dev/null 2>&1
    sleep 10
    if [[ -f /tmp/psso-registered ]]; then
        REG_COMPLETED="true"
    else
        REG_COMPLETED="false"
    fi

    log "DEBUG: Recheck file exists: $(if [[ -f /tmp/psso-registered ]]; then echo yes; else echo no; fi)"
    log "DEBUG: REG_COMPLETED value is: '$REG_COMPLETED'"

    if [[ "${REG_COMPLETED//$'\n'/}" != "true" ]]; then
        # Log and final update before quitting
        log "Still not registered after retry. User may need to register manually."

        echo "title: Still Not Registered" >>"$CMD_FILE"
        echo "message: We tried to help register this Mac, but it didn’t go through.\n\nYou can try opening Company Portal manually or contact IT for help." >>"$CMD_FILE"
        echo "icon: SF=exclamationmark.triangle" >>"$CMD_FILE"
        echo "progresstext: Registration not completed" >>"$CMD_FILE"
        sleep 6

        echo "quit:" >>"$CMD_FILE"
        exit 0
    else
        {
            echo "progress: 25"
            echo "title: Registration Confirmed"
            echo "message: Company Portal has successfully registered this Mac. Continuing setup... 🙌"
            echo "icon: ${ICON_NOTIFICATIONS}"
            echo "progresstext: Starting configuration..."
        } >>"$CMD_FILE"
    fi

fi

# Step 2: Platform SSO / Touch ID is enabled. Inform user.
echo "title: Company Portal Successfully Registered!" >>"$CMD_FILE"
echo "message: Thank you for your patience!🙌 " >>"$CMD_FILE"
echo "progresstext: Approving login configuration..." >>"$CMD_FILE"
echo "icon: ${ICON_COMPANYPORT_REGISTER}" >>"$CMD_FILE"
echo "progress: 50" >>"$CMD_FILE"

sleep 3
echo "title: Passkey for Touch ID registered!" >>"$CMD_FILE"
echo "message: This was the final setup step — simply use touch-id when using this mac!🙌 " >>"$CMD_FILE"
echo "progresstext: Verifying login configuration..." >>"$CMD_FILE"
echo "progress: 70" >>"$CMD_FILE"
echo "progresstext: Finishing setup..." >>"$CMD_FILE"
echo "icon: SF=touchid" >>"$CMD_FILE"

sleep 1

# Step 3: Success
echo "title: You're All Set!" >>"$CMD_FILE"
echo "message: This Mac now has now been fully configured!🚀" >>"$CMD_FILE"
echo "progresstext: Done" >>"$CMD_FILE"
echo "progress: complete" >>"$CMD_FILE"
echo "progresstext: Setup complete!" >>"$CMD_FILE"
echo "icon: SF=network.badge.shield.half.filled" >>"$CMD_FILE"

sleep 1
echo "quit:" >>"$CMD_FILE"
