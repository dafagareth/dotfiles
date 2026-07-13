
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- HYPRLAND CONFIGURATION (migrated dari hyprland.conf)   --
-- Wiki: https://wiki.hypr.land/Configuring/               --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Internal monitor
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = 1.33,
})
-- External monitor (HDMI), mirroring eDP-1
hl.monitor({
    output   = "HDMI-A-2",
    mode     = "1920x1080@60",
    position = "1920x0",
    scale    = 1.0,
    mirror   = "eDP-1",
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "wofi --show drun"
local browser     = "firefox"
local noteTaking  = "obsidian"
local code        = "codium"


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    hl.exec_cmd("kanshi &")
    hl.exec_cmd("waybar &")
    -- eww: daemon untuk popup media & volume (dipicu klik modul Waybar)
    hl.exec_cmd("eww daemon &")
    -- Dock ala macOS. Opsinya ada di dock-start.sh (satu sumber, dipakai juga
    -- oleh dock-pin.sh saat perlu restart dock).
    hl.exec_cmd("$HOME/.config/hypr/scripts/dock-start.sh &")
    -- Dock otomatis muncul saat workspace aktif kosong (listener event Hyprland).
    -- Dibungkus loop: kalau listener-nya mati, hidupkan lagi (self-healing) --
    -- pernah mati diam-diam dan bikin fitur ini berhenti tanpa ketahuan.
    hl.exec_cmd("bash -c 'while true; do $HOME/.config/hypr/scripts/dock-autoshow.py; sleep 3; done' &")
    -- Wallpaper via awww (fork swww) -- slideshow: daemon + gambar acak dari
    -- ~/Pictures/Wallpapers, berganti tiap 15 menit. Taruh gambar di folder itu;
    -- kalau cuma 1 gambar ya ditampilkan itu saja.
    hl.exec_cmd("$HOME/.config/hypr/scripts/wallpaper-slideshow.sh &")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- cliphist: rekam tiap perubahan clipboard untuk riwayat (Super+V)
    hl.exec_cmd("wl-paste --watch cliphist store &")

    -- GTK/Icon theme settings
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Breeze-Dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- NVIDIA
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

-- Desktop session detection (xdg-open dll)
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- ssh-agent: supaya app GUI (VSCodium dsb.) yang diluncurkan dari Hyprland
-- juga menemukan agent-nya saat push/pull. UID 1000 = user ini.
hl.env("SSH_AUTH_SOCK", "/run/user/1000/ssh-agent.socket")

-- Cursor
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Theme
hl.env("GTK_THEME", "Breeze-Dark")
hl.env("GTK_APPLICATION_PREFER_DARK_THEME", "1")

-- Qt
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_STYLE_OVERRIDE", "breeze")

-- Steam scaling
hl.env("STEAM_FORCE_DESKTOPUI_SCALING", "1.5")

-- Default applications
hl.env("BROWSER", "firefox")
hl.env("EDITOR", "codium")
hl.env("VISUAL", "codium")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },

    general = {
        gaps_in  = 2,
        gaps_out = 0,

        border_size = 1,

        -- Minimalist grayscale borders
        col = {
            active_border   = "rgba(ffffffcc)", -- White 80% opacity
            inactive_border = "rgba(ffffff33)", -- White 20% opacity
        },

        resize_on_border = false,
        allow_tearing    = false,

        layout = "dwindle",
    },

    decoration = {
        rounding = 0,

        active_opacity   = 0.98,
        inactive_opacity = 0.90,

        shadow = {
            enabled      = true,
            range        = 6,
            render_power = 3,
            color        = 0x66000000, -- rgba(00000066)
        },

        blur = {
            enabled  = true,
            size     = 8,
            passes   = 3,
            vibrancy = 0.15,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Bezier curves, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })


-------------------
---- LAYOUTS ------
-------------------

hl.config({
    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },
})


----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout = "us",
        -- CapsLock DIMATIKAN total (tombolnya tidak melakukan apa-apa).
        -- Alternatif kalau suatu saat mau dimanfaatkan, ganti nilainya:
        --   "caps:escape"        -> CapsLock jadi Escape
        --   "caps:ctrl_modifier" -> CapsLock jadi Ctrl
        kb_options = "caps:none",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- Per-device configuration (belum pernah diganti dari placeholder)
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Application launchers
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + N",      hl.dsp.exec_cmd(noteTaking))
hl.bind(mainMod .. " + C",      hl.dsp.exec_cmd(code))
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd(menu))

-- Window management
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
-- Dimatikan di config lama juga (dikomen):
-- hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Focus movement
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces mainMod + [0-9], pindahin window mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Minimize window ke special workspace (silent flag: best-effort, cek popup error abis reload)
hl.bind(mainMod .. " + Z", hl.dsp.window.move({ workspace = "special:minimized", silent = true }))

-- Notifikasi (swaync). Super+N sudah dipakai obsidian, jadi pakai SHIFT.
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))   -- buka/tutup panel
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("swaync-client -d -sw"))   -- toggle Jangan Ganggu
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("swaync-client -C -sw"))   -- tutup semua popup

