#!/bin/bash

# Check if path to Xcode project is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 /path/to/YourProject.xcodeproj"
    exit 1
fi

# Check if the provided path ends with .xcodeproj
project_path="$1"
if [[ ! "$project_path" =~ \.xcodeproj$ ]]; then
    echo "Please provide a valid path to an Xcode project (.xcodeproj)"
    exit 1
fi

# Extracting project name without extension
project_name=$(basename "$project_path" .xcodeproj)

# Define build directory
build_dir="build"

# Define team ID and code sign identity
team_id=""
code_sign_identity="iPhone Developer"
bundle_identifier="com.yourcompany.bundleid"
provisioning_profile="Provisioning Profile Name"

# Function to fetch the bundle identifier from the project file
get_bundle_identifier() {
    bundle_identifier=$(sed -En -e 's/.*PRODUCT_BUNDLE_IDENTIFIER = ([^;]*);/\1/p' "$project_path/project.pbxproj" | head -n 1)
    echo "$bundle_identifier"
}

# Function to build IPA
build_ipa() {
    xcodebuild -project "$project_path" -scheme "$project_name" \
        -archivePath "$build_dir/$project_name.xcarchive" \
        archive \
        DEVELOPMENT_TEAM="$team_id" \
        CODE_SIGN_IDENTITY="$code_sign_identity" \
        PROVISIONING_PROFILE="$provisioning_profile" \
        PRODUCT_BUNDLE_IDENTIFIER="$bundle_identifier" \
        -destination 'generic/platform=iOS'

    xcodebuild -exportArchive -archivePath "$build_dir/$project_name.xcarchive" \
        -exportPath "$build_dir" -exportOptionsPlist "$build_dir/exportOptions.plist"
}

# Main script execution starts here

# Ensure the build directory exists
mkdir -p "$build_dir"

# Generate export options plist for IPA creation
cat << EOF > "$build_dir/exportOptions.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>debugging</string>
    <key>teamID</key>
    <string>$team_id</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>$bundle_identifier</key>
        <string>$provisioning_profile</string>
    </dict>
</dict>
</plist>
EOF

# Build IPA
build_ipa

# Notify completion
echo "IPA generated successfully at: $build_dir/$project_name.ipa"
