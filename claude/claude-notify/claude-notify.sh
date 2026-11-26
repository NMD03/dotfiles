#!/usr/bin/env bash
#
# claude-notify.sh show|close
#
# Called by Claude Code hooks (see hooks/hooks.json) with the hook event as
# JSON on stdin. Shows one dunst notification per session when it needs you,
# and closes it again when the session continues.
#
#   show   Notification hook: permission prompt, question or idle -> notify
#   close  PostToolUse / UserPromptSubmit / Stop / SessionEnd -> close it
#
# Styling (colour, no timeout) comes from the [claude-code] rule in dunstrc.

set -uo pipefail

APP=claude-code
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/claude-notify"

input=$(cat)
field() { jq -r --arg k "$1" '.[$k] // empty' <<<"$input" 2>/dev/null; }

session=$(field session_id)
[[ -n $session ]] || exit 0
marker="$STATE_DIR/$session"
# dunst needs a numeric id; derive a stable one from the session id
id=$(printf '%s' "$session" | cksum | cut -d' ' -f1)
id=$((id % 2147483647 + 1))

case "${1:-}" in
show)
    # category selects the frame colour in dunstrc ([claude-code-<category>])
    case "$(field notification_type)" in
    permission_prompt) category=permission label="needs permission" ;;
    elicitation_dialog | elicitation_url_dialog | agent_needs_input) category=question label="has a question" ;;
    idle_prompt) category=idle label="is waiting" ;;
    *) exit 0 ;; # e.g. auth_success: not worth a sticky notification
    esac
    cwd=$(field cwd)
    # session name is not in the hook input; look it up, fall back to the folder
    name=$(timeout 3 claude agents --json 2>/dev/null |
        jq -r --arg s "$session" '[.[] | select(.sessionId == $s) | .name // empty][0] // empty' 2>/dev/null)
    name=${name:-$(basename "${cwd:-?}")}
    body=$(field message)
    body=${body:-Claude needs you}
    [[ -n $cwd ]] && body+=$'\n'"$cwd"
    mkdir -p "$STATE_DIR"
    dunstify -a "$APP" -c "claude.$category" -r "$id" "✻ $name · $label" "$body" &&
        touch "$marker"
    ;;
close)
    # PostToolUse fires on every tool call: only act if this session has one open
    [[ -e $marker ]] || exit 0
    dunstify -C "$id"
    rm -f "$marker"
    ;;
*)
    echo "usage: $0 show|close  (hook JSON on stdin)" >&2
    exit 2
    ;;
esac
