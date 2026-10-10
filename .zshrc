# terminal-wakatime setup
export PATH="$HOME/.wakatime:$PATH"
eval "$(terminal-wakatime init)"

# aliases
alias ls="eza"

# plugins
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source /usr/share/zsh/plugins/zsh-auto-venv/auto-venv.plugin.zsh

# starship
eval "$(starship init zsh)"
