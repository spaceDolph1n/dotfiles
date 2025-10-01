# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

export PATH=/opt/homebrew/bin:$PATH
export PATH=$PATH:$HOME/.local/bin

export SCRIPTS="$HOME/.config/scripts"
export SECOND_BRAIN=$HOME/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Second\ Brain
export PATH="$PATH:$SCRIPTS"

alias dotfiles="cd ~/.config/dotfiles/"
alias scripts='cd ~/.config/scripts'
alias sb='cd $SECOND_BRAIN'
alias v="nvim"

# for NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
[ -s "$(brew --prefix nvm)/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix nvm)/etc/bash_completion.d/nvm"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export EDITOR=/opt/homebrew/bin/nvim

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Zsh plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting extract sudo history)

source $ZSH/oh-my-zsh.sh

# Set language environment
export LANG=en_US.UTF-8

# solution for functest error 
# xref: https://github.com/starship/starship/issues/3418
if [[ "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select" || \
      "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select-wrapped" ]]; then
    zle -N zle-keymap-select "";
fi
eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# Syntax highlighting should be sourced after plugins
source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Optional: Enable autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

# BAT: Better CAT
alias cat=bat

# EZA: Better ls
alias ll="eza -l --icons --git -a --no-user"
alias lt="eza --tree --level=2 --long --icons --git --no-user"

# Zoxide (better cd)
eval "$(zoxide init zsh)"
alias cd="z"

# Function for yazi to stay in the same folder when you exit
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Set up fzf key bindings and fuzzy completion and makes it use fd instead of find
eval "$(fzf --zsh)"

alias source-zsh="source ~/.zshrc"
alias edit-zsh="nvim ~/.zshrc"

# change LazyGit config location
export XDG_CONFIG_HOME="$HOME/.config"

# navigation
cx() { cd "$@" && ll; } # cd and list
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; } # fuzzy cd
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy } # fuzzy find and copy to clipboard
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" } # fuzzy find and open in nvim

# Git config default location
export GIT_CONFIG_GLOBAL=~/.config/git/.gitconfig

# VI Mode
bindkey -v
