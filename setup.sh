#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup/$(date +%Y%m%d-%H%M%S)"

CONFIGS=(
    hypr kitty matugen nvim rofi waybar wlogout
)

# Core desktop and configuration utilities
PACKAGES=(
    hyprland
    kitty
    neovim
    waybar
    wlogout
    rofi-wayland

    # Hyprland utilities
    hyprpaper
    hyprlock
    hypridle
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    polkit-kde-agent

    # Clipboard, screenshots, notifications
    wl-clipboard
    cliphist
    grim
    slurp
    swappy
    mako
    brightnessctl
    playerctl
    pavucontrol
    pipewire
    pipewire-pulse
    wireplumber

    # Fonts and icons
    ttf-jetbrains-mono-nerd
    noto-fonts
    noto-fonts-emoji
    ttf-font-awesome

    # Tools used by configuration scripts
    git
    curl
    wget
    jq
    unzip
    zip
    imagemagick
    python
    python-pip
    ripgrep
    fd
    fzf
    tree
)

AUR_PACKAGES=(
    matugen
)

install_packages() {
    if ! command -v pacman >/dev/null 2>&1; then
        echo "This script currently supports Arch-based systems only."
        exit 1
    fi

    sudo pacman -Syu --needed "${PACKAGES[@]}"

    local aur_helper=""
    if command -v yay >/dev/null 2>&1; then
        aur_helper="yay"
    elif command -v paru >/dev/null 2>&1; then
        aur_helper="paru"
    fi

    if [[ -n "$aur_helper" ]]; then
        "$aur_helper" -S --needed "${AUR_PACKAGES[@]}"
    else
        echo "Install an AUR helper (yay or paru), then install:"
        printf '  %s\n' "${AUR_PACKAGES[@]}"
    fi
}

copy_configs() {
    mkdir -p "$CONFIG_DIR"

    for name in "${CONFIGS[@]}"; do
        local src="$SCRIPT_DIR/$name"
        local dest="$CONFIG_DIR/$name"

        if [[ ! -d "$src" ]]; then
            echo "Skipping missing directory: $name"
            continue
        fi

        if [[ -e "$dest" || -L "$dest" ]]; then
            mkdir -p "$BACKUP_DIR"
            mv -- "$dest" "$BACKUP_DIR/$name"
        fi

        cp -a -- "$src" "$dest"
        echo "Installed config: $name"
    done

    if [[ -d "$BACKUP_DIR" ]]; then
        echo "Previous configs backed up to: $BACKUP_DIR"
    fi
}

main() {
    install_packages
    copy_configs

    mkdir -p "$HOME/.local/bin"
    cp walset "$HOME/.local/bin/"

    echo
    echo "Base setup complete."
    echo "Review your configs for additional dependencies."
    echo "You may need to log out and select Hyprland at the login screen."
}

main "$@"
