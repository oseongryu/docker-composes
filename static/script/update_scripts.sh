#!/bin/bash

# Base URL
BASE_URL="https://gist.githubusercontent.com/oseongryu/d50f81d8894af19821c9f2e5d9b6646b/raw"

# File containing the list of files to update
FILE_LIST="/script/update_file_list.txt"

# Target directory
TARGET_DIR="/script"


# Ensure the target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Target directory $TARGET_DIR does not exist. Creating it..."
    mkdir -p "$TARGET_DIR"
fi

# Ensure the file list exists
if [ ! -f "$FILE_LIST" ]; then
    echo "Error: File list $FILE_LIST does not exist. Please create it and try again."
    exit 1
fi

# Download and update each file
while IFS= read -r FILE; do
    echo "Updating $FILE..."
    curl -fsSL "${BASE_URL}/${FILE}" -o "${TARGET_DIR}/${FILE}"
    if [ $? -eq 0 ]; then
        echo "$FILE updated successfully."
    else
        echo "Failed to update $FILE."
    fi
done < "$FILE_LIST"

echo "All files updated."