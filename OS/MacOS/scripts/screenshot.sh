#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Screenshot
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

current_date=$(date +"%Y-%m-%d_%H-%M-%S")
file_path=~/Pictures/screenshots/screenshot_$current_date.png
screencapture -i "$file_path"
osascript -e "set the clipboard to (read (POSIX file \"$file_path\") as TIFF picture)"
