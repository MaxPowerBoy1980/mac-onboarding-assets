#!/bin/zsh

#############################################
# logging.sh
# Provides simple and unified logging functionality
#############################################

# ✏️ SETTINGS
LOG_FILE="/Library/Logs/Microsoft/IntuneScripts/mdm-onboarding.log"

# 🔥 General log function
log() {
    local TIMESTAMP
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] [INFO] : $1" | tee -a "$LOG_FILE"
}

# ⚠️ Warning log
log_warning() {
    local TIMESTAMP
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] [WARNING] : $1" | tee -a "$LOG_FILE"
}

# ❌ Error log
log_error() {
    local TIMESTAMP
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] [ERROR] : $1" | tee -a "$LOG_FILE"
}
