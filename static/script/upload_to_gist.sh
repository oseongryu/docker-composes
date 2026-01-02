#!/bin/bash

# GitHub Personal Access Token (환경 변수에서 가져옴)
# zshrc에 export GITHUB_TOKEN='your_token' 형태로 설정 필요
# GitHub Settings > Developer settings > Personal access tokens에서 생성
# gist 권한 필요

# Gist ID (기존 gist를 업데이트하는 경우)
GIST_ID="d50f81d8894af19821c9f2e5d9b6646b"

# File containing the list of files to upload
FILE_LIST="../script/update_file_list.txt"

# Source directory
SOURCE_DIR="../script"

# Ensure the file list exists
if [ ! -f "$FILE_LIST" ]; then
    echo "Error: File list $FILE_LIST does not exist. Please create it and try again."
    exit 1
fi

# Check if token is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable is not set."
    echo "Please add to your ~/.zshrc: export GITHUB_TOKEN='your_token_here'"
    echo "Then run: source ~/.zshrc"
    exit 1
fi

# Build JSON payload
echo "Building JSON payload..."
JSON_CONTENT='{"files":{'

FIRST=true
while IFS= read -r FILE; do
    FILE_PATH="${SOURCE_DIR}/${FILE}"

    if [ ! -f "$FILE_PATH" ]; then
        echo "Warning: $FILE_PATH does not exist. Skipping..."
        continue
    fi

    echo "Adding $FILE to payload..."

    # Read file content and escape for JSON
    CONTENT=$(jq -Rs . < "$FILE_PATH")

    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        JSON_CONTENT="${JSON_CONTENT},"
    fi

    JSON_CONTENT="${JSON_CONTENT}\"${FILE}\":{\"content\":${CONTENT}}"
done < "$FILE_LIST"

JSON_CONTENT="${JSON_CONTENT}}}"

# Upload to gist
echo "Uploading to gist..."
RESPONSE=$(curl -s -X PATCH \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/gists/$GIST_ID" \
    -d "$JSON_CONTENT")

# Check if upload was successful
if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
    echo "✓ Successfully uploaded to gist!"
    echo "Gist URL: $(echo "$RESPONSE" | jq -r '.html_url')"
else
    echo "✗ Failed to upload to gist."
    echo "Response: $RESPONSE"
    exit 1
fi

echo "All files uploaded successfully."
