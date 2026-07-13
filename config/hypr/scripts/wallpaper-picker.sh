#!/bin/bash
# Pilih wallpaper dari ~/Pictures/Wallpapers lewat wofi, set via awww.
# Catatan: slideshow (kalau aktif) tetap bisa mengganti lagi saat intervalnya tiba.

DIR="$HOME/Pictures/Wallpapers"

sel=$(find "$DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -printf '%f\n' \
    | sort \
    | wofi --dmenu \
        --prompt "󰸉 Wallpaper" \
        --width 420 --height 460 \
        --cache-file=/dev/null \
        --style ~/.config/wofi/style.css)

[ -z "$sel" ] && exit 0
[ -f "$DIR/$sel" ] && awww img "$DIR/$sel" --resize crop --transition-type grow --transition-fps 60
