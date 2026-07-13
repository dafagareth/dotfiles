#!/bin/bash
# deflisten eww: info media sebagai JSON (judul, artis, player, album art, progress).
#
# Album art: MPRIS memberi `mpris:artUrl`. Firefox/YouTube memberi URL https,
# jadi harus diunduh dulu ke file lokal (GTK image tak bisa memuat https).
# Diunduh SEKALI lalu di-cache berdasarkan hash URL-nya.
#
# HEMAT BATERAI: kalau popup tertutup, jeda pembaruan diperlambat.

ART_DIR="${XDG_RUNTIME_DIR:-/tmp}/eww-art"
MARK="${XDG_RUNTIME_DIR:-/tmp}/eww-media-open"
mkdir -p "$ART_DIR"

emit() {
    status=$(playerctl status 2>/dev/null)
    title=$(playerctl metadata title 2>/dev/null)
    artist=$(playerctl metadata artist 2>/dev/null)
    player=$(playerctl metadata --format '{{playerName}}' 2>/dev/null)
    arturl=$(playerctl metadata mpris:artUrl 2>/dev/null)

    art=""
    if [ -n "$arturl" ]; then
        key=$(printf '%s' "$arturl" | md5sum | cut -d' ' -f1)
        f="$ART_DIR/$key"
        if [ ! -s "$f" ]; then
            case "$arturl" in
                file://*) cp -- "${arturl#file://}" "$f" 2>/dev/null ;;
                http*)    curl -sfL --max-time 5 -o "$f" "$arturl" 2>/dev/null ;;
            esac
        fi
        [ -s "$f" ] && art="$f"
    fi

    # progress %: length dalam MIKRODETIK, position dalam detik
    pos=$(playerctl position 2>/dev/null | cut -d. -f1)
    len=$(playerctl metadata mpris:length 2>/dev/null)
    prog=0
    if [[ "$len" =~ ^[0-9]+$ ]] && [ "$len" -gt 0 ] && [[ "$pos" =~ ^[0-9]+$ ]]; then
        prog=$(( pos * 100000000 / len ))
        [ "$prog" -gt 100 ] && prog=100
    fi

    jq -nc --arg s "${status:-Stopped}" \
           --arg t "${title:-Tidak ada media}" \
           --arg a "${artist:-}" \
           --arg p "${player:-}" \
           --arg art "$art" \
           --argjson prog "$prog" \
           '{status:$s, title:$t, artist:$a, player:$p, art:$art, progress:$prog}'
}

emit
while true; do
    if [ -e "$MARK" ]; then sleep 1; else sleep 3; fi
    emit
done
