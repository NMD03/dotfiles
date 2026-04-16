#!/usr/bin/env bash
set -eu

action="${1:-}"

case "$action" in
  up)
    wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
    ;;
  down)
    wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-
    ;;
  mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    ;;
  micmute)
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    ;;
  *)
    exit 1
    ;;
esac

if [ "$action" = "micmute" ]; then
  if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
    dunstify "Microphone" "Muted" \
      -h string:x-dunst-stack-tag:mic
  else
    dunstify "Microphone" "Unmuted" \
      -h string:x-dunst-stack-tag:mic
  fi
  exit 0
fi

if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED; then
  dunstify "Volume" "Muted" \
    -h string:x-dunst-stack-tag:volume
else
  v="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2*100}')"
  dunstify "Volume" "${v}%" \
    -h int:value:"$v" \
    -h string:x-dunst-stack-tag:volume
fi
