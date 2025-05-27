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

autoload -Uz compinit
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
compinit
# End of lines added by compinstall
