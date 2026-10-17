#!/usr/bin/env bash

source ./lib/utils.sh

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

sudo_keepalive || exit 1


install_core() {
    log_info "Installing core packages..."

    user_ask_exec paru -S --needed \
        mangowm kitty fuzzel mangobar wl-clipboard \
        grim slurp wlogout xorg-xwayland xlockmore \
        dunst swayidle copyq wtype ttf-roboto \
        ttf-roboto-slab maplemono-nf \
        ttf-nerd-fonts-symbols || return 1

    local configs=(
        mango kitty mangobar fuzzel wlogout dunst fontconfig
    )
    local config source dest

    for config in "${configs[@]}"; do
        source="$SCRIPT_DIR/.config/$config"
        dest="$HOME/.config/$config"

        if [[ -e "$dest" ]]; then
            log_warning "Configuration for $config already exists at $dest. Skipping."
            continue
        fi

        if [[ ! -d "$source" ]]; then
            log_error "Configuration source for $config not found: $source."
            continue
        fi

        if ! user_ask_exec mkdir -p "$dest"; then
            log_error "Failed to create configuration directory $dest."
            continue
        fi

        if ! user_ask_exec cp -r "$source/." "$dest/"; then
            log_error "Failed to copy $config configuration into $dest."
            continue
        fi

        log_success "Successfully installed $config configuration."
    done
}


install_bluetooth() {
    log_info "Installing Bluetooth packages..."

    user_ask_exec sudo pacman --noconfirm -S --needed \
        bluez bluez-utils blueman || return 1

    user_ask_exec sudo systemctl enable --now bluetooth.service \
        || return 1

    log_success "Bluetooth and Blueman installed successfully."
}


install_networkmanager() {
    log_info "Installing NetworkManager and applet..."

    user_ask_exec sudo pacman --noconfirm -S --needed \
        networkmanager network-manager-applet || return 1

    log_info "Enabling NetworkManager service..."

    user_ask_exec sudo systemctl enable --now NetworkManager.service \
        || return 1

    log_success "NetworkManager and applet installed successfully."
}


install_shell_config() {
    log_info "Installing Zsh and packages..."

    user_ask_exec paru -S --needed \
        zsh \
        zsh-fast-syntax-highlighting \
        zsh-vi-mode \
        zsh-auto-venv-git \
        eza \
        starship || return 1

    if [[ -e "$HOME/.zshrc" ]]; then
        log_error "ZSH configuration already exists at $HOME/.zshrc."
        log_error "Move it before installing this configuration."
        return 1
    fi

    user_ask_exec cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc" \
        || return 1

    log_success "Zsh installed successfully."
}


install_neovim_config() {
    if [[ -e "$HOME/.config/nvim" ]]; then
        log_error "Neovim configuration already exists at $HOME/.config/nvim."
        log_error "Move it before installing this configuration."
        return 1
    fi

    log_info "Installing Neovim configuration..."

    user_ask_exec paru -S --needed \
        neovim-nightly-bin \
        tree-sitter \
        tree-sitter-cli \
        rustup \
        nodejs-n \
        git || return 1

    log_info "Installing Rust..."

    user_ask_exec rustup default stable || return 1

    log_info "Installing Node.js..."

    user_ask_exec sudo n i latest || return 1

    user_ask_exec git clone \
        https://github.com/nautrw/nvim \
        "$HOME/.config/nvim" || return 1

    log_success "Successfully installed Neovim configuration."
}


install_app_theming() {
    log_info "Installing and setting app theming..."

    if [[ -e "$HOME/.config/qt6ct" ]]; then
        log_error "Qt6ct configuration already exists at $HOME/.config/qt6ct."
        log_error "Move it before installing this configuration."
        return 1
    fi

    user_ask_exec paru -S --needed \
        glib2 \
        kvantum \
        kvantum-qt5 \
        kvantum-theme-libadwaita-git \
        qt6ct \
        qt5ct || return 1

    log_info "Setting GTK apps to Adwaita dark mode..."

    user_ask_exec gsettings set \
        org.gnome.desktop.interface color-scheme 'prefer-dark' \
        || return 1

    user_ask_exec gsettings set \
        org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' \
        || return 1

    user_ask_exec gsettings set \
        org.gnome.desktop.interface icon-theme 'Adwaita' \
        || return 1

    log_info "Setting Qt app theming to LibAdwaita..."

    local kvantum_config="$HOME/.config/Kvantum/kvantum.kvconfig"

    user_ask_exec mkdir -p "${kvantum_config%/*}" || return 1

    # Write the Kvantum configuration.
    write_kvantum_config() {
        cat > "$kvantum_config" <<'EOF'
[General]
theme=KvLibadwaitaDark
EOF
    }

    user_ask_exec write_kvantum_config || return 1

    user_ask_exec cp -r \
        "$SCRIPT_DIR/.config/qt6ct" \
        "$HOME/.config/qt6ct" || return 1

    user_ask_exec touch "$HOME/.zprofile" || return 1

    # Add the Qt platform theme setting only if it is not already present.
    if ! grep -qxF \
        'export QT_QPA_PLATFORMTHEME=qt6ct' "$HOME/.zprofile"; then
        user_ask_exec bash -c \
            'printf "%s\n" "export QT_QPA_PLATFORMTHEME=qt6ct" >> "$HOME/.zprofile"' \
            || return 1
    fi

    log_success "Successfully themed GTK and Qt apps to Adwaita Dark."
}


