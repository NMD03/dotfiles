#!/bin/bash

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
