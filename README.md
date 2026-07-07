# dotfiles

Backup dotfiles pribadi (Arch Linux + Hyprland). Repo ini pakai teknik **bare git repo**
yang langsung nge-track file di `$HOME` — bukan symlink, bukan copy ke folder lain.

## Isi repo

- Shell: `.zshrc`, `.bashrc`, `.bash_profile`
- Git: `.gitconfig`, `.config/git/ignore`
- Desktop (Hyprland/Wayland): `.config/hypr`, `.config/waybar`, `.config/wofi`,
  `.config/kanshi`, `.config/swaylock`, `.config/hyprpaper`
- Theming: `.gtkrc-2.0`, `.config/gtk-2.0`, `.config/gtk-3.0`, `.config/gtk-4.0`,
  `.config/qt6ct`, `.config/Kvantum`, `.config/nwg-look`
- Terminal tools: `.config/btop`, `.config/htop`, `.config/ranger`, `.config/lazygit`,
  `.config/cava`, `.config/calcure`, `.config/calcurse`
- Lain-lain: `.npmrc`, `.nvidia-settings-rc`

**Sengaja TIDAK di-backup di sini:**
- `.ssh`, `.gnupg` — private key, jangan pernah taruh di git.
- `.bootdev.yaml`, `.config/ngrok/ngrok.yml` — ada access token/authtoken asli.
- `.oh-my-zsh/custom/*` — cuma clone plugin/tema publik, lihat bagian [Oh My Zsh](#oh-my-zsh--plugin--tema) buat install ulang.

## Cara restore ke instalasi Arch baru

```bash
# 1. Clone sebagai bare repo
git clone --bare https://github.com/dafagareth/dotfiles.git "$HOME/.dotfiles"

# 2. Bikin alias sementara buat checkout awal
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# 3. Jangan tampilkan semua file $HOME sebagai untracked
dotfiles config --local status.showUntrackedFiles no

# 4. Coba checkout. Kalau fresh install biasanya aman langsung checkout.
#    Kalau ada file bawaan yang bentrok (mis. .bashrc default distro),
#    backup dulu file itu baru checkout ulang:
mkdir -p .dotfiles-backup
dotfiles checkout 2>&1 | grep -E "^\s+\." | awk '{print $1}' | \
  xargs -I{} mv {} .dotfiles-backup/{}
dotfiles checkout
```

Setelah checkout sukses, alias `dotfiles` juga otomatis ikut ke-restore
(sudah ditambahkan permanen di `.zshrc`), jadi ke depannya tinggal pakai
`dotfiles add/commit/push` seperti git biasa buat nambah dotfiles baru.

## Paket yang perlu diinstall

### Base & shell

```bash
sudo pacman -S --needed zsh git base-devel curl wget
```

### AUR helper (kalau belum ada)

```bash
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay && makepkg -si
```

### Hyprland & desktop Wayland

```bash
sudo pacman -S --needed hyprland waybar wofi kanshi hypridle hyprpaper \
  swaylock swaybg xdg-desktop-portal-hyprland thunar firefox kitty
yay -S --needed hyprpolkitagent
```

### Theming

```bash
sudo pacman -S --needed qt6ct gnome-themes-extra
yay -S --needed nwg-look kvantum-qt6 breeze breeze-gtk breeze-icons \
  papirus-icon-theme
```

### Terminal tools

```bash
sudo pacman -S --needed btop htop ranger lazygit cava calcurse mpv libnotify
yay -S --needed calcure termdown
```

### Font

```bash
yay -S --needed ttf-jetbrains-mono-nerd
```

### GPU (kalau pakai NVIDIA seperti mesin ini)

```bash
sudo pacman -S --needed nvidia nvidia-utils nvidia-settings
```

## Oh My Zsh + plugin + tema

Framework dan plugin oh-my-zsh sengaja tidak masuk repo dotfiles (isinya
clone dari repo publik orang lain, bukan config pribadi). Install manual:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
```

`.zshrc` yang sudah di-restore otomatis pakai tema & plugin di atas
(`plugins=(... zsh-autosuggestions zsh-syntax-highlighting zsh-completions history-substring-search)`).

## Setelah restore

```bash
# Login GitHub CLI (dipakai sebagai git credential helper di .gitconfig)
gh auth login

source ~/.zshrc
```

Cek juga file yang di-skip di atas (`.bootdev.yaml`, `.config/ngrok/ngrok.yml`) —
kalau masih dipakai, isi ulang manual dengan token yang masih valid.
