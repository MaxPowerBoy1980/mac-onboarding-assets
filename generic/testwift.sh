#!/bin/zsh

# Basic SwiftDialog test
/usr/local/bin/dialog \
    --title "Welcome to SwiftDialog" \
    --message "You're seeing a sample SwiftDialog window.\n\nFeel free to explore customizing the interface!" \
    --icon SF=hammer.circle \
    --button1text "OK" \
    --moveable true \
    --ontop \
    --width 600 \
    --height 350