-- Window switcher (daftar semua window di semua workspace, pakai wofi)
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd("~/.config/hypr/wofi-window-switcher.sh"))

-- Cycle window: langsung ke window berikutnya di workspace ini, tanpa menu.
-- Dipindah dari ALT+Tab ke Super+' (apostrof) supaya tangan tidak perlu pindah
-- ke ALT -- Super sudah dipegang untuk hampir semua bind lain.
-- Super+SHIFT+' buat mundur. bring_to_top biar window floating naik ke depan
-- (kalau cuma cycle_next, floating-nya dapat fokus tapi tetap ketimbun).
-- CATATAN sintaks: `code:48` TIDAK didukung parser bind Lua ini (bind-nya lenyap
-- diam-diam). Yang dipakai harus NAMA KEYSYM. Untuk tombol di sebelah Enter,
-- xkb (layout us) memberi keysym "apostrophe"; untuk tombol kiri angka 1,
-- keysym-nya "grave". Keduanya di-bind supaya tak perlu memikirkan tombol mana.
local function cycle(forward)
    return function()
        hl.dispatch(hl.dsp.window.cycle_next({ next = forward }))
        hl.dispatch(hl.dsp.window.bring_to_top())
    end
end

hl.bind(mainMod .. " + apostrophe",         cycle(true))   -- '
hl.bind(mainMod .. " + grave",              cycle(true))   -- `
hl.bind(mainMod .. " + SHIFT + apostrophe", cycle(false))  -- mundur
hl.bind(mainMod .. " + SHIFT + grave",      cycle(false))  -- mundur

-- Window resize (resizeactive equivalent: relative pixel delta)
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.resize({ x = -40, y = 0,  relative = true }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = 40,  y = 0,  relative = true }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0,   y = -40, relative = true }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }))

-- Scroll through workspaces mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows dengan mainMod + LMB/RMB drag
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshot: full screen -> simpan ke file + clipboard + notifikasi
hl.bind("Print", hl.dsp.exec_cmd("bash -c 'mkdir -p ~/Pictures/Screenshot; f=~/Pictures/Screenshot/screenshot-$(date +%Y%m%d-%H%M%S).png; grim \"$f\" && wl-copy < \"$f\" && notify-send \"Screenshot\" \"Disimpan: $f\"'"))

-- Screenshot: pilih area (drag select) -> buka swappy buat anotasi/simpan/copy
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("bash -c 'mkdir -p ~/Pictures/Screenshot; grim -g \"$(slurp)\" - | swappy -f -'"))

-- Lock screen
-- Lock layar. Warna & indikator diatur di ~/.config/swaylock/config (tema
-- GitHub Dark), termasuk indicator-idle-visible supaya indikator selalu
-- terlihat -- layar kunci polos hitam gak bisa dibedakan dari layar mati.
-- Sama persis dengan lock_cmd hypridle.
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("swaylock -f"))

-- Clipboard history (cliphist + wofi). Super+V dipakai togglefloating (baris ~261),
-- jadi clipboard di Super+SHIFT+V biar tidak bentrok.
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/clipboard.sh"))

-- Power menu (wlogout): overlay layar-penuh + blur, tombol horizontal.
-- -b 5 = 5 tombol per baris -> semua dalam satu baris horizontal di tengah.
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("wlogout -b 5"))

-- Color picker (hyprpicker): colek warna piksel -> hex ke clipboard + notif.
-- Super+P sudah dipakai, jadi ini di Super+SHIFT+P.
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("bash -c 'hyprpicker -a -f hex && notify-send \"Warna disalin\" \"$(wl-paste)\"'"))

-- Wallpaper picker (wofi): pilih wallpaper dari ~/Pictures/Wallpapers.
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/wallpaper-picker.sh"))

-- Power profile: cycle power-saver -> balanced -> performance (+ notif).
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/powerprofile.sh cycle"))

-- Toggle dock (tampil/sembunyi) tanpa perlu mouse ke tepi bawah.
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/dock-toggle.sh"))

-- Kelola app yang di-pin ke dock (menu wofi; bisa pin app yang belum berjalan).
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/dock-pin.sh"))

-- Volume control
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })

-- Brightness control
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind(mainMod .. " + F12", hl.dsp.exec_cmd("brightnessctl set +5%"))
hl.bind(mainMod .. " + F11", hl.dsp.exec_cmd("brightnessctl set 5%-"))

-- Media control (butuh playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Blur latar desktop di belakang wlogout (power menu layar-penuh).
-- Namespace layer wlogout versi ini = "logout_dialog" (diverifikasi via
-- `hyprctl layers`, BUKAN "logout"/"wlogout").
hl.layer_rule({
    name         = "blur-wlogout",
    match        = { namespace = "logout_dialog" },
    blur         = true,
    ignore_alpha = 0.3,
})

-- Blur di belakang dock -> efek "kaca" ala macOS.
-- Namespace diverifikasi via `hyprctl layers` = "nwg-dock".
hl.layer_rule({
    name         = "blur-dock",
    match        = { namespace = "nwg-dock" },
    blur         = true,
    ignore_alpha = 0.3,
})

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Suppress maximize events
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- Fix XWayland dragging
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Hyprland-run positioning
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})
