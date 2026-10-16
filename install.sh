#!/usr/bin/env bash

source ./install/utils.sh

set -e # will exit if any command returns non-zero status

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

sudo_keepalive 


install_core () {
    if ! paru -S --needed \
        mangowm kitty fuzzel mangobar wl-clipboard \
        grim slurp wlogout xorg-xwayland xlockmore \
        dunst swayidle copyq wtype ttf-roboto \
        ttf-roboto-slab maplemono-nf \
        ttf-nerd-fonts-symbols; then
        log_error "Failed to install core packages."
        return 1
    fi

    local configs=("mango" "kitty" "mangobar" "fuzzel" "wlogout" "dunst" "fontconfig")

    for config in "${configs[@]}"; do
        local source="$SCRIPT_DIR/.config/$config"
        local dest="$HOME/.config/$config"

        if [[ -e "$dest" ]]; then
            log_error "Configuration for $config already exists at $dest. Skipping."
            continue
        fi

        if [[ ! -d "$source" ]]; then
            log_error "Configuration source for $config not found: $source."
            continue
        fi

        if ! mkdir -p "$dest"; then
            log_error "Failed to make configuration directory $dest."
            continue
        fi

        if ! cp -r "$source/." "$dest/"; then
            log_error "Failed to copy $config configuration into $dest."
            continue
        fi

        log_success "Successfully installed $config configuration."
    done
}

install_bluetooth () {
    log_info "Installing Bluetooth packages..."

    if ! sudo pacman --noconfirm -S --needed bluez bluez-utils blueman; then
        log_error "Failed to install Bluetooth packages."
        return 1
    fi

    if ! sudo systemctl enable --now bluetooth.service; then
        log_error "Failed to enable Bluetooth service."
        return 1
    fi

    log_success "Bluetooth and Blueman installed successfully."
}

install_networkmanager () {
    log_info "Installing NetworkManager and applet..."

    if ! sudo pacman --noconfirm -S --needed \
        networkmanager network-manager-applet; then
        log_error "Failed to install NetworkManager packages."
        return 1
    fi

    log_info "Enabling NetworkManager service..."

    if ! sudo systemctl enable --now NetworkManager.service; then
        log_error "Failed to enable NetworkManager."
        return 1
    fi

    log_success "NetworkManager and applet installed successfully."
}

install_shell_config () {
    echo "Installing Zsh and packages..."

    if ! paru -S --needed zsh \
        zsh-fast-syntax-highlighting \
        zsh-vi-mode \
        zsh-auto-venv-git \
        eza \
        starship; then
        log_error "Failed to install Zsh packages."
        return 1
    fi

    if [[ -e "$HOME/.zshrc" ]]; then
        log_error "ZSH configuration already exists at $HOME/.zshrc."
        log_error "Move it before installing this configuration."
        return 1
    fi

    if ! cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"; then
        log_error "Failed to copy Zsh configuration."
        return 1
    fi

    log_success "Zsh installed successfully."
}

install_neovim_config () {
    if [[ -e "$HOME/.config/nvim" ]]; then
        log_error "Neovim configuration already exists at $HOME/.config/nvim."
        log_error "Move it before installing this configuration."
        return 1
    fi

    log_info "Installing Neovim configuration..."

    if ! paru -S --needed neovim-nightly-bin \
        tree-sitter \
        tree-sitter-cli \
        rustup \
        nodejs-n \
        git; then
        log_error "Failed to install Neovim packages."
        return 1
    fi

    log_info "Installing Rust..."

    if ! rustup default stable; then
        log_error "Failed to install Rust."
        return 1
    fi

    log_info "Installing Nodejs..."

    if ! sudo n i latest; then
        log_error "Failed to install Nodejs."
        return 1
    fi

    if ! git clone https://github.com/nautrw/nvim "$HOME/.config/nvim"; then
        log_error "Failed to clone Neovim configuration."
        return 1
    fi

    log_success "Successfully installed Neovim configuration."
}

install_app_theming () {
    log_info "Installing and setting app theming..."

    if [[ -e "$HOME/.config/qt6ct" ]]; then
        log_error "Qt6ct configuration already exists at $HOME/.config/qt6ct."
        log_error "Move it before installing this configuration."
        return 1
    fi

    if ! paru -S --needed glib2 \
        kvantum \
        kvantum-qt5 \
        kvantum-theme-libadwaita-git \
        qt6ct \
        qt5ct; then
        log_error "Failed to install app theming packages."
        return 1
    fi

    log_info "Setting GTK apps to Adwaita dark mode..."

    if ! gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'; then
        log_error "Failed to set dark colorschemes."
        return 1
    fi

    if ! gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'; then
        log_error "Failed to set GTK3 theme to Adwaita dark."
        return 1
    fi

    if ! gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'; then
        log_error "Failed to set GTK icon theme to Adwaita."
        return 1
    fi

    log_info "Setting QT app theming to LibAdwaita..."

    local kvantum_config="$HOME/.config/Kvantum/kvantum.kvconfig"

    if ! mkdir -p "${kvantum_config%/*}"; then
        log_error "Failed to create Kvantum configuration directory."
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
        log_error "Failed to set Kvantum Manager theme to Adwaita Dark."
        return 1
    fi

    if ! cp -r "$SCRIPT_DIR/.config/qt6ct" "$HOME/.config"; then
        log_error "Failed to copy qt6ct configuration into $HOME/.config/qt6ct."
        return 1
    fi

    if ! touch "$HOME/.zprofile"; then
        log_error "Failed to create $HOME/.zprofile"
        return 1
    fi

    # grep checks if the line already exists
    if ! grep -qxF 'export QT_QPA_PLATFORMTHEME=qt6ct' "$HOME/.zprofile"; then
        if ! echo 'export QT_QPA_PLATFORMTHEME=qt6ct' >> "$HOME/.zprofile"; then
            log_error "Failed to set QT_QPA_PLATFORMTHEME=qt6ct in $HOME/.zprofile"
    fi

    log_success "Successfully themed GTK and QT apps to Adwaita Dark."
}

