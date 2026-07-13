#!/bin/bash
# Kelola app yang di-pin ke dock lewat menu wofi.
# Memilih sebuah app = TOGGLE (yang belum ter-pin jadi ter-pin, dan sebaliknya).
#
# Kelebihan dibanding klik-kanan di dock: kamu bisa nge-pin app yang SEDANG
# TIDAK BERJALAN (klik-kanan cuma bisa untuk app yang sudah terbuka).
#
# File pinned: ~/.cache/nwg-dock-pinned -- isinya NAMA FILE .desktop saja,
# mis. "firefox.desktop". JANGAN path lengkap: dock gagal me-resolve ikonnya.

PINFILE="$HOME/.cache/nwg-dock-pinned"
DOCK_START="$HOME/.config/hypr/scripts/dock-start.sh"
touch "$PINFILE"

# Kumpulkan app: nama file .desktop + nama tampilannya (lewati yang disembunyikan)
mapfile -t entries < <(
    find /usr/share/applications "$HOME/.local/share/applications" \
        -maxdepth 1 -name '*.desktop' 2>/dev/null |
    while read -r f; do
        grep -qi '^NoDisplay=true' "$f" && continue
        grep -qi '^Type=Application' "$f" || continue
        name=$(grep -m1 '^Name=' "$f" | cut -d= -f2-)
        [ -n "$name" ] && printf '%s\t%s\n' "$(basename "$f")" "$name"
    done | sort -t$'\t' -k2 -f -u
)

[ "${#entries[@]}" -eq 0 ] && { notify-send "Dock" "Tak ada aplikasi ditemukan"; exit 1; }

# Dua array sejajar: yang tampil di wofi, dan nama file .desktop-nya.
# (Disimpan terpisah supaya tak perlu mem-parse balik teks menu.)
declare -a display files
for e in "${entries[@]}"; do
    IFS=$'\t' read -r file name <<< "$e"
    if grep -qxF "$file" "$PINFILE"; then
        display+=("  $name")      # sudah ter-pin
    else
        display+=("   $name")      # belum
    fi
    files+=("$file")
done

sel=$(printf '%s\n' "${display[@]}" | wofi --dmenu \
    --prompt "󰐃 Pin ke dock" \
    --width 480 --height 520 \
    --cache-file=/dev/null \
    --style ~/.config/wofi/style.css)

[ -z "$sel" ] && exit 0

# Cari index dengan perbandingan string biasa (nama app bisa mengandung
# karakter regex seperti [ ] . * -- jadi jangan pakai grep/regex di sini).
for i in "${!display[@]}"; do
    [ "${display[$i]}" = "$sel" ] || continue
    f="${files[$i]}"
    if grep -qxF "$f" "$PINFILE"; then
        grep -vxF "$f" "$PINFILE" > "$PINFILE.tmp" && mv "$PINFILE.tmp" "$PINFILE"
        notify-send -t 2000 "Dock" "Unpin: ${sel#*  }"
    else
        printf '%s\n' "$f" >> "$PINFILE"
        notify-send -t 2000 "Dock" "Pin: ${sel#*  }"
    fi
    break
done

# Restart dock supaya daftar pinned yang baru terbaca
pid=$(ps -e -o pid=,comm= | awk '/nwg-dock/ {print $1; exit}')
[ -n "$pid" ] && kill "$pid"
sleep 0.5
setsid -f "$DOCK_START" >/dev/null 2>&1
