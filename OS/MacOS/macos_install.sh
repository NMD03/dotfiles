#!/bin/bash

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

# Installed software
check_command() {
  local command=$1
  if command -v "$command" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

# --- Install Xcode Command Line Tools ---
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
else
  info "Xcode Command Line Tools are already installed."
fi

# --- Install Homebrew ---
if ! check_command "brew"; then
  info "Install Homebrew using official install script..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if check_command "brew"; then
    success "Homebrew installed successfully."
  else
    error "Homebrew installation failed."
  fi
else
  info "Homebrew is already installed on your system."
fi

# --- Install Ansible ---
if ! check_command "ansible"; then
  info "Install Ansible using Homebrew..."
  brew install ansible
  if check_command "ansible"; then
    success "Ansible installed successfully."
  else
    error "Ansible installation failed."
  fi
else
  info "Ansible already installed on your system."
fi
