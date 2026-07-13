#!/bin/bash
# Dipanggil defpoll eww. Keluarkan JSON: volume master, mikrofon, dan
# daftar aplikasi yang sedang mengeluarkan suara (sink-inputs) + volumenya.

read_vol() {  # $1 = @DEFAULT_AUDIO_SINK@ / @DEFAULT_AUDIO_SOURCE@
    wpctl get-volume "$1" 2>/dev/null
}

m=$(read_vol @DEFAULT_AUDIO_SINK@)
s=$(read_vol @DEFAULT_AUDIO_SOURCE@)

master=$(printf '%s' "$m" | awk '{printf "%d", $2*100}')
mic=$(printf '%s' "$s"    | awk '{printf "%d", $2*100}')
master_muted=$(printf '%s' "$m" | grep -qi muted && echo true || echo false)
mic_muted=$(printf '%s' "$s"    | grep -qi muted && echo true || echo false)

# Aplikasi yang sedang bunyi. Nama diambil dari application.name, jatuh ke
# media.name kalau kosong (mis. tab browser).
apps=$(pactl -f json list sink-inputs 2>/dev/null | jq -c '
    [ .[] | {
        id:   .index,
        name: (.properties["application.name"]
               // .properties["media.name"]
               // "Aplikasi"),
        vol:  (((.volume | to_entries | .[0].value.value_percent) // "0%")
               | rtrimstr("%") | tonumber)
    } ]' 2>/dev/null)
[ -z "$apps" ] && apps='[]'

jq -nc \
    --argjson master "${master:-0}" \
    --argjson mic "${mic:-0}" \
    --argjson mm "$master_muted" \
    --argjson sm "$mic_muted" \
    --argjson apps "$apps" \
    '{master:$master, master_muted:$mm, mic:$mic, mic_muted:$sm, apps:$apps}'
