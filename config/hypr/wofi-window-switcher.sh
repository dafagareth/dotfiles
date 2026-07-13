#!/bin/bash

# Ambil daftar window. Pakai TAB sebagai pemisah, bukan "|", karena judul
# window bisa saja mengandung karakter "|" (mis. tab browser) dan bikin
# parsing field-nya meleset.
mapfile -t entries < <(
    hyprctl clients -j | jq -r '.[] | "\(.workspace.id)\t\(.class)\t\(.title)\t\(.address)"'
)

if [ "${#entries[@]}" -eq 0 ]; then
    notify-send "No Windows" "No windows are currently open"
    exit 0
fi

# Pisah jadi dua array sejajar: yang tampil di wofi, dan address-nya.
# Address disimpan terpisah biar gak perlu cari-cari nomor baris lagi.
declare -a display addrs
for e in "${entries[@]}"; do
    IFS=$'\t' read -r ws class title addr <<< "$e"
    display+=("$(printf '%-8s %-20s %s' "WS:$ws" "$class" "$title")")
    addrs+=("$addr")
done

# Show dalam wofi
selected=$(printf '%s\n' "${display[@]}" | wofi --dmenu \
    --prompt "󰖯 Switch Window" \
    --width 900 \
    --height 500 \
    --cache-file=/dev/null \
    --define hide_scroll=false \
    --style ~/.config/wofi/style-switcher.css)

[ -n "$selected" ] || exit 0

# Cari index yang persis sama (perbandingan string biasa, bukan regex —
# judul window sering mengandung karakter regex seperti [ ] * . )
for i in "${!display[@]}"; do
    if [ "${display[$i]}" = "$selected" ]; then
        # Hyprland versi Lua: "hyprctl dispatch focuswindow address:0x..."
        # ditafsirkan sebagai Lua dan bikin syntax error. Bentuk barunya:
        hyprctl dispatch "hl.dsp.focus({ window = \"address:${addrs[$i]}\" })"
        exit 0
    fi
done
