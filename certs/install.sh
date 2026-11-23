#!/usr/bin/env bash
#
# Trust the CA certificates in this folder (certs/*.crt):
#   1. system trust store (curl, git, podman, python, ...)
#   2. NSS database ~/.pki/nssdb (Chromium/Electron apps, e.g. Bitwarden)
#   3. Flatpak override so sandboxed Electron apps can read ~/.pki
#
# Safe to re-run. Called by `make` on Linux.

set -euo pipefail

DIR=$(cd "$(dirname "$0")" && pwd)
FLATPAK_APPS=(com.bitwarden.desktop) # Electron Flatpaks that should see ~/.pki

. /etc/os-release
case " $ID ${ID_LIKE:-} " in
    *" fedora "* | *" arch "*)
        anchors=/etc/pki/ca-trust/source/anchors
        [[ $ID == arch ]] && anchors=/etc/ca-certificates/trust-source/anchors
        update=(update-ca-trust) ;;
    *" debian "* | *" ubuntu "*)
        anchors=/usr/local/share/ca-certificates # files must end in .crt
        update=(update-ca-certificates) ;;
    *)
        echo "certs: unsupported distro '$ID', skipping" >&2
        exit 0 ;;
esac

# 1. System store: copy (not link), system services must not depend on $HOME
changed=0
for crt in "$DIR"/*.crt; do
    target="$anchors/$(basename "$crt")"
    if ! cmp -s "$crt" "$target"; then
        sudo install -D -m 644 "$crt" "$target"
        changed=1
    fi
done
if [[ $changed -eq 1 ]]; then
    sudo "${update[@]}"
fi

# 2. NSS database (re-adding a nickname replaces the entry)
if command -v certutil >/dev/null; then
    db="sql:$HOME/.pki/nssdb"
    mkdir -p "$HOME/.pki/nssdb"
    [[ -f $HOME/.pki/nssdb/cert9.db ]] || certutil -d "$db" -N --empty-password
    for crt in "$DIR"/*.crt; do
        certutil -d "$db" -A -t "C,," -n "$(basename "$crt" .crt)" -i "$crt"
    done
else
    echo "certs: certutil not found (nss-tools / libnss3-tools / nss), skipping NSS" >&2
fi

# 3. Flatpak Electron apps
if command -v flatpak >/dev/null; then
    for app in "${FLATPAK_APPS[@]}"; do
        flatpak override --user --filesystem=~/.pki:ro "$app"
    done
fi
