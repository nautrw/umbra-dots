# terminal-wakatime setup
export PATH="$HOME/.wakatime:$PATH"
if command -v terminal-wakatime &>/dev/null; then
    eval "$(terminal-wakatime init)"
fi

# misc. variables
export PATH="$PATH:/home/$USER/.local/bin:/home/$USER/.cargo/bin"
export EDITOR=nvim

# keybinds
bindkey '^[[1;5D' backward-word # ctrl+left
bindkey '^[[1;5C' forward-word # ctrl+right
bindkey '^H' backward-kill-word # ctrl+backspace

# history
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=5000
export SAVEHIST=5000
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY

# aliases
alias ls="eza"
alias rlzsh="source ~/.zshrc"

# plugins
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source /usr/share/zsh/plugins/zsh-auto-venv/auto-venv.plugin.zsh
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

function zvm_vi_yank() {
    zvm_yank
    print -rn -- "$CUTBUFFER" | wl-copy
}

# starship
eval "$(starship init zsh)"
