#!/usr/bin/env bash
#
# Installer for this Hyprland dotfiles setup on Arch Linux.
#
# What it does:
#   1. Installs the required packages (official repos, then AUR).
#   2. Backs up any config it is about to overwrite.
#   3. Copies the configs into place.
#   4. Enables the user services the setup relies on.
#
# It never touches credentials. No SSH keys, no GPG keys, no tokens.
#
# Usage:
#   ./install.sh              full install
#   ./install.sh --no-packages   skip package installation, copy configs only
#   ./install.sh --dry-run       show what would happen, change nothing

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=false
SKIP_PACKAGES=false

for arg in "$@"; do
    case "$arg" in
        --dry-run)     DRY_RUN=true ;;
        --no-packages) SKIP_PACKAGES=true ;;
        -h|--help)     sed -n '2,20p' "$0"; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; exit 1 ;;
    esac
done

# ── helpers ───────────────────────────────────────────────────────────────

c_info()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
c_ok()    { printf '\033[1;32m ok\033[0m %s\n' "$*"; }
c_warn()  { printf '\033[1;33m  !\033[0m %s\n' "$*"; }
c_error() { printf '\033[1;31m  x\033[0m %s\n' "$*" >&2; }

run() {
    if $DRY_RUN; then
        printf '   would run: %s\n' "$*"
    else
        "$@"
    fi
}

# ── sanity checks ─────────────────────────────────────────────────────────

if [[ ! -f /etc/arch-release ]]; then
    c_error "This installer targets Arch Linux. Other distros are not supported."
    exit 1
fi

if [[ $EUID -eq 0 ]]; then
    c_error "Do not run this as root. It installs into your own home directory."
    exit 1
fi

if $DRY_RUN; then
    c_warn "Dry run. Nothing will be changed."
fi

# ── 1. packages ───────────────────────────────────────────────────────────

install_packages() {
    c_info "Installing packages from the official repositories"
    mapfile -t pac < <(grep -vE '^\s*(#|$)' "$REPO_DIR/packages/pacman.txt")
    run sudo pacman -S --needed --noconfirm "${pac[@]}"
    c_ok "Official packages installed"

    local helper=""
    for h in yay paru; do
        command -v "$h" >/dev/null 2>&1 && { helper="$h"; break; }
    done

    if [[ -z "$helper" ]]; then
        c_warn "No AUR helper found (yay or paru)."
        c_warn "Install one, then run: \$helper -S --needed $(tr '\n' ' ' < "$REPO_DIR/packages/aur.txt")"
        return
    fi

    c_info "Installing AUR packages with $helper"
    mapfile -t aur < <(grep -vE '^\s*(#|$)' "$REPO_DIR/packages/aur.txt")
    run "$helper" -S --needed --noconfirm "${aur[@]}"
    c_ok "AUR packages installed"
}

# ── 2. configs ────────────────────────────────────────────────────────────

backup_then_copy() {
    local src="$1" dest="$2"

    if [[ -e "$dest" ]]; then
        local rel="${dest#"$HOME"/}"
        run mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
        run cp -r "$dest" "$BACKUP_DIR/$rel"
    fi

    run mkdir -p "$(dirname "$dest")"
    run rm -rf "$dest"
    run cp -r "$src" "$dest"
}

install_configs() {
    c_info "Backing up existing configs to ${BACKUP_DIR/#$HOME/\~}"

    local entry name
    for entry in "$REPO_DIR"/config/*; do
        name="$(basename "$entry")"
        backup_then_copy "$entry" "$HOME/.config/$name"
        c_ok ".config/$name"
    done

    backup_then_copy "$REPO_DIR/home/zshrc" "$HOME/.zshrc"
    c_ok ".zshrc"

    # scripts must stay executable
    run chmod +x "$HOME"/.config/hypr/scripts/*.sh 2>/dev/null || true
    run chmod +x "$HOME"/.config/hypr/scripts/*.py 2>/dev/null || true
    run chmod +x "$HOME"/.config/eww/scripts/*.sh  2>/dev/null || true
    run chmod +x "$HOME"/.config/hypr/*.sh         2>/dev/null || true
    run chmod +x "$HOME"/.config/waybar/*.sh       2>/dev/null || true
}

# ── 3. services ───────────────────────────────────────────────────────────

enable_services() {
    c_info "Enabling services"

    if systemctl list-unit-files power-profiles-daemon.service >/dev/null 2>&1; then
        run sudo systemctl enable --now power-profiles-daemon.service
        c_ok "power-profiles-daemon (needed by the Waybar power module)"
    fi

    if [[ -f "$HOME/.config/systemd/user/ssh-agent.service" ]]; then
        run systemctl --user daemon-reload
        run systemctl --user enable --now ssh-agent.service
        c_ok "ssh-agent (remembers your SSH key passphrase per session)"
    fi
}

# ── run ───────────────────────────────────────────────────────────────────

echo
c_info "Hyprland dotfiles installer"
echo

if ! $SKIP_PACKAGES; then
    install_packages
else
    c_warn "Skipping package installation (--no-packages)"
fi

echo
install_configs
echo
enable_services

echo
c_ok "Done."
echo
cat <<'EOF'
Next steps:

  1. Put a wallpaper at ~/Pictures/Wallpapers/. Any jpg or png will do.
     The slideshow rotates through that folder every 30 minutes.

  2. Log out and back into Hyprland so the autostart entries take effect.

  3. Optional. The zsh config expects oh-my-zsh with the
     zsh-autosuggestions and zsh-syntax-highlighting plugins.

Your previous configs were backed up. Nothing was deleted.
EOF
