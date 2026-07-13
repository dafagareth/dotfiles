#!/bin/bash
# awww slideshow: set wallpaper acak dari folder, berganti tiap INTERVAL detik.
# Kalau folder cuma punya 1 gambar, ya itu saja yang tampil (tidak error).
# Dipakai di autostart hyprland.lua. Argumen opsional: [folder] [interval_detik].

DIR="${1:-$HOME/Pictures/Wallpapers}"
INTERVAL="${2:-1800}"   # 30 menit

# pastikan daemon awww siap
pgrep -x awww-daemon >/dev/null || { awww-daemon & sleep 0.6; }

while true; do
    img=$(find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) 2>/dev/null | shuf -n1)
    [ -n "$img" ] && awww img "$img" --resize crop --transition-type grow --transition-fps 60
    sleep "$INTERVAL"
done
