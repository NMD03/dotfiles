#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Wallpaper
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Create an array of all jpg, jpeg, png, webp files in the wallpaper directory
IFS=$'\n' read -d '' -r -a files < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print && printf '\0')

# Check if any files were found
if [ ${#files[@]} -eq 0 ]; then
    echo "No wallpaper files found in the directory."
    exit 1
fi

# Get the current wallpaper path
CURRENT_WALLPAPER=$(osascript -e 'tell application "System Events" to get picture of first desktop')

CURRENT_WALLPAPER=${CURRENT_WALLPAPER#file://}
CURRENT_WALLPAPER=${CURRENT_WALLPAPER#/}

# Find the index of the current wallpaper in the array
CURRENT_INDEX=-1
for i in "${!files[@]}"; do
  if [[ "${files[$i]}" == "$CURRENT_WALLPAPER" ]]; then
    CURRENT_INDEX=$i
    break
  fi
done

echo $CURRENT_WALLPAPER
echo $CURRENT_INDEX
# Determine the next index
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#files[@]} ))
echo $NEXT_INDEX

# Get path to the next wallpaper
new_wallpaper_path=${files[$NEXT_INDEX]}
/usr/libexec/PlistBuddy -c "set AllSpacesAndDisplays:Desktop:Content:Choices:0:Files:0:relative file:///$new_wallpaper_path" ~/Library/Application\ Support/com.apple.wallpaper/Store/Index.plist
killall WallpaperAgent

