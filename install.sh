#!/usr/bin/env bash

set -o pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

confirm_prompt () {
    local prompt="$1 [y/N] "
    local REPLY

    # sets the default response var to $REPLY
    # -n reads 1 char and doesnt need to press enter
    read -r -p "$prompt" -n 1 REPLY || return 1
    echo

    # =~ is for regex match
    # this will already return 0 if true or 1 if not true
    [[ $REPLY =~ ^[Yy]$ ]]
}

run_catch_error () {
    if ! "$@"; then
        echo "Error: Installation failed: $@" >&2
        exit 1
    fi
}

install_core () {
    if ! paru -S --needed \
        mangowm kitty fuzzel mangobar wl-clipboard \
        grim slurp wlogout xorg-xwayland xlockmore \
        dunst swayidle copyq wtype ttf-roboto \
        ttf-roboto-slab maplemono-nf \
        ttf-nerd-fonts-symbols; then
        echo "Failed to install core packages." >&2
        return 1
    fi

    local configs=("mango" "kitty" "mangobar" "fuzzel" "wlogout" "dunst" "fontconfig")

    for config in "${configs[@]}"; do
        local source="$SCRIPT_DIR/.config/$config"
        local dest="$HOME/.config/$config"

        if [[ -e "$dest" ]]; then
            echo "Configuration for $config already exists at $dest. Skipping." >&2
            continue
        fi

        if [[ ! -d "$source" ]]; then
            echo "Configuration source for $config not found: $source." >&2
            continue
        fi

        if ! mkdir -p "$dest"; then
            echo "Failed to make configuration directory $dest." >&2
            continue
        fi

        if ! cp -r "$source/." "$dest/"; then
            echo "Failed to copy $config configuration into $dest." >&2
            continue
        fi

        echo "Successfully installed $config configuration."
    done
}

install_bluetooth () {
    echo "Installing Bluetooth packages..."

    if ! sudo pacman --noconfirm -S --needed bluez bluez-utils blueman; then
        echo "Failed to install Bluetooth packages." >&2
        return 1
    fi

    if ! sudo systemctl enable --now bluetooth.service; then
        echo "Failed to enable Bluetooth service." >&2
        return 1
    fi

    echo "Bluetooth and Blueman installed successfully."
}

install_networkmanager () {
    echo "Installing NetworkManager and applet..."

    if ! sudo pacman --noconfirm -S --needed \
        networkmanager network-manager-applet; then
        echo "Failed to install NetworkManager packages." >&2
        return 1
    fi

    echo "Enabling NetworkManager service..."

    if ! sudo systemctl enable --now NetworkManager.service; then
        echo "Failed to enable NetworkManager." >&2
        return 1
    fi

    echo "NetworkManager and applet installed successfully."
}

install_shell_config () {
    echo "Installing Zsh and packages..."

    if ! paru -S --needed zsh \
        zsh-fast-syntax-highlighting \
        zsh-vi-mode \
        zsh-auto-venv-git \
        eza \
        starship; then
        echo "Failed to install Zsh packages." >&2
        return 1
    fi

    if [[ -e "$HOME/.zshrc" ]]; then
        echo "ZSH configuration already exists at $HOME/.zshrc." >&2
        echo "Move it before installing this configuration." >&@
        return 1
    fi

    if ! cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"; then
        echo "Failed to copy Zsh configuration." >&2
        return 1
    fi

    echo "Zsh installed successfully."
}

install_neovim_config () {
    if [[ -e "$HOME/.config/nvim" ]]; then
        echo "Neovim configuration already exists at $HOME/.config/nvim." >&2
        echo "Move it before installing this configuration." >&2
        return 1
    fi

    echo "Installing Neovim configuration..."

    if ! paru -S --needed neovim-nightly-bin \
        tree-sitter \
        tree-sitter-cli \
        rustup \
        nodejs-n \
        git; then
        echo "Failed to install Neovim packages." >&2
        return 1
    fi

    echo "Installing Rust..."

    if ! rustup default stable; then
        echo "Failed to install Rust." >&2
        return 1
    fi

    echo "Installing Nodejs..."

    if ! sudo n i latest; then
        echo "Failed to install Nodejs." >&2
        return 1
    fi

    if ! git clone https://github.com/nautrw/nvim "$HOME/.config/nvim"; then
        echo "Failed to clone Neovim configuration." >&2
        return 1
    fi

    echo "Successfully installed Neovim configuration."
}

