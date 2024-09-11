#!/bin/bash

# Ensure the script is not run as root to avoid running apt-get without sudo
if [ "$(id -u)" -eq 0 ]; then
  error "This script should not be run as root. Please run without sudo."
  exit 1
fi

sudo apt-get update

# --- Install Ansible ---
if ! check_command "ansible"; then
  info "Install Ansible using apt..."
  sudo apt-get install -y ansible
  if check_command "ansible"; then
    success "Ansible installed successfully."
  else
    error "Ansible installation failed."
  fi
else
  info "Ansible already installed on your system."
fi
