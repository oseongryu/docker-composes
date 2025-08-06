#!/bin/bash

# Base URL
BASE_URL="https://gist.githubusercontent.com/oseongryu/d50f81d8894af19821c9f2e5d9b6646b/raw"

# List of files to update
FILES=(
    "app_android_studio.sh"
    "app_brave_browser.sh"
    "app_chrome.sh"
    "app_intellij.sh"
    "app_opera.sh"
    "app_vscode.sh"
    "app_warp.sh"
    "init_chrome.sh"
    "init_env_nvm.sh"
    "init_korean.sh"
    "init_timezone.sh"
    "init_user.sh"
    "python_automation.sh"
    "python_shorts.sh"
)

# Target directory
TARGET_DIR="/script"

# Ensure the target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Target directory $TARGET_DIR does not exist. Creating it..."
    mkdir -p "$TARGET_DIR"
fi

# Download and update each file
for FILE in "${FILES[@]}"; do
    echo "Updating $FILE..."
    curl -fsSL "${BASE_URL}/${FILE}" -o "${TARGET_DIR}/${FILE}"
    if [ $? -eq 0 ]; then
        echo "$FILE updated successfully."
    else
        echo "Failed to update $FILE."
    fi
done

echo "All files updated."