# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------
export XDG_CONFIG_HOME="$HOME/.config"
export LANG=en_US.UTF-8

export PATH=/opt/homebrew/bin:$PATH
export PATH=$PATH:$HOME/.local/bin

export SCRIPTS="$HOME/.config/scripts"
export PATH="$PATH:$SCRIPTS"

# Resolved from PATH rather than hardcoded to /opt/homebrew, so this file also
# works on an Intel Mac or Linux box.
export EDITOR=nvim
export VISUAL="$EDITOR"
export MANPAGER="nvim +Man!"

export GIT_CONFIG_GLOBAL=~/.config/git/.gitconfig
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# ESLINT_USE_FLAT_CONFIG / ESLINT_CONFIG intentionally NOT exported here.
#   - A global ESLINT_USE_FLAT_CONFIG breaks whichever repo style it doesn't
#     match; nvim/lsp/eslint.lua now decides per project root instead.
#   - ESLINT_CONFIG is not a variable ESLint reads, and it pointed at
#     ~/.config/eslint/eslint.config.js, which does not exist.

# ---------------------------------------------------------------------------
# Oh My Zsh
# ---------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"

# zsh-syntax-highlighting is deliberately NOT in this list -- it must be sourced
# last of everything that touches ZLE, which happens at the bottom of this file.
# It used to be in both places, so it was loaded twice.
plugins=(git zsh-autosuggestions extract sudo history)

source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

# ---------------------------------------------------------------------------
# Prompt
# ---------------------------------------------------------------------------
# xref: https://github.com/starship/starship/issues/3418
if [[ "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select" || \
      "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select-wrapped" ]]; then
    zle -N zle-keymap-select "";
fi
eval "$(starship init zsh)"

# ---------------------------------------------------------------------------
# Tooling
# ---------------------------------------------------------------------------
# mise replaces fnm: one version manager for Node *and* Python (FastAPI), plus
# per-project env vars via .mise.toml. Still honours .nvmrc / .node-version.
eval "$(mise activate zsh)"

# `--cmd cd` is the supported way to shadow cd; the old `alias cd="z"` broke
# `cd -` and made `cd` non-overridable in scripts.
eval "$(zoxide init zsh --cmd cd)"

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
alias dotfiles="cd ~/.config/dotfiles/"
alias scripts='cd ~/.config/scripts'
alias sb='cd ~/.sb/second-brain/'
alias v="nvim"

alias prs="gh dash"

alias cat=bat
alias ll="eza -l --icons --git -a --no-user"
alias lt="eza --tree --level=2 --long --icons --git --no-user"

alias source-zsh="source ~/.zshrc"
alias edit-zsh="nvim ~/.zshrc"

# ---------------------------------------------------------------------------
# Functions
# ---------------------------------------------------------------------------
# yazi, staying in the directory you exited from
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# navigation
cl() { cd "$@" && ll; }                                        # cd and list
cv() { cd "$@" && v; }                                         # cd and open in nvim
mkc() { mkdir -p "$1" && cd "$1"; }                            # create dir and move inside
cmkc() { cd "$1" && mkdir -p "$2" && cd "$2"; }                # move, create dir, move inside
cmkcv() { cd "$1" && mkdir -p "$2" && cd "$2" && v .; }        # ...and open nvim
mkcv() { mkdir -p "$1" && cd "$1" && v .; }                    # create dir, move inside, open nvim

# These three used `find`, which ignores .gitignore and walks node_modules.
#
# The fd invocation is NOT repeated here: these reuse the same FZF_*_COMMAND
# defined further down, so a file means the same thing to `fv` as it does to
# Ctrl-T. Written out separately they had already drifted -- the env vars pass
# --follow and these did not. `${=VAR}` is zsh word-splitting, needed because
# the variable holds a command plus its arguments. Definition order does not
# matter: a function body expands when it runs, not when it is defined.
#
# Every one of them guards on `&&`. Cancelling fzf prints nothing, and `f`
# without the guard piped that nothing straight into pbcopy -- so escaping out
# of the picker silently wiped the clipboard.
fcd() { local d; d=$(${=FZF_ALT_C_COMMAND} | fzf) && cd "$d" && ll; }
f() { local file; file=$(${=FZF_DEFAULT_COMMAND} | fzf) && printf '%s' "$file" | pbcopy; }
fv() { local file; file=$(${=FZF_DEFAULT_COMMAND} | fzf) && nvim "$file"; }

# ---------------------------------------------------------------------------
# Keybindings -- order matters
# ---------------------------------------------------------------------------
# `bindkey -v` selects the viins keymap, so it must come BEFORE anything that
# installs widgets, otherwise those bindings land in a keymap that is not active.
bindkey -v

# Esc in NORMAL mode returns to INSERT, so Esc toggles instead of trapping.
#
# Why this is needed: the omz `sudo` plugin binds `\e\e` to prepend sudo. From
# insert, `\e` is a *prefix* of that, so zsh waits KEYTIMEOUT (40 = 400ms) for a
# second Esc. Fast double-Esc gets sudo; slower than 400ms drops you into vicmd
# instead. Same keypress, two outcomes, depending on typing speed.
#
# This does NOT break the sudo binding: `\e\e` lives in the viins keymap and is
# resolved there before vicmd is ever entered. Verified with `bindkey -M viins`.
bindkey -M vicmd '\e' vi-insert

# fzf: Ctrl-T (files), Ctrl-R (history, immediately overridden by atuin below),
# Alt-C (cd). FZF_DEFAULT_COMMAND was never actually set despite the old comment
# claiming fzf used fd.
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border --info=inline'
eval "$(fzf --zsh)"

# atuin: SQLite-backed shell history, searchable across sessions with directory
# and exit-code context. Local-only -- sync requires an explicit `atuin login`.
# Up-arrow is left alone so plain prefix-history still behaves as before.
eval "$(atuin init zsh --disable-up-arrow)"

# Must be last: zsh-syntax-highlighting wraps every widget defined before it.
source ${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
