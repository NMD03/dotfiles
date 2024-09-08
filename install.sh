#!/bin/bash

DOTFILES_DIR="."
XDG_CONFIG_HOME="$HOME/.config"

# --- Helper Functions ---
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Debug output
info() {
  local msg=$1
  echo -e "${BLUE}Info: $msg${NC}" >/dev/tty
}

error() {
  local msg=$1
  echo -e "${RED}Error: $msg${NC}" >/dev/tty
}

warn() {
  local msg=$1
  echo -e "${YELLOW}Warning: $msg${NC}" >/dev/tty
}

success() {
  local msg=$1
  echo -e "${GREEN}Success: $msg${NC}" >/dev/tty
}

# --- Create config dir ---
mkdir -p "$XDG_CONFIG_HOME"

# --- Different Operations based on OS ---
# MacOS
if [ "$(uname)" == "Darwin" ]; then
  # Run macOS installation script
  ./OS/MacOS/macos_install.sh
# Linux
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  # Linux specific commands
  echo "message"
fi

# --- Install Software on System ---
ansible-playbook --ask-become-pass setup.yml

# --- Create symlinks for config files using stow ---

stow_config_directory="dot-config"
stow_home_directory="home-dir"

# Function to handle conflicts and convert dot- to .
handle_conflicts() {
  local stow_dir="$1"
  local target_dir="$2"
  for file_path in $(find $stow_dir -type f); do
    local file=$(basename $file_path)
    local target_file="${file/dot-/.}" # Replace 'dot-' with '.' for target file
    if [[ -e "$target_dir/$target_file" ]]; then
      # Rename the conflicting file in the target directory
      mv "$target_dir/$target_file" "$target_dir/$target_file.bak"
      info "Renamed $target_file to $target_file.bak to resolve conflict."
    fi
  done
}

# Resolve conflicts by renaming existing files in the target directories
handle_conflicts "$DOTFILES_DIR/$stow_config_directory" "$XDG_CONFIG_HOME"
handle_conflicts "$DOTFILES_DIR/$stow_home_directory" "$HOME"

stow -v --dotfiles $stow_config_directory -t $config_directory
stow -v --dotfiles $stow_home_directory -t $home_dir
