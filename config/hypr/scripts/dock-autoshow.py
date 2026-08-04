#!/usr/bin/env python3
"""Tampilkan dock otomatis saat workspace aktif KOSONG (ala macOS/GNOME).

Mendengar event Hyprland langsung lewat socket2 -- event-driven, TANPA polling,
jadi tidak membebani CPU/baterai. socat/nc tak diperlukan.

  workspace kosong  -> SIGRTMIN+2 (show dock)
  ada window        -> SIGRTMIN+3 (hide dock)

Sinyal hanya dikirim saat status BERUBAH (tidak spam).
Dock tetap bisa dipanggil manual: hover tepi bawah, atau Super+A (toggle).
"""

import json
import os
import signal
import socket
import subprocess
import sys
import time

SHOW = signal.SIGRTMIN + 2
HIDE = signal.SIGRTMIN + 3

# Event yang bisa mengubah jumlah window di workspace aktif
EVENTS = {
    "workspace", "workspacev2",
    "openwindow", "closewindow",
    "movewindow", "movewindowv2",
    "focusedmon", "monitoradded", "monitorremoved",
}

# wofi/swaync/wlogout adalah LAYER, bukan window -- menutupnya tidak memancarkan
# `closewindow`. Tanpa ini, dock yang menutup diri karena tombol launcher diklik
# tak akan muncul lagi walau workspace masih kosong. Jadi `closelayer` juga
# memicu cek ulang.
LAYER_CLOSE_EVENT = "closelayer"

# ...TAPI layer milik dock sendiri harus diabaikan, kalau tidak jadi loop:
# dock tutup -> closelayer -> buka lagi -> ... tanpa henti.
IGNORE_LAYERS = {"nwg-dock", "hotspot"}


def dock_pid():
    """PID nwg-dock-hyprland (comm terpotong jadi 'nwg-dock-hyprla')."""
    for entry in os.listdir("/proc"):
        if not entry.isdigit():
            continue
        try:
            with open(f"/proc/{entry}/comm") as f:
                if f.read().strip().startswith("nwg-dock"):
                    return int(entry)
        except OSError:
            continue
    return None


def workspace_is_empty():
    try:
        out = subprocess.run(
            ["hyprctl", "activeworkspace", "-j"],
            capture_output=True, text=True, timeout=2,
        )
        return json.loads(out.stdout).get("windows", 1) == 0
    except Exception:
        return False


def main():
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if not sig:
        sys.exit("HYPRLAND_INSTANCE_SIGNATURE tidak diset")
    xdg = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    path = os.path.join(xdg, "hypr", sig, ".socket2.sock")

    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(path)

    def signal_now():
        pid = dock_pid()
        if pid is None:
            script = os.path.expanduser("~/.config/hypr/scripts/dock-start.sh")
            subprocess.Popen([script])
            return
        try:
            os.kill(pid, SHOW if workspace_is_empty() else HIDE)
        except OSError:
            pass

    def apply():
        # Tepat setelah event, hyprctl KADANG masih melaporkan workspace lama
        # (race) -- bikin dock nyangkut. Solusinya baca DUA KALI: pembacaan
        # kedua mengoreksi kalau yang pertama meleset. Sinyalnya idempoten,
        # jadi mengirim ulang aman.
        time.sleep(0.12)
        signal_now()
        time.sleep(0.35)
        signal_now()

    # Mode -r membuat dock MULAI dalam keadaan terlihat. Saat login, listener bisa
    # start lebih dulu daripada dock -- kalau langsung apply(), dock_pid() masih
    # None dan dock tertinggal tampil di workspace yang berisi. Jadi tunggu dulu.
    for _ in range(40):  # maks ~10 detik
        if dock_pid() is not None:
            break
        time.sleep(0.25)

    apply()  # terapkan kondisi awal

    buf = b""
    while True:
        data = sock.recv(4096)
        if not data:
            break
        buf += data
        while b"\n" in buf:
            line, buf = buf.split(b"\n", 1)
            head, _, payload = line.partition(b">>")
            name = head.decode(errors="ignore")
            ns = payload.decode(errors="ignore").strip()

            if name in EVENTS:
                apply()
            elif name == LAYER_CLOSE_EVENT and ns not in IGNORE_LAYERS:
                # mis. wofi ditutup -> kalau workspace masih kosong, tampilkan
                # lagi dock (yang tadi menutup diri karena tombolnya diklik)
                apply()


if __name__ == "__main__":
    main()
