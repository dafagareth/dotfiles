#!/bin/bash
# Kelola power-profiles-daemon (PPD) tanpa sudo (lewat polkit sesi aktif).
#   powerprofile.sh          -> cetak JSON status untuk modul Waybar
#   powerprofile.sh cycle    -> ganti ke mode berikutnya + notif + refresh Waybar
#
# Urutan cycle: power-saver -> balanced -> performance -> (kembali) power-saver

icon_for() {
    case "$1" in
        performance) printf '' ;;   # bolt
        balanced)    printf '' ;;   # dashboard/tachometer
        power-saver) printf '' ;;   # leaf
        *)           printf '' ;;   # question
    esac
}

cur=$(powerprofilesctl get 2>/dev/null)

case "$1" in
  cycle)
    case "$cur" in
        power-saver) next="balanced" ;;
        balanced)    next="performance" ;;
        performance) next="power-saver" ;;
        *)           next="balanced" ;;
    esac
    powerprofilesctl set "$next" 2>/dev/null
    notify-send -t 2000 -h string:x-canonical-private-synchronous:powerprofile \
        "Power profile" "$(icon_for "$next")  ${next}"
    # refresh modul waybar (signal 8) -- update instan tanpa nunggu interval
    pkill -RTMIN+8 -x waybar 2>/dev/null
    ;;
  *)
    icon=$(icon_for "$cur")
    printf '{"text": "%s", "tooltip": "Power profile: %s\\nKlik untuk ganti", "class": "%s"}\n' \
        "$icon" "$cur" "$cur"
    ;;
esac
