#!/bin/zsh

log_msg() {
    echo "[POST-ONBOARDING] $1"
    echo "[POST-ONBOARDING] $1" >>/tmp/script2-fallback.log
}

log_msg "Script2.sh started as $(whoami) at $(date)"

log_msg "Running as user: $(whoami)"
id
log_msg "---- Script started at $(date) ----"
log_msg "✅ Running: post-onboarding script"
log_msg "Shell: $SHELL"
log_msg "User: $(whoami)"
log_msg "Terminal: $TERM"
log_msg "PATH: $PATH"

logged_in_user=$(stat -f "%Su" /dev/console)
log_msg "Detected logged-in user: $logged_in_user"
user_name=$(dscl . -read /Users/"$logged_in_user" RealName | tail -1)
log_msg "User full name: $user_name"
first_name=$(echo "$user_name" | awk '{print $1}')
log_msg "👋 Hello, $user_name!"

# Get model and serial
model_id=$(sysctl -n hw.model)
serial_number=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')

log_msg "Script2.sh finished at $(date)"
