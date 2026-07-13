#!/bin/bash
# Toggle visibilitas dock (dipakai Super+A).
#
# Kalau toggle ini MENAMPILKAN dock, dijadwalkan auto-hide setelah 5 detik.
# PENGECUALIAN: kalau workspace sedang KOSONG, auto-hide dilewati -- di situ
# dock memang seharusnya tetap tampil (lihat dock-autoshow.py), dan menyembunyikannya
# akan bertabrakan dengan fitur itu.
#
# Catatan: Escape TIDAK bisa dipakai untuk menutup dock. nwg-dock sama sekali
# tidak menangani keyboard (tak ada key-press-event / keyboard interactivity di
# source-nya), jadi tombol apa pun tak akan sampai ke dia.

AUTOHIDE_SECS=5
TIMER_PID="${XDG_RUNTIME_DIR:-/tmp}/dock-autohide.pid"

# PID dock dicari lewat comm (bukan `pkill -f`, yang bisa menabrak shell pemanggil)
pid=$(ps -e -o pid=,comm= | awk '/nwg-dock/ {print $1; exit}')
[ -n "$pid" ] || exit 0

dock_visible() {
    hyprctl layers -j 2>/dev/null \
        | jq -e -r '.[].levels | to_entries[].value[] | .namespace' 2>/dev/null \
        | grep -qx 'nwg-dock'
}

workspace_empty() {
    [ "$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.windows')" = "0" ]
}

# Batalkan timer auto-hide yang masih menggantung dari toggle sebelumnya,
# supaya dia tidak menyembunyikan dock yang baru saja kita tampilkan lagi.
if [ -f "$TIMER_PID" ]; then
    kill "$(cat "$TIMER_PID")" 2>/dev/null
    rm -f "$TIMER_PID"
fi

if dock_visible; then
    kill -RTMIN+3 "$pid" 2>/dev/null          # sedang tampil -> sembunyikan
else
    kill -RTMIN+2 "$pid" 2>/dev/null          # sedang sembunyi -> tampilkan
    if ! workspace_empty; then
        (
            sleep "$AUTOHIDE_SECS"
            # Periksa ULANG sebelum menyembunyikan: dalam 5 detik itu kamu bisa
            # saja sudah pindah ke workspace KOSONG, di mana dock justru harus
            # tetap tampil. Tanpa cek ini, timer lama akan menyembunyikannya.
            workspace_empty || kill -RTMIN+3 "$pid" 2>/dev/null
            rm -f "$TIMER_PID"
        ) &
        echo $! > "$TIMER_PID"
    fi
fi
