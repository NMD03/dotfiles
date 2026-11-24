#!/bin/sh
# launch.sh <flatpak-app-id> <command> [args...]
# Starts the Flatpak if it is installed, otherwise the native command
# (e.g. Flatpaks on Pleiades, .deb/Snap installs on Ubuntu).
app=$1
cmd=$2
shift 2
if command -v flatpak >/dev/null && flatpak info "$app" >/dev/null 2>&1; then
    exec flatpak run "$app" "$@"
fi
exec "$cmd" "$@"
