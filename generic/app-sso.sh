#!/bin/bash

if [[ "$1" == "platform" && "$2" == "-s" ]]; then
    if [[ -f /tmp/psso-registered ]]; then
        echo "PlatformSSO is registered"
    else
        echo "PlatformSSO is not registered"
    fi
    exit 0

elif [[ "$1" == "-l" ]]; then
    echo "Triggering registration flow..."
    touch /tmp/psso-registered
    exit 0
fi
