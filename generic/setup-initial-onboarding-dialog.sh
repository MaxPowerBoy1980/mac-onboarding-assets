#!/bin/zsh

echo "✅ Running: /Users/Shared/Mac-Projects/PlayGround/SwiftDialog/testwift.sh"

echo "Shell: $SHELL"
echo "User: $(whoami)"
echo "Terminal: $TERM"
echo "PATH: $PATH"

# Create temporary command file
command_file="/var/tmp/dialog_command.log"
: >"$command_file" # Clear it

# Launch SwiftDialog with command file
/usr/local/bin/dialog \
    --title "Setting up..." \
    --message "Preparing your Mac..." \
    --icon SF=gearshape \
    --commandfile "$command_file" \
    --button1text "Close" \
    --progress \
    --moveable true \
    --ontop \
    --width 600 \
    --height 350 & #Launch in background
sleeo 1
# Simulate task progress
sleep 1
echo "progress: 25" >>"$command_file"
echo "message: Installing essentials..." >>"$command_file"
echo "Step 1 complete" | tee -a ~/test-lab.log
sleep 1
echo "progress: 60" >>"$command_file"
echo "message: Configuring system..." >>"$command_file"
sleep 1
echo "progress: 100" >>"$command_file"
echo "message: Complete!" >>"$command_file"