install_optionals () {
    if confirm_prompt "Install v4l2loopback-dkms? (Allows for virtual camera support in OBS studio)"; then
        if ! paru -S --needed v4l2loopback-dkms; then
            log_error "Failed to install v4l2loopback-dkms."
        else
            log_success "Successfully installed v4l2loopback-dkms."
        fi
    fi

    if confirm_prompt "Wayland XDG desktop portal utilities? (Window picker for screenshare)"; then
        if ! paru -S --needed xdg-desktop-portal-wlr \
            wlr-utils-bin \
            tesseract-data-eng; then
            log_error "Failed to install Wayland XDG desktop portal utilities."
        elif ! cp -r "$SCRIPT_DIR/.config/xdg-desktop-portal-wlr" "$HOME/.config"; then
            log_error "Failed to copy Wayland XDG deskto portal configuration to $HOME/.config/xdg-desktop-portal-wlr."
        else
            log_success "Successfully installed Wayland XDG desktop portal utilities."
        fi
    fi

    if confirm_prompt "Install yazi and set it as the terminal file chooser? (Terminal file manager)"; then
        if ! paru -S --needed yazi xdg-desktop-portal-termfilechooser-hunkyburrito-git; then
            log_error "Failed to install yazi packages." 
        elif ! cp -r "$SCRIPT_DIR/.config/xdg-desktop-portal-termfilechooser" "$HOME/.config"; then
            log_error "Failed to copy terminal file chooser XDG desktop portal configuration to $HOME/.config/xdg-desktop-portal-termfilechooser."
        elif ! ya pkg install; then
            log_error "Failed to install Yazi packages." 
        else
            log_success "Successfully installed Yazi."
        fi
    fi
}

# using () instead of {} runs in a subshell, so all directory changes are isolatedl;
# don't have to cd back when done
install_paru () (
    if ! local tmpdir="$(mktemp -d)"; then
        log_error "Failed to create temporary directory"
    fi

    trap 'rm -rf -- "$TMPDIR"' EXIT || return 1

    if ! sudo pacman -S --needed --noconfirm rustup; then
        log_error "Failed to install the rustup package"
    fi

    if ! rustup default stable; then
        log_error "Failed to install rust"
    fi

    if ! git clone https://aur.archlinux.org/paru.git "$tmpdir/paru"; then
        log_error "Failed to clone the paru repository from the AUR"
    fi

    if ! cd "$tmpdir/paru"; then
        log_error "Failed to CD into paru"
    fi

    if ! makepkg -si; then
        log_error "Failed to build paru"
    fi
)

install_sddm () {
    if ! confirm_prompt "Install SDDM to launch Mango?"; then
        return 1
    fi

    if ! paru -S --needed sddm; then
        log_error "Failed to install SDDM."
        return 1
    fi

    if ! sudo systemctl enable sddm; then
        log_error "Failed to enable the SDDM service."
        return 1
    fi
}

if ! command_exists "paru"; then
    if ! confirm_prompt "Paru is required for this installation script. Install it?"; then
        log_die "Paru is required. Exiting."
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
        log_info "You have chosen the full dotfiles option. Proceeding to install..."
        run_catch_error install_core
        run_catch_error install_bluetooth 
        run_catch_error install_networkmanager 
        run_catch_error install_shell_config 
        run_catch_error install_neovim_config 
        run_catch_error install_app_theming
        run_catch_error install_optionals
        run_catch_error install_sddm
        ;;
    "2")
        log_info "You have chosen the rice & theming option. Proceeding to install..."
        run_catch_error install_core 
        run_catch_error install_app_theming
        run_catch_error install_sddm
        ;;
    "3")
        log_info "You have chosen the minimal option. Proceeding to install..."
        run_catch_error install_shell_config 
        run_catch_error install_neovim_config 
        ;;
    "4")
        log_info "You have chosen the Adwaita theming option. Proceeding to install..."
        run_catch_error install_app_theming
        ;;
    *)
        log_die "Invalid option chosen. Exiting."
        ;;
esac

log_success "The installation was probably a success."
log_success "It is recommended that you reboot to apply all changes."
log_success "Read the README file for some post-install tips."
