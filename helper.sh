#!/bin/bash

# Color definitions
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Information output function
info() {
  local msg=$1
  echo -e "${BLUE}Info: $msg${NC}"
}

# Error output function
error() {
  local msg=$1
  echo -e "${RED}Error: $msg${NC}"
}

# Warning output function
warn() {
  local msg=$1
  echo -e "${YELLOW}Warning: $msg${NC}"
}

# Success output function
success() {
  local msg=$1
  echo -e "${GREEN}Success: $msg${NC}"
}

# Command check function
check_command() {
  local command=$1
  if command -v "$command" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

export BLUE RED YELLOW GREEN NC
export -f info
export -f error
export -f warn
export -f success
export -f check_command
