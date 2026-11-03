# Lines configured by zsh-newuser-install
eval "$(starship init zsh)"
eval "$(fnm env --use-on-cd --shell zsh)"
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/lixuling/.zshrc'
alias vim="nvim"
alias notes="nvim ~/MINE/notes"
alias coding="~/.config/scripts/coding"
alias tiktokstreamkey="~/MINE/stream/StreamLabsTikTokStreamKeyGenerator.dist/StreamLabsTikTokStreamKeyGenerator.bin"
alias ls='exa --icons'

autoload -Uz compinit
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
compinit

export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:/var/lib/snapd/snap/bin"
export PATH="$PATH:/home/lixuling/.cargo/bin"
export EDITOR="nvim"

. "$HOME/.local/bin/env"
eval "$(uv generate-shell-completion zsh)"

# secrets (API keys etc) — not tracked in dotfiles
[ -f "$HOME/.secrets.zsh" ] && source "$HOME/.secrets.zsh"

# opencode
export PATH=/home/lixuling/.opencode/bin:$PATH

# bun
export PATH="/home/lixuling/.bun/bin:$PATH"

# pnpm
export PNPM_HOME="/home/lixuling/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


# Pi
export PATH="/home/lixuling/.local/share/pi-node/node-v22.23.2-linux-x64/bin:$PATH"

# bun completions
[ -s "/home/lixuling/.bun/_bun" ] && source "/home/lixuling/.bun/_bun"

# Multiple Claude Code accounts (isolated via CLAUDE_CONFIG_DIR)
alias claude-personal="claude"
alias claude-work="CLAUDE_CONFIG_DIR=$HOME/.claude-work claude"

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<
