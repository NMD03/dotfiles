#!/bin/bash

DOTFILES_DIR="."
XDG_CONFIG_HOME="$HOME/.config"

# --- Import Helper Functions ---
source ./helper.sh

# --- Create config dir ---
mkdir -p "$XDG_CONFIG_HOME"

# --- Different Operations based on OS ---
# MacOS
if [ "$(uname)" == "Darwin" ]; then
  # Run MacOS installation script
  ./OS/MacOS/macos_install.sh
# Ubuntu
elif [ "$(lsb_release -i 2>/dev/null | cut -f 2)" == "Ubuntu" ]; then
  # Run Ubuntu installation script
  ./OS/Linux/ubuntu/ubuntu_install.sh
# Arch
elif [ "$(lsb_release -i 2>/dev/null | cut -f 2)" == "Arch" ]; then
  # Run Arch installation script
  ./OS/Linux/arch/arch_install.sh
else
  error "OS is not supported"
fi

# --- Install Software on System ---
ansible-playbook --ask-become-pass setup.yml

# --- Create symlinks for config files using stow ---

stow_config_directory="dot-config"
stow_home_directory="home-dir"

## Function to handle conflicts and convert dot- to .
handle_conflicts() {
  local stow_dir="$1"
  local target_dir="$2"
  # Handle both files and directories within stow_dir
  for item_path in $(find $stow_dir -type f -or -type d); do
    local item=$(basename "$item_path")
    local target_item="${item/dot-/.}" # Replace 'dot-' with '.' for target item

    if [[ -e "$target_dir/$target_item" ]]; then
      # Rename the conflicting item in the target directory
      mv "$target_dir/$target_item" "$target_dir/$target_item.bak"
      info "Renamed $target_item to $target_item.bak to resolve conflict."
    fi
  done
}

# Resolve conflicts by renaming existing files in the target directories
handle_conflicts "$DOTFILES_DIR/$stow_config_directory" "$XDG_CONFIG_HOME"
handle_conflicts "$DOTFILES_DIR/$stow_home_directory" "$HOME"

stow -v --dotfiles $stow_config_directory -t $XDG_CONFIG_HOME
stow -v --dotfiles $stow_home_directory -t $HOME