install_app_theming () {
    echo "Installing and setting app theming..."

    if [[ -e "$HOME/.config/qt6ct" ]]; then
        echo "Error: Qt6ct configuration already exists at $HOME/.config/qt6ct." >&2
        echo "Move it before installing this configuration." >&@
        return 1
    fi

    if ! paru -S --needed glib2 \
        kvantum \
        kvantum-qt5 \
        kvantum-theme-libadwaita-git \
        qt6ct \
        qt5ct; then
        echo "Failed to install app theming packages." >&2
        return 1
    fi

    echo "Setting GTK apps to Adwaita dark mode..."

    if ! gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'; then
        echo "Failed to set dark colorschemes." >&2
        return 1
    fi

    if ! gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'; then
        echo "Failed to set GTK3 theme to Adwaita dark." >&2
        return 1
    fi

    if ! gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'; then
        echo "Failed to set GTK icon theme to Adwaita." >&2
        return 1
    fi

    echo "Setting QT app theming to LibAdwaita..."

    local kvantum_config="$HOME/.config/Kvantum/kvantum.kvconfig"

    if ! mkdir -p "${kvantum_config%/*}"; then
        echo "Failed to create Kvantum configuration directory." >&2
        return 1
    fi

    # if ! kvantummanager --set KvLibadwaitaDark; then
    #     echo "Failed to set Kvantum Manager theme to Adwaita Dark." >&2
    #     return 1
    # fi

    if ! cat > "$kvantum_config" <<'EOF'
[General]
theme=KvLibadwaitaDark
EOF
    then
        echo "Failed to set Kvantum Manager theme to Adwaita Dark." >&2
        return 1
    fi

    if ! cp -r "$SCRIPT_DIR/.config/qt6ct" "$HOME/.config"; then
        echo "Failed to copy qt6ct configuration into $HOME/.config/qt6ct." >&2
        return 1
    fi

    if ! touch "$HOME/.zprofile"; then
        echo "Failed to create $HOME/.zprofile" >&2
        return 1
    fi

    # grep checks if the line already exists
    if ! grep -qxF 'export QT_QPA_PLATFORMTHEME=qt6ct' "$HOME/.zprofile"; then
        echo 'export QT_QPA_PLATFORMTHEME=qt6ct' >> "$HOME/.zprofile" ||
            return 1
    fi

    echo "Successfully themed GTK and QT apps to Adwaita Dark."
}

install_optionals () {
    if confirm_prompt "Install v4l2loopback-dkms? (Allows for virtual camera support in OBS studio)"; then
        if ! paru -S --needed v4l2loopback-dkms; then
            echo "Failed to install v4l2loopback-dkms." >&2
        else
            echo "Successfully installed v4l2loopback-dkms."
        fi
    fi

    if confirm_prompt "Wayland XDG desktop portal utilities? (Window picker for screenshare)"; then
        if ! paru -S --needed xdg-desktop-portal-wlr \
            wlr-utils-bin \
            tesseract-data-eng; then
            echo "Failed to install Wayland XDG desktop portal utilities." >&2
        elif ! cp -r "$SCRIPT_DIR/.config/xdg-desktop-portal-wlr" "$HOME/.config"; then
            echo "Failed to copy Wayland XDG deskto portal configuration to $HOME/.config/xdg-desktop-portal-wlr." >&2
        else
            echo "Successfully installed Wayland XDG desktop portal utilities."
        fi
    fi

    if confirm_prompt "Install yazi and set it as the terminal file chooser? (Terminal file manager)"; then
        if ! paru -S --needed yazi xdg-desktop-portal-termfilechooser-hunkyburrito-git; then
            echo "Failed to install yazi packages." >&2;
        elif ! cp -r "$SCRIPT_DIR/.config/xdg-desktop-portal-termfilechooser" "$HOME/.config"; then
            echo "Failed to copy terminal file chooser XDG desktop portal configuration to $HOME/.config/xdg-desktop-portal-termfilechooser." >&2
        elif ! ya pkg install; then
            echo "Failed to install Yazi packages." >&2;
        else
            echo "Successfully installed Yazi."
        fi
    fi
}

# using () instead of {} runs in a subshell, so all directory changes are isolatedl;
# don't have to cd back when done
install_paru () (
    sudo -v || return 1

    local tmpdir="$(mktemp -d)" || return 1
    trap 'rm -rf -- "$TMPDIR"' EXIT

    sudo pacman -S --needed --noconfirm rustup || return 1
    rustup default stable || return 1

    git clone https://aur.archlinux.org/paru.git "$tmpdir/paru" || return 1
    cd "$tmpdir/paru" || return 1
    makepkg -si || return 1
)

if ! sudo -n true 2>/dev/null; then
    echo "No sudo access, prompting..."

    if ! sudo -v; then
        echo "Error: no sudo authentication." >&2
        exit 1
    fi
fi

if ! command -v paru; then
    if ! confirm_prompt "Paru is required for this installation script. Install it?"; then
        echo "Paru is required. Exiting." >&2
        exit 1
    fi

    run_catch_error install_paru
fi

echo "1. Full dotfiles (Rice, ZSH, Neovim, NetworkManager & Applet, Bluetooth & Applet, Optionals)"
echo "2. Only rice & theming"
echo "3. Minimal (ZSH, Neovim)"
echo "4. Adwaita theming"
read -r -p "What mode would you like to install? " choice

case $choice in 
    "1") 
        echo "You have chosen the full dotfiles option. Proceeding to install..."
        run_catch_error install_core
        run_catch_error install_bluetooth 
        run_catch_error install_networkmanager 
        run_catch_error install_shell_config 
        run_catch_error install_neovim_config 
        run_catch_error install_app_theming
        run_catch_error install_optionals
        ;;
    "2")
        echo "You have chosen the rice & theming option. Proceeding to install..."
        run_catch_error install_core 
        run_catch_error install_app_theming
        ;;
    "3")
        echo "You have chosen the minimal option. Proceeding to install..."
        run_catch_error install_shell_config 
        run_catch_error install_neovim_config 
        ;;
    "4")
        echo "You have chosen the Adwaita theming option. Proceeding to install..."
        run_catch_error install_app_theming
        ;;
    *)
        echo "Invalid option chosen. Exiting." >&2
        exit 1
        ;;
esac
