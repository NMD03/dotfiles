#!/bin/bash

DOTFILES_DIR="."
XDG_CONFIG_HOME="$HOME/.config"
ETC="/etc"

# --- Import Helper Functions ---
source ./helper.sh

# --- Create config dir ---
mkdir -p "$XDG_CONFIG_HOME"

# --- Different Operations based on OS ---
# MacOS
if [ "$(uname)" == "Darwin" ]; then
  # Run MacOS installation script
  chmod +x ./OS/MacOS/macos_install.sh
  ./OS/MacOS/macos_install.sh
# Ubuntu
elif [ "$(lsb_release -i 2>/dev/null | cut -f 2)" == "Ubuntu" ]; then
  # Run Ubuntu installation script
  chmod +x ./OS/Linux/ubuntu/ubuntu_install.sh
  ./OS/Linux/ubuntu/ubuntu_install.sh
# Arch
elif [ "$(lsb_release -i 2>/dev/null | cut -f 2)" == "Arch" ]; then
  # Run Arch installation script
  chmod +x ./OS/Linux/arch/arch_install.sh
  ./OS/Linux/arch/arch_install.sh
else
  error "OS is not supported"
fi

# --- Install Software on System ---
ansible-playbook --ask-become-pass setup.yml

# --- Create symlinks for config files using stow ---
stow_config_directory="CONFIG"
stow_home_directory="HOME"
stow_etc_directory="ETC"
# MacOS
macos_stow_config_directory="./OS/MacOS/CONFIG"
macos_stow_home_directory="./OS/MacOS/HOME"
macos_stow_etc_directory="./OS/MacOS/ETC"
# Ubuntu
ubuntu_stow_config_directory="./OS/Linux/ubuntu/CONFIG"
ubuntu_stow_home_directory="./OS/Linux/ubuntu/HOME"
ubuntu_stow_etc_directory="./OS/Linux/ubuntu/ETC"
# Arch
arch_stow_config_directory="./OS/Linux/arch/CONFIG"
arch_stow_home_directory="./OS/Linux/arch/HOME"
arch_stow_etc_directory="./OS/Linux/arch/ETC"
# Linux
linux_stow_config_directory="./OS/Linux/CONFIG"
linux_stow_home_directory="./OS/Linux/HOME"
linux_stow_etc_directory="./OS/Linux/ETC"

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
handle_conflicts "$DOTFILES_DIR/$stow_etc_directory" "$ETC"

# MacOS
if [ "$(uname)" == "Darwin" ]; then
  handle_conflicts "$DOTFILES_DIR/$macos_stow_config_directory" "$XDG_CONFIG_HOME"
  handle_conflicts "$DOTFILES_DIR/$macos_stow_home_directory" "$HOME"
  handle_conflicts "$DOTFILES_DIR/$macos_stow_etc_directory" "$ETC"
# Ubuntu
elif [ "$(lsb_release -i 2>/dev/null | cut -f 2)" == "Ubuntu" ]; then
  handle_conflicts "$DOTFILES_DIR/$ubuntu_stow_config_directory" "$XDG_CONFIG_HOME"
  handle_conflicts "$DOTFILES_DIR/$ubuntu_stow_home_directory" "$HOME"
  handle_conflicts "$DOTFILES_DIR/$ubuntu_stow_etc_directory" "$ETC"
  handle_conflicts "$DOTFILES_DIR/$linux_stow_config_directory" "$XDG_CONFIG_HOME"
  handle_conflicts "$DOTFILES_DIR/$linux_stow_home_directory" "$HOME"
  handle_conflicts "$DOTFILES_DIR/$linux_stow_etc_directory" "$ETC"
# Arch
elif [ "$(lsb_release -i 2>/dev/null | cut -f 2)" == "Arch" ]; then
  handle_conflicts "$DOTFILES_DIR/$arch_stow_config_directory" "$XDG_CONFIG_HOME"
  handle_conflicts "$DOTFILES_DIR/$arch_stow_home_directory" "$HOME"
  handle_conflicts "$DOTFILES_DIR/$arch_stow_etc_directory" "$ETC"
  handle_conflicts "$DOTFILES_DIR/$linux_stow_config_directory" "$XDG_CONFIG_HOME"
  handle_conflicts "$DOTFILES_DIR/$linux_stow_home_directory" "$HOME"
  handle_conflicts "$DOTFILES_DIR/$linux_stow_etc_directory" "$ETC"
fi

make

