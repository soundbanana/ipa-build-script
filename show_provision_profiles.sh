#!/bin/bash

# Path to the mobile provisioning profiles
profile_path="$HOME/Library/MobileDevice/Provisioning Profiles"

# Check if the directory exists
if [ ! -d "$profile_path" ]; then
    echo "Provisioning Profiles directory not found at $profile_path"
    exit 1
fi

# Iterate through the profiles and print their names
for profile in "$profile_path"/*.mobileprovision; do
    if [ -f "$profile" ]; then
        name=$(security cms -D -i "$profile" | plutil -extract Name xml1 -o - - | plutil -p - | awk -F'"' '/^"/{print $2}')
        uuid=$(security cms -D -i "$profile" | plutil -extract UUID xml1 -o - - | plutil -p - | awk -F'"' '/^"/{print $2}')
        echo "Provisioning Profile: $name"
        echo "UUID: $uuid"
        echo "Path: $profile"
        echo "-------------------------------"
    fi
done
