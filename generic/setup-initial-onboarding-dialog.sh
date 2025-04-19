#!/bin/zsh

LOG_PATH="/Users/Shared/MDM-Core/logs/onboarding.log"
POST_SCRIPT="/Users/Shared/MDM-Core/Scripts/post-onboarding.sh"
POST_URL="https://your-repo-url.example.com/post-onboarding.sh"

mkdir -p "$(dirname "$LOG_PATH")"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >>"$LOG_PATH"
}
download_assets() {
    BASE_URL="https://raw.githubusercontent.com/MaxPowerBoy1980/mac-onboarding-assets/main/dtu"
    MANIFEST_URL="$BASE_URL/asset-list.txt"
    TEMP_MANIFEST="/tmp/dtu-asset-list.txt"

    log "[DOWNLOAD] Fetching asset manifest from $MANIFEST_URL"
    echo "[DOWNLOAD] Fetching asset manifest from $MANIFEST_URL"

    if curl -fsSL "$MANIFEST_URL" -o "$TEMP_MANIFEST"; then
        log "[DOWNLOAD] Manifest downloaded to $TEMP_MANIFEST"
    else
        log "[ERROR] Failed to download asset-list.txt"
        echo "[ERROR] Failed to download asset-list.txt"
        return 1
    fi

    while IFS= read -r line || [ -n "$line" ]; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue # Skip comments and blank lines

        src="$line"
        dest="/usr/local/MDM/assets/${src#*/}" # Drop 'scripts/', 'assets/', etc.
        dest_dir="$(dirname "$dest")"
        mkdir -p "$dest_dir"

        log "[DOWNLOAD] $src → $dest"
        echo "[DOWNLOAD] $src → $dest"

        if curl -fsSL "$BASE_URL/$src" -o "$dest"; then
            chmod +x "$dest" 2>/dev/null
            log "[SUCCESS] Downloaded $src"
        else
            log "[ERROR] Failed to download $src"
            echo "[ERROR] Failed to download $src"
        fi
    done <"$TEMP_MANIFEST"

    rm -f "$TEMP_MANIFEST"
}

log "[START] DTU onboarding script running."

OS_VERSION=$(sw_vers -productVersion)
USER_FIRSTNAME=$(id -F | awk '{print $1}')
DEVICE_NAME="DTU-MacBook-${USER_FIRSTNAME}"

# Updated timeout durations for testing
TIMEOUT_SHORT=3

# Merged Dialog: Welcome and Identity Info
log "[DIALOG 1] Showing welcome + identity screen"
echo "[DIALOG 1] Showing welcome + identity screen"
/usr/local/bin/dialog \
    --title "DTU Mac Setup" \
    --icon SF=lock.shield \
    --appearance light \
    --message "**Welcome! Your DTU Mac is being set up.**

 🔐 Security and login features  
 🧷 FileVault, VPN, Touch ID  
 🧬 SSO + Sikker Digital Compliance  
 🧪 macOS: $OS_VERSION  
 🏷️ Name: $DEVICE_NAME" \
    --blurscreen \
    --ontop \
    --button1text "Continue"

# Step 2: Set Computer Name
log "[STEP 1] Setting device name to $DEVICE_NAME"
echo "[STEP 1] Setting device name to $DEVICE_NAME"
scutil --set ComputerName "$DEVICE_NAME"
scutil --set HostName "$DEVICE_NAME"
log "[INFO] Device name set."

# Step 4: Download Post-Onboarding Script
log "[STEP 3] Downloading post-onboarding script from $POST_URL"
echo "[STEP 3] Downloading post-onboarding script from $POST_URL"
if curl -fsSL "$POST_URL" -o "$POST_SCRIPT"; then
    chmod +x "$POST_SCRIPT"
    log "[SUCCESS] Post-onboarding script downloaded."
    echo "[SUCCESS] Post-onboarding script downloaded."
else
    log "[ERROR] Failed to download post-onboarding script."
    echo "[ERROR] Failed to download post-onboarding script."
fi

# Call download_assets to fetch required assets before starting the progress dialog
download_assets
# Step 5: Show progress dialog with task-specific updates
CMD_FILE="/var/tmp/dtu-onboarding-progress"
rm -f "$CMD_FILE"
touch "$CMD_FILE"

log "[DIALOG 2] Showing progress status"
/usr/local/bin/dialog \
    --title "Finalizing Setup" \
    --icon SF=gear \
    --appearance light \
    --message "**Finalizing your Mac's configuration.**" \
    --infotext "Initializing..." \
    --progress \
    --blurscreen \
    --ontop \
    --commandfile "$CMD_FILE" &

DIALOG_PID=$!

# Custom tasks and SF symbols per step
declare -a TASKS=(
    "Downloading assets::Fetching required images, icons, and scripts::arrow.down.circle"
    "Building local profile::Creating user environment and preferences::person.crop.circle"
    "Applying DTU configuration::Installing settings, security and compliance profiles::slider.horizontal.3"
    "Configuring Touch ID login::Enabling secure, passwordless access using PSSO::touchid"
    "Cleaning up and finalizing::Tidying up temporary files and preparing for use::checkmark.seal"
)

i=1
for task in "${TASKS[@]}"; do
    title="${task%%::*}"
    remainder="${task#*::}"
    description="${remainder%%::*}"
    icon="${remainder##*::}"
    progress=$((i * 20))

    echo "message: $title" >>"$CMD_FILE"
    echo "progresstext: $description" >>"$CMD_FILE"
    echo "progress: $progress" >>"$CMD_FILE"
    echo "icon: SF=$icon" >>"$CMD_FILE"

    log "[DIALOG 2] Step $i – $title"
    echo "[DIALOG 2] Step $i – $title"
    sleep 1
    ((i++))
done

echo "progresstext: Setup complete – Welcome to DTU!" >>"$CMD_FILE"
echo "progress: 100" >>"$CMD_FILE"
sleep 1
kill "$DIALOG_PID" 2>/dev/null
rm -f "$CMD_FILE"

log "[COMPLETE] Onboarding flow finished"
echo "[COMPLETE] Onboarding flow finished."