install_optionals() {
    if ask_confirm \
        "Install v4l2loopback-dkms? (Allows virtual camera support in OBS Studio)"; then

        if user_ask_exec paru -S --needed v4l2loopback-dkms; then
            log_success "Successfully installed v4l2loopback-dkms."
        else
            log_error "Failed to install v4l2loopback-dkms."
        fi
    fi

    if ask_confirm \
        "Install Wayland XDG desktop portal utilities? (Window picker for screensharing)"; then

        if user_ask_exec paru -S --needed \
            xdg-desktop-portal-wlr \
            wlr-utils-bin \
            tesseract-data-eng; then

            if user_ask_exec cp -r \
                "$SCRIPT_DIR/.config/xdg-desktop-portal-wlr" \
                "$HOME/.config/xdg-desktop-portal-wlr"; then
                log_success "Successfully installed Wayland XDG desktop portal utilities."
            else
                log_error "Failed to copy Wayland XDG desktop portal configuration."
            fi
        else
            log_error "Failed to install Wayland XDG desktop portal utilities."
        fi
    fi

    if ask_confirm \
        "Install Yazi and set it as the terminal file chooser? (Terminal file manager)"; then

        if user_ask_exec paru -S --needed \
            yazi xdg-desktop-portal-termfilechooser-hunkyburrito-git; then

            if user_ask_exec cp -r \
                "$SCRIPT_DIR/.config/xdg-desktop-portal-termfilechooser" \
                "$HOME/.config/xdg-desktop-portal-termfilechooser"; then

                if user_ask_exec ya pkg install; then
                    log_success "Successfully installed Yazi."
                else
                    log_error "Failed to install Yazi packages."
                fi
            else
                log_error "Failed to copy terminal file chooser configuration."
            fi
        else
            log_error "Failed to install Yazi packages."
        fi
    fi
}


# Use a subshell to isolate directory changes and local variables.
install_paru() (
    local tmpdir

    if ! tmpdir="$(mktemp -d)"; then
        log_error "Failed to create temporary directory."
        return 1
    fi

    trap 'rm -rf -- "$tmpdir"' EXIT

    user_ask_exec sudo pacman -S --needed --noconfirm rustup \
        || return 1

    user_ask_exec rustup default stable || return 1

    user_ask_exec git clone \
        https://aur.archlinux.org/paru.git "$tmpdir/paru" \
        || return 1

    user_ask_exec makepkg -si --noconfirm \
        --dir "$tmpdir/paru" 2>/dev/null
)


install_sddm() {
    if ! ask_confirm "Install SDDM to launch Mango?"; then
        log_info "Skipping SDDM installation."
        return 0
    fi

    user_ask_exec paru -S --needed sddm || return 1

    user_ask_exec sudo systemctl enable sddm || return 1

    log_success "SDDM installed and enabled successfully."
}

log_info "$(header "Umbra Dotfiles Installer")"

log_info "  1. Full dotfiles (Rice, ZSH, Neovim, NetworkManager, Bluetooth, Optionals)"
log_info "  2. Only rice & theming"
log_info "  3. Minimal (ZSH, Neovim)"
log_info "  4. Adwaita theming"

choice=
read_fmt "What mode would you like to install?" choice || exit 1

if ask_confirm "Would you like to be asked before every command runs?" y; then
    if ask_confirm "Are you SURE you want to do this?"; then
        ask=false
        log_warning "Will not ask to run commands..."
    else
        log_info "Will ask to run commands."
    fi
fi

# Install paru if it is not already available.
if ! command_exists paru; then
    if ! ask_confirm "Paru is required for this installation script. Install it?"; then
        log_die "Paru is required. Exiting."
    fi

    run_catch_error install_paru
fi

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
