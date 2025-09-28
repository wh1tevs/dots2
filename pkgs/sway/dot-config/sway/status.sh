#!/usr/bin/env bash

set -euo pipefail

function get_volume {
  muted="$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')"

  if [[ "$muted" == "yes" ]]; then
    echo "mut"
    return
  fi

  echo "$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -n1)"
}

function get_layout {
  layout="$(swaymsg -rt get_inputs | jq -r '.[] | select(.type=="keyboard") | .xkb_active_layout_name' | head -n1)"

  case "$layout" in
  "English (US)")
    echo "us"
    ;;
  "Russian")
    echo "ru"
    ;;
  *)
    echo ""
    ;;
  esac
}

while true; do
  net="$(nmcli -t -f NAME connection show --active | head -n1 | awk -F: '{print $1}')"
  vol="$(get_volume)"
  layout="$(get_layout)"
  datetime="$(date '+%H:%M') $(date '+%A, %d %B %Y')"

  echo -e "net:$net | $layout | vol:$vol | $datetime"
  sleep 1
done
