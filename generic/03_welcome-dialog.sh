#!/bin/zsh

#############################################
# 03_welcome-dialog.sh
# Welcome message with progress during onboarding
#############################################

# 🔹 Settings
LOGFILE="/Library/Logs/Microsoft/IntuneScripts/mdm-baseline.log"

# 🧑‍💻 Get current user and OS version
current_user=$(stat -f%Su /dev/console)
os_version=$(sw_vers -productVersion)

# 📝 Load shared logging module
if [ -f "/usr/local/MDMAssets/Scripts/logging.sh" ]; then
    source "/usr/local/MDMAssets/Scripts/logging.sh"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] logging.sh not found! Exiting." | tee -a "$LOGFILE"
    exit 1
fi

log "🔹 Script started for user $current_user on macOS $os_version."

# ✅ Verify SwiftDialog exists
if [ ! -x "/usr/local/bin/dialog" ]; then
    log "❌ SwiftDialog not found! Exiting."
    exit 1
fi

# 🚀 Create SwiftDialog command file
cmdfile="/var/tmp/welcome_progress.dialog"
rm -f "$cmdfile" # Ensure clean start

cat <<EOF >"$cmdfile"
progress: 0
title: "Velkommen, $current_user!"
message: "Din Mac kører macOS $os_version.\n\nVi forbereder alt til en sikker opsætning. 🚀"
progresstext: "Starter forberedelse..."
EOF

log "🛠 Created command file for SwiftDialog."

# 📺 Launch SwiftDialog
/usr/local/bin/dialog --commandfile "$cmdfile" --ontop --position center --width 600 &
dialog_pid=$!
sleep 1 # Give dialog a second to launch
log "🖥 SwiftDialog launched with PID $dialog_pid."

# 🔄 Simulate progress over 5 seconds
for i in {1..5}; do
    sleep 1
    progress=$((i * 20))
    echo "progress: $progress" >>"$cmdfile"
    echo "progresstext: \"Installerer komponenter... ($progress%)\"" >>"$cmdfile"
    log "Progress updated to $progress%."
done

# 🛑 Close SwiftDialog
sleep 1
echo "quit:" >>"$cmdfile"
log "✅ Welcome dialog completed and closed."

exit 0
