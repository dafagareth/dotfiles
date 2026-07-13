#!/bin/bash
# Satu-satunya tempat opsi dock didefinisikan -- dipakai oleh autostart
# hyprland.lua DAN dock-pin.sh (saat perlu restart dock). Ubah di sini saja.
#
#  -r   resident TANPA hotspot (dock tak muncul saat kursor ke tepi bawah);
#       visibilitas diatur Super+A + dock-autoshow.py
#  -i   ukuran ikon
#  -w   jumlah workspace
#  -c   perintah tombol launcher (nwg-drawer tak terpasang -> pakai wofi)
exec nwg-dock-hyprland -r -i 36 -w 5 -c "wofi --show drun" -mb 6
