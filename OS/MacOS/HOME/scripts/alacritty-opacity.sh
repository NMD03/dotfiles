#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle alacritty opacity
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description toggles the opacity of the Alacritty terminal

CONFIG=~/.config/alacritty/alacritty.toml
LOW_OPACITY="opacity = 0.8"
HIGH_OPACITY="opacity = 1.0"
CURRENT_OPACITY=$(grep "opacity" $CONFIG)

if [ "$CURRENT_OPACITY" == "$HIGH_OPACITY" ]; then
  sed -i '' "s/$HIGH_OPACITY/$LOW_OPACITY/" $CONFIG
else
  sed -i '' "s/$LOW_OPACITY/$HIGH_OPACITY/" $CONFIG
fi

# Reload Alacritty with new settings
osascript -e 'tell application "Alacritty" to activate'

