# dotfiles

Hyprland desktop on Arch Linux, themed end to end with the GitHub Dark palette.

Every component that renders on screen uses the same colours, from the terminal
and the bar down to the file manager, the lock screen and the notification
panel. The setup is keyboard driven, with a dock and popup widgets available
when a mouse is more convenient.

## Overview

| Component | Program | Notes |
| --- | --- | --- |
| Compositor | Hyprland | Config written in Lua, not hyprlang |
| Bar | Waybar | Media, power profile, tray, workspaces |
| Launcher | wofi | Also used by the dock, clipboard and pickers |
| Notifications | SwayNC | |
| Lock screen | swaylock | Colours live in one config file, no inline flags |
| Idle | hypridle | |
| Terminal | kitty | |
| Shell | zsh | starship prompt, syntax highlighting |
| File manager | yazi | Opens the current folder in VSCodium or a terminal |
| Editors | Neovim (NvChad) and VSCodium | |
| Dock | nwg-dock-hyprland | Auto shows on an empty workspace, blurred |
| Power menu | wlogout | Full screen, blurred background |
| Widgets | eww | Media popup with a live visualizer, volume mixer |
| Wallpaper | awww | Random slideshow every 30 minutes |
| Monitoring | btop, cava | |
| Cursor | Bibata Modern Classic | |
| Icons | Papirus Dark | |

## Theme

One palette across the whole system. The base stays monochrome and blue is the
only accent.

| Role | Colour |
| --- | --- |
| Background | `#000000` and `#0d1117` |
| Surface | `#161b22` |
| Border | `#30363d` |
| Text | `#e6edf3` |
| Accent | `#58a6ff` |
| Success | `#3fb950` |
| Warning | `#d29922` |
| Error | `#ff7b72` |

## Requirements

Arch Linux, and an AUR helper (`yay` or `paru`) for the three packages that are
not in the official repositories. The full list lives in `packages/pacman.txt`
and `packages/aur.txt`.

## Install

```sh
git clone git@github.com:dafagareth/dotfiles.git
cd dotfiles
./install.sh
```

The installer will:

1. Install the packages listed under `packages/`.
2. Copy any config it is about to replace into `~/.dotfiles-backup/<timestamp>/`.
3. Copy the configs into `~/.config` and `~/.zshrc`.
4. Enable `power-profiles-daemon` and the user `ssh-agent` service.

Nothing is deleted. If you do not like the result, the backup folder holds your
previous setup.

Useful flags:

```sh
./install.sh --dry-run       # print what would happen, change nothing
./install.sh --no-packages   # copy the configs only
```

After installing, drop a wallpaper into `~/Pictures/Wallpapers/` and log back
into Hyprland so the autostart entries take effect.

## Shell setup

The zsh config expects oh-my-zsh and two plugins. They are not vendored here,
because they are clones of public repositories rather than personal config.

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
git clone https://github.com/zsh-users/zsh-autosuggestions     "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
```

## Keybindings

`Super` is the modifier throughout. `Alt` is deliberately unused, so your hand
never has to leave its resting position.

### Applications

| Keys | Action |
| --- | --- |
| `Super` `Return` | Terminal |
| `Super` `B` | Browser |
| `Super` `E` | File manager |
| `Super` `C` | VSCodium |
| `Super` `N` | Notes |
| `Super` `D` | Application launcher |

### Windows

| Keys | Action |
| --- | --- |
| `Super` `Q` | Close window |
| `Super` `V` | Toggle floating |
| `Super` `arrows` | Move focus |
| `Super` `Ctrl` `H J K L` | Resize |
| `Super` `'` or `` ` `` | Cycle to the next window |
| `Super` `Shift` `'` | Cycle backwards |
| `Super` `Tab` | Window switcher across all workspaces |
| `Super` `1` to `5` | Switch workspace |
| `Super` `Z` | Minimize to a scratch workspace |
| `Super` `S` | Scratchpad |

### Desktop

| Keys | Action |
| --- | --- |
| `Super` `A` | Show or hide the dock |
| `Super` `Shift` `A` | Pin or unpin an app on the dock |
| `Super` `W` | Wallpaper picker |
| `Super` `L` | Lock the screen |
| `Super` `X` | Power menu |
| `Super` `Shift` `B` | Cycle the power profile |
| `Super` `Shift` `P` | Colour picker, copies the hex to the clipboard |
| `Super` `Shift` `V` | Clipboard history |
| `Print` | Screenshot the whole screen |
| `Shift` `Print` | Screenshot a region, then annotate |

### Notifications

| Keys | Action |
| --- | --- |
| `Super` `Shift` `N` | Open the notification panel |
| `Super` `Shift` `D` | Toggle do not disturb |
| `Super` `Shift` `C` | Dismiss all notifications |

## Waybar modules

The media icon only appears while something is playing. Clicking a module opens
an eww popup rather than a plain tooltip.

| Module | Left click | Middle click | Right click | Scroll |
| --- | --- | --- | --- | --- |
| Media | Popup with album art, a live cava visualizer and transport controls | Play or pause | | Next or previous track |
| Volume | Popup with sliders for the speaker, the microphone and each running app | pavucontrol | Mute | Volume up or down |
| Power profile | Cycle performance, balanced, power saver | | | |

## Structure

```
.
├── config/       copied to ~/.config
├── home/         copied to ~ (currently just zshrc)
├── packages/     package lists, split by repository
├── install.sh
└── README.md
```

## What this repository does not contain

Credentials are never committed. These stay on the machine and are not tracked:

- `~/.ssh` and `~/.gnupg`, which hold private keys.
- `~/.config/gh/hosts.yml`, which holds a GitHub token in plain text.
- Any `.env` file, API key or personal document.

If you fork this, keep it that way.

## Notes on the Hyprland config

It is written in Lua rather than hyprlang. A few things behave differently from
the usual setup and are worth knowing before you edit it.

- Dispatchers are called as `hl.dsp.*`. A bare string such as
  `hyprctl dispatch exit` is parsed as Lua and fails. Use
  `hyprctl dispatch 'hl.dsp.exit()'` instead.
- Bindings use keysym names. `code:48` is not supported, and a binding that
  uses it is dropped silently.
- Check for conflicts with `hyprctl binds`. Grepping the config misses them,
  because bindings are written as `mainMod .. " + KEY"`.
- `hl.dsp.dpms("on")` returns `ok` but toggles rather than turns the display
  on. The argument has to be a table with an `action` field.
