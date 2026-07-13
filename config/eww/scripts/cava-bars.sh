#!/bin/bash
# deflisten eww: ubah output RAW cava menjadi deretan blok unicode.
#
# HEMAT BATERAI: cava HANYA dijalankan saat popup media terbuka. popup.sh
# membuat file penanda saat membuka, dan menghapusnya saat menutup. Kalau
# penanda tak ada, skrip ini cuma memancarkan bar diam dan tidur.

MARK="${XDG_RUNTIME_DIR:-/tmp}/eww-media-open"
CFG="$HOME/.config/eww/cava.conf"

BLOCKS=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
# jumlah ▁ harus sama dengan `bars` di cava.conf (32) supaya lebar bar diam
# sama dengan saat aktif -- kalau beda, popup akan "meloncat" lebarnya.
IDLE="▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁"

while true; do
    if [ ! -e "$MARK" ]; then
        printf '%s\n' "$IDLE"
        sleep 1
        continue
    fi

    # coproc supaya PID cava bisa dipegang dan dimatikan saat popup ditutup
    coproc CAVA { cava -p "$CFG" 2>/dev/null; }

    while IFS= read -r -u "${CAVA[0]}" line; do
        [ -e "$MARK" ] || break          # popup ditutup -> berhenti
        out=""
        IFS=';' read -ra vals <<< "$line"
        for v in "${vals[@]}"; do
            [ -n "$v" ] && out+="${BLOCKS[$v]}"
        done
        printf '%s\n' "$out"
    done

    kill "$CAVA_PID" 2>/dev/null
    wait "$CAVA_PID" 2>/dev/null
    printf '%s\n' "$IDLE"
done
