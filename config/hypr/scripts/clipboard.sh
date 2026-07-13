#!/bin/bash
# Riwayat clipboard: cliphist + wofi (tema GitHub Dark).
# cliphist mengisi riwayat lewat `wl-paste --watch cliphist store` (autostart).
# Baris terpilih masih membawa ID di depannya; `cliphist decode` yang membacanya.

selected=$(cliphist list | wofi --dmenu \
    --prompt "󰅍 Clipboard" \
    --width 700 --height 400 \
    --cache-file=/dev/null \
    --style ~/.config/wofi/style.css)

[ -n "$selected" ] || exit 0

printf '%s' "$selected" | cliphist decode | wl-copy
