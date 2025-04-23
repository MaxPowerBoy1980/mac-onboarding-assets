#!/bin/zsh

LOGFILE="/Users/Shared/dtu_post_onboarding.log"
exec > >(tee -a "$LOGFILE") 2>&1
echo "Running as user: $(whoami)"
id
echo "---- Script started at $(date) ----"

echo "✅ Running: post-onboarding script"

echo "Shell: $SHELL"
echo "User: $(whoami)"
echo "Terminal: $TERM"
echo "PATH: $PATH"

# logged_in_user=$(stat -f "%Su" /dev/console)
# user_name=$(dscl . -read /Users/"$logged_in_user" RealName | tail -1)
# first_name=$(echo "$user_name" | awk '{print $1}')
# echo "👋 Hello, $user_name!"

# Get model and serial
# model_id=$(sysctl -n hw.model)
# serial_number=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')

# Construct personalized name
# new_device_name="${first_name}-DTU-IT-${model_id}-${serial_number}"
# echo "📛 Setting system names to: $new_device_name"

# Create temporary command file
# command_file=$(mktemp /var/tmp/dialog_command.XXXXXX)
# chown "$logged_in_user" "$command_file"
# : >"$command_file" # Clear it

sleep 4
sleep 10

echo "---- Script ended at $(date) ----"

exit 0
