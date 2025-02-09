# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

export PATH=/opt/homebrew/bin:$PATH

export SCRIPTS="$HOME/.config/scripts"
export SECOND_BRAIN=$HOME/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Second\ Brain
export PATH="$PATH:$SCRIPTS"

alias dotfiles="cd ~/.config/dotfiles/"
alias scripts='cd ~/.config/scripts'
alias sb='cd $SECOND_BRAIN'
alias v="nvim"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export EDITOR=/opt/homebrew/bin/nvim

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Zsh plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Set language environment
export LANG=en_US.UTF-8

eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# Syntax highlighting should be sourced after plugins
source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Optional: Enable autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

# BAT: Better CAT
export BAT_THEME="Catppuccin Mocha"
alias cat=bat

# EZA: Better ls
alias l="eza -l --icons --git -a --no-user"
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

# Catppuccin mocha theme for fzf
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

alias source-zsh="source ~/.zshrc"
alias edit-zsh="nvim ~/.zshrc"

# SFTP connections
alias sftp-test="lftp -u scanbotsdk2-tiago -p 2222 sftp://scanbotsdk2.sftp.wpengine.com"
alias sftp-prod="lftp -u scanbotsdk1-tiago -p 2222 sftp://scanbotsdk1.sftp.wpengine.com"
alias sftp-staging="lftp -u stagingscanbot-tiago -p 2222 sftp://stagingscanbot.sftp.wpengine.com"
alias sftp-dev="lftp -u scanbotdev-tiago -p 2222 sftp://scanbotdev.sftp.wpengine.com"

# change LazyGit config location
export XDG_CONFIG_HOME="$HOME/.config"

# navigation
cx() { cd "$@" && l; } # cd and list
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; } # fuzzy cd
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy } # fuzzy find and copy to clipboard
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" } # fuzzy find and open in nvim

# Git
alias gc="git commit -m" # commit
alias gca="git commit -a -m" # commit and stage modified and deleted
alias gP="git push origin HEAD"
alias gp="git pull origin"
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
alias gb='git branch'
alias gba='git branch -a'
alias ga='git add'
alias gap='git add -p'
alias gcoall='git checkout -- .'

# Git config default location
export GIT_CONFIG_GLOBAL=~/.config/git/.gitconfig

# Ollama alias
alias bot="ollama run qwen2.5-coder:14b"
