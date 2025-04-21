#!/bin/bash
DIALOG="/usr/local/bin/dialog"
ICON="/usr/local/MDMAssets/assets/arrow.up.forward.app.png"
LOGO="/usr/local/MDMAssets/assets/cp2.png"

loggedInUser=$(stat -f "%Su" /dev/console)
loggedInUID=$(id -u "$loggedInUser")

launchctl asuser "$loggedInUID" sudo -u "$loggedInUser" "$DIALOG" \
    --title "Register key for Touch-ID 🔐" \
    --titlefont "Helvetica-Bold" \
    --titlealignment center \
    --message "Last step. Click Company Portal notification in upper right corner. Please Click Register! 👉" \
    --infotext "Videoguide available on your desktop. Kind Regards, DTU-IT support." \
    --height 320 \
    --width 600 \
    --moveable \
    --progress \
    --icon "$LOGO"
