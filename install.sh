#!/bin/bash

DOTFILES_DIR="."
XDG_CONFIG_HOME="$HOME/.config"
ETC="/etc"

# --- Import Helper Functions ---
source ./helper.sh

# --- Create config dir ---
mkdir -p "$XDG_CONFIG_HOME"

# --- Detect OS ---
OS_ID="$(source /etc/os-release && echo "$ID")"

# --- Different Operations based on OS ---
if [ "$(uname)" == "Darwin" ]; then
  # MacOS
  chmod +x ./OS/MacOS/macos_install.sh
  ./OS/MacOS/macos_install.sh
elif [ "$OS_ID" == "ubuntu" ]; then
  chmod +x ./OS/Linux/ubuntu/ubuntu_install.sh
  ./OS/Linux/ubuntu/ubuntu_install.sh
elif [ "$OS_ID" == "arch" ]; then
  chmod +x ./OS/Linux/arch/arch_install.sh
  ./OS/Linux/arch/arch_install.sh
elif [ "$OS_ID" == "fedora" ]; then
  chmod +x ./OS/Linux/fedora/fedora_install.sh
  ./OS/Linux/fedora/fedora_install.sh
else
  error "OS is not supported"
  exit 1
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

# Fedora
fedora_stow_config_directory="./OS/Linux/fedora/CONFIG"
fedora_stow_home_directory="./OS/Linux/fedora/HOME"
fedora_stow_etc_directory="./OS/Linux/fedora/ETC"

# Linux generic
linux_stow_config_directory="./OS/Linux/CONFIG"
linux_stow_home_directory="./OS/Linux/HOME"
linux_stow_etc_directory="./OS/Linux/ETC"

# --- Conflict Handling Function ---
handle_conflicts() {
  local stow_dir="$1"
  local target_dir="$2"
  for item_path in $(find "$stow_dir" -type f -or -type d); do
    local item=$(basename "$item_path")
    local target_item="${item/dot-/.}"  # Replace 'dot-' with '.'

    if [[ -e "$target_dir/$target_item" ]]; then
      mv "$target_dir/$target_item" "$target_dir/$target_item.bak"
      info "Renamed $target_item to $target_item.bak to resolve conflict."
    fi
  done
}

# --- Resolve conflicts for generic configs ---
handle_conflicts "$DOTFILES_DIR/$stow_config_directory" "$XDG_CONFIG_HOME"
handle_conflicts "$DOTFILES_DIR/$stow_home_directory" "$HOME"
handle_conflicts "$DOTFILES_DIR/$stow_etc_directory" "$ETC"

# --- OS-specific conflict resolution ---
if [ "$(uname)" == "Darwin" ]; then
  handle_conflicts "$DOTFILES_DIR/$macos_stow_config_directory" "$XDG_CONFIG_HOME"
  handle_conflicts "$DOTFILES_DIR/$macos_stow_home_directory" "$HOME"
  handle_conflicts "$DOTFILES_DIR/$macos_stow_etc_directory" "$ETC"

elif [ "$OS_ID" == "ubuntu" ]; then
  handle_conflicts "$DOTFILES_DIR/$ubuntu_stow_config_directory" "$XDG_CONFIG_HOME"
  handle_conflicts "$DOTFILES_DIR/$ubuntu_stow_home_directory" "$HOME"
  handle_conflicts "$DOTFILES_DIR/$ubuntu_stow_etc_directory" "$ETC"
  handle_conflicts "$DOTFILES_DIR/$linux_stow_config_directory" "$XDG_CONFIG_HOME"
  handle_conflicts "$DOTFILES_DIR/$linux_stow_home_directory" "$HOME"
  handle_conflicts "$DOTFILES_DIR/$linux_stow_etc_directory" "$ETC"

elif [ "$OS_ID" == "arch" ]; then
  handle_conflicts "$DOTFILES_DIR/$arch_stow_config_directory" "$XDG_CONFIG_HOME"
  handle_conflicts "$DOTFILES_DIR/$arch_stow_home_directory" "$HOME"
  handle_conflicts "$DOTFILES_DIR/$arch_stow_etc_directory" "$ETC"
  handle_conflicts "$DOTFILES_DIR/$linux_stow_config_directory" "$XDG_CONFIG_HOME"
  handle_conflicts "$DOTFILES_DIR/$linux_stow_home_directory" "$HOME"
  handle_conflicts "$DOTFILES_DIR/$linux_stow_etc_directory" "$ETC"

elif [ "$OS_ID" == "fedora" ]; then
  handle_conflicts "$DOTFILES_DIR/$fedora_stow_config_directory" "$XDG_CONFIG_HOME"
  handle_conflicts "$DOTFILES_DIR/$fedora_stow_home_directory" "$HOME"
  handle_conflicts "$DOTFILES_DIR/$fedora_stow_etc_directory" "$ETC"
  handle_conflicts "$DOTFILES_DIR/$linux_stow_config_directory" "$XDG_CONFIG_HOME"
  handle_conflicts "$DOTFILES_DIR/$linux_stow_home_directory" "$HOME"
  handle_conflicts "$DOTFILES_DIR/$linux_stow_etc_directory" "$ETC"
fi

# --- Final Step ---
make

