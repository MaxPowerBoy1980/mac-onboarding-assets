#!/bin/zsh

LOGFILE="/var/log/dtu_post_onboarding.log"
exec > >(tee -a "$LOGFILE") 2>&1
echo "---- Script started at $(date) ----"

echo "✅ Running: onboarding script"

echo "Shell: $SHELL"
echo "User: $(whoami)"
echo "Terminal: $TERM"
echo "PATH: $PATH"

logged_in_user=$(stat -f "%Su" /dev/console)
user_name=$(dscl . -read /Users/"$logged_in_user" RealName | tail -1)
first_name=$(echo "$user_name" | awk '{print $1}')
echo "👋 Hello, $user_name!"

# Get model and serial
model_id=$(sysctl -n hw.model)
serial_number=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')

# Construct personalized name
new_device_name="${first_name}-DTU-IT-${model_id}-${serial_number}"
echo "📛 Setting system names to: $new_device_name"

# Set all system name types
scutil --set ComputerName "$new_device_name"
scutil --set HostName "$new_device_name"
scutil --set LocalHostName "$(echo "$new_device_name" | tr '[:upper:]' '[:lower:]' | tr -d ',')"

# Create temporary command file
command_file=$(mktemp /var/tmp/dialog_command.XXXXXX)
chown "$logged_in_user" "$command_file"
: >"$command_file" # Clear it

sleep 4

# Launch SwiftDialog with command file
/usr/local/bin/dialog \
    --title "Welcome to DTU, post-onboarding!" \
    --message "DIALOG1" \
    --icon SF=macbook \
    --commandfile "$command_file" \
    --timer 5 \
    --hidetimerbar \
    --quitoninfo \
    --progress \
    --moveable true \
    --ontop \
    --width 600 \
    --height 350 & #Launch in background

# Launch SwiftDialog with command file
/usr/local/bin/dialog \
    --title "DIALOG12 $first_name!" \
    --message "We are done!." \
    --icon SF=macbook \
    --commandfile "$command_file" \
    --timer 5 \
    --hidetimerbar \
    --quitoninfo \
    --progress \
    --moveable true \
    --ontop \
    --width 600 \
    --height 350 & #Launch in background
sleep 5

echo "---- Script ended at $(date) ----"
