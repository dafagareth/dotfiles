#!/bin/bash
# Toggle popup eww. Dipanggil dari on-click modul Waybar.
#
#   popup.sh media    -> popup media (album art + cava + kontrol)
#   popup.sh volume   -> popup volume (master / mic / per-aplikasi)
#   popup.sh close    -> tutup semua (dipanggil oleh backdrop saat diklik)
#
# BACKDROP: popup eww tidak punya event "focus lost", jadi klik di luar tak
# akan menutupnya sendiri. Solusinya lapisan transparan selebar layar yang
# dibuka DI BAWAH popup; klik di mana pun mengenainya -> semua ditutup.
# Urutan buka penting: backdrop DULU, baru popup -- supaya popup di atasnya.
#
# Saat popup media terbuka dibuat file penanda; cava & polling media hanya
# berjalan selama penanda itu ada (hemat baterai).

WIN="$1"
[ -n "$WIN" ] || exit 1
MARK="${XDG_RUNTIME_DIR:-/tmp}/eww-media-open"

# pastikan daemon eww hidup
eww ping >/dev/null 2>&1 || eww daemon >/dev/null 2>&1

close_all() {
    eww close media    >/dev/null 2>&1
    eww close volume   >/dev/null 2>&1
    eww close backdrop >/dev/null 2>&1
    rm -f "$MARK"
}

if [ "$WIN" = "close" ]; then
    close_all
    exit 0
fi

opened=$(eww active-windows 2>/dev/null | cut -d: -f1)
is_open() { printf '%s\n' "$opened" | grep -qx "$1"; }

if is_open "$WIN"; then
    # klik modul yang sama saat popup-nya terbuka -> tutup
    close_all
else
    close_all                      # tutup popup lain (dan backdrop lamanya)
    [ "$WIN" = "media" ] && touch "$MARK"
    eww open backdrop >/dev/null 2>&1
    eww open "$WIN"   >/dev/null 2>&1
fi
