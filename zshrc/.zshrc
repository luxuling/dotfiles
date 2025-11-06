# Lines configured by zsh-newuser-install
eval "$(starship init zsh)"
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
# End of lines added by compinstall


# Load Angular CLI autocompletion.
source <(ng completion script)


# Load Angular CLI autocompletion.
source <(ng completion script)

export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:/var/lib/snapd/snap/bin"

. "$HOME/.local/bin/env"
eval "$(uv generate-shell-completion zsh)"
