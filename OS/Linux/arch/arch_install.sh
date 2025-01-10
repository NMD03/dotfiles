#!/bin/bash

# Helper functions for colored output
info() {
  echo -e "\033[1;34mINFO:\033[0m $1"
}

success() {
  echo -e "\033[1;32mSUCCESS:\033[0m $1"
}

error() {
  echo -e "\033[1;31mERROR:\033[0m $1"
}

check_command() {
  command -v "$1" >/dev/null 2>&1
}

# Ensure the script is not run as root to avoid unnecessary risks
if [ "$(id -u)" -eq 0 ]; then
  error "This script should not be run as root. Please run it as a normal user."
  exit 1
fi

# Update the system package database
info "Updating package database..."
if sudo pacman -Syu --noconfirm; then
  success "Package database updated successfully."
else
  error "Failed to update package database."
  exit 1
fi

# Install Ansible
info "Checking for Ansible..."
if ! check_command "ansible"; then
  info "Ansible is not installed. Installing..."
  if sudo pacman -S --noconfirm ansible; then
    if check_command "ansible"; then
      success "Ansible installed successfully."
    else
      error "Ansible installation failed after running pacman."
      exit 1
    fi
  else
    error "Failed to install Ansible using pacman."
    exit 1
  fi
else
  success "Ansible is already installed on your system."
fi

