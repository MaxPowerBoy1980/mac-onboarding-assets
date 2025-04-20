#!/bin/zsh

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

# Launch SwiftDialog with command file
/usr/local/bin/dialog \
    --title "Welcome, $first_name" \
    --message "We're getting things ready for you..." \
    --icon SF=gearshape \
    --commandfile "$command_file" \
    --button1text "Close" \
    --progress \
    --moveable true \
    --ontop \
    --width 600 \
    --height 350 & #Launch in background
sleep 1
# Simulate task progress
sleep 1
echo "progress: 25" >>"$command_file"
echo "message: Installing essentials..." >>"$command_file"
echo "Step 1 complete" | tee -a ~/test-lab.log
sleep 1
echo "progress: 60" >>"$command_file"
echo "message: Configuring system..." >>"$command_file"
sleep 1
echo "title: Downloading Assets" >>"$command_file"
echo "message: Fetching required files to /Users/Shared/MDM-Core/Assets..." >>"$command_file"
echo "progress: 80" >>"$command_file"
sleep 1
echo "title: Setup Complete" >>"$command_file"
echo "message: All configurations and assets are ready. You're good to go!" >>"$command_file"
echo "progress: 100" >>"$command_file"
