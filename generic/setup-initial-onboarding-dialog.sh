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
    --title "Welcome to DTU, $first_name!" \
    --message "Setting things up and downloading a few essential files. Hang tight — this won’t take long." \
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
sleep 1

# Begin background asset download
{
    ASSET_BASE_URL="https://raw.githubusercontent.com/MaxPowerBoy1980/mac-onboarding-assets/main/dtu"
    ASSET_TARGET_DIR="/usr/local/MDMAssets"
    ASSET_LIST_URL="$ASSET_BASE_URL/asset-list.txt"

    mkdir -p "$ASSET_TARGET_DIR"

    curl -s "$ASSET_LIST_URL" | while read -r line; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        file_url="$ASSET_BASE_URL/$line"
        target_path="$ASSET_TARGET_DIR/$line"
        mkdir -p "$(dirname "$target_path")"
        echo "📥 Downloading $line"
        curl -s -o "$target_path" "$file_url"
    done
} &

# Simulate task progress
sleep 1
echo "progress: 10" >>"$command_file"
echo -e "title: 1. Preparing Your Mac" >>"$command_file"
echo "message: Downloading setup files to /usr/local/MDMAssets. Just a moment." >>"$command_file"
echo "icon: SF=arrow.down.circle" >>"$command_file"
sleep 1

echo "progress: 40" >>"$command_file"
echo -e "title: 2. Installing Required Apps" >>"$command_file"
echo "message: In a few minutes we wil be installing required apps in the background. No action needed." >>"$command_file"
echo "icon: SF=gearshape.2" >>"$command_file"
sleep 1

echo "progress: 70" >>"$command_file"
echo -e "title: 3. Final Configuration" >>"$command_file"
echo "message: Applying final system settings. Almost there..." >>"$command_file"
echo "icon: SF=checkmark.seal" >>"$command_file"
sleep 1

echo "progress: 100" >>"$command_file"
echo -e "title: 4. Sign In to Finish" >>"$command_file"
echo "message: Please sign in to Company Portal to complete your setup. And you're all set." >>"$command_file"
echo "icon: SF=person.crop.circle.badge.checkmark" >>"$command_file"
wait
echo "✅ All files downloaded. Ready to proceed."
