#!/bin/bash
# Power menu via wofi (tema GitHub Dark).
# Logout memakai bentuk Lua yang benar: `hyprctl dispatch 'hl.dsp.exit()'`
# (dispatch 'exit' polos error di config-Lua -- ditafsirkan sebagai Lua).
# Lock memakai swaylock -f; buka kunci dengan MENGETIK PASSWORD.

lock="  Lock"
suspend="󰏤  Suspend"
logout="󰍃  Logout"
reboot="  Reboot"
shutdown="  Shutdown"

chosen=$(printf '%s\n' "$lock" "$suspend" "$logout" "$reboot" "$shutdown" | wofi --dmenu \
    --prompt "Power" \
    --width 280 --height 300 \
    --cache-file=/dev/null \
    --style ~/.config/wofi/style.css)

case "$chosen" in
    "$lock")     swaylock -f ;;
    "$suspend")  systemctl suspend ;;
    "$logout")   hyprctl dispatch 'hl.dsp.exit()' ;;
    "$reboot")   systemctl reboot ;;
    "$shutdown") systemctl poweroff ;;
esac
