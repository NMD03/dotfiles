#!/usr/bin/env bash
#
# i3status plus one entry listing all active WireGuard tunnels, e.g. "WG: home lab".
# Used as sway's bar status_command. Needs output_format = "i3bar" in the config.

COLOR="#b5c7eb"

wg_block() {
    local names
    # interface names only, whatever they are called; no root needed
    names=$(ip -br link show type wireguard 2>/dev/null | awk '{sub(/@.*/, "", $1); print $1}' | paste -sd' ')
    [[ -n $names ]] && printf '{"name":"wireguard","full_text":"WG: %s","color":"%s"},' "$names" "$COLOR"
}

i3status | {
    # i3bar protocol: header line, "[", then one JSON array per update ("," before all but the first)
    read -r line && echo "$line"
    read -r line && echo "$line"
    while read -r line; do
        prefix=""
        if [[ $line == ,* ]]; then
            prefix=","
            line=${line#,}
        fi
        echo "${prefix}[$(wg_block)${line#\[}"
    done
}
