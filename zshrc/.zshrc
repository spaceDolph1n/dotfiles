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

# ESLINT_USE_FLAT_CONFIG / ESLINT_CONFIG intentionally NOT exported: a global
# flat-config flag breaks whichever repo it does not match (nvim/lsp/eslint.lua
# decides per project root), and ESLINT_CONFIG is not a variable ESLint reads.

# ---------------------------------------------------------------------------
# Oh My Zsh
# ---------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"

# zsh-autosuggestions and zsh-syntax-highlighting are NOT in this list: both wrap
# ZLE widgets, so they are sourced by hand below -- after fzf-tab, and
# syntax-highlighting last of all.
plugins=(git extract sudo history)

# Homebrew's completions (_gh, _fd, _rg, _mise, ...) are not in the default fpath,
# so `gh <TAB>` only completed filenames. Must precede oh-my-zsh, which runs
# compinit. `:h:h` not `:A:h:h` -- bin/brew is a symlink into Homebrew/bin.
if (( $+commands[brew] )); then
    fpath=("${commands[brew]:h:h}/share/zsh/site-functions" $fpath)
fi

# workmux ships a zsh completion (with dynamic worktree-handle completion) but
# its brew formula installs only the binary, so `_workmux` was never on fpath
# and `workmux <TAB>` fell back to filenames. Regenerate into oh-my-zsh's
# completion cache -- already on fpath -- whenever the binary is newer than it.
if (( $+commands[workmux] )); then
    () {
        local dump="$ZSH/cache/completions/_workmux"
        if [[ ! -s $dump || $commands[workmux] -nt $dump ]]; then
            mkdir -p "${dump:h}" && workmux completions zsh >| "$dump"
        fi
    }
fi

source $ZSH/oh-my-zsh.sh

# ---------------------------------------------------------------------------
# Completion menu -- order matters
# ---------------------------------------------------------------------------
# fzf-tab puts the fzf picker on Tab. It hooks the completion system rather than
# individual commands, so anything with a zsh completion is covered. Loads after
# compinit (oh-my-zsh runs it) and before plugins that wrap ZLE widgets.
source "${commands[brew]:h:h}/share/fzf-tab/fzf-tab.zsh"
source "$ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# fzf-tab needs zsh's own menu off. The five-colon pattern matches oh-my-zsh's
# `menu select` exactly -- a plain `:completion:*` is less specific and loses.
zstyle ':completion:*' menu no
zstyle ':completion:*:*:*:*:*' menu no

# Group headers only render when descriptions have a format.
zstyle ':completion:*:descriptions' format '[%d]'

# fzf-tab does not read FZF_DEFAULT_OPTS unless told to.
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# `cd <TAB>` is where the name alone rarely says enough.
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always $realpath'

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
alias dotfiles="cd ~/.config/dotfiles/ && v"
alias scripts='cd ~/.config/scripts'
alias sb='cd ~/.sb/second-brain/ && v'
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

# `${=VAR}` is zsh word-splitting; the FZF_*_COMMAND vars are reused so `fv` and
# Ctrl-T agree on what a file is. The `&&` guards matter -- without one, escaping
# out of fzf pipes nothing into pbcopy and wipes the clipboard.
fcd() { local d; d=$(${=FZF_ALT_C_COMMAND} | fzf) && cd "$d" && ll; }
f() { local file; file=$(${=FZF_DEFAULT_COMMAND} | fzf) && printf '%s' "$file" | pbcopy; }
fv() { local file; file=$(${=FZF_DEFAULT_COMMAND} | fzf) && nvim "$file"; }

# smallpdf/web: the dev server's port comes from ~/.web-dev-profile, so only one
# worktree can hold 443/80. Kill whoever has it, then start here. The pattern
# matches `node -r ./registerWebDevServer` from bin/dev; killing that leaf is
# enough, its env-cmd and with-env parents exit with it.
alias kill-dev='pkill -f registerWebDevServer'
dev() { pkill -f registerWebDevServer; npm run dev; }

# ---------------------------------------------------------------------------
# Keybindings -- order matters
# ---------------------------------------------------------------------------
# `bindkey -v` selects the viins keymap, so it must come BEFORE anything that
# installs widgets, otherwise those bindings land in a keymap that is not active.
bindkey -v

# Esc toggles back to INSERT instead of trapping. Needed because omz's `sudo`
# plugin binds `\e\e`, so a lone Esc waits out KEYTIMEOUT (400ms) first. Does not
# break it -- `\e\e` lives in viins and resolves before vicmd is ever entered.
bindkey -M vicmd '\e' vi-insert

# fzf: Ctrl-T (files), Ctrl-R (overridden by atuin below), Alt-C (cd).
#
# fzf's Tab widget falls back to this when there is no `**` trigger. Set
# explicitly because fzf only guesses when it is empty, so re-sourcing a shell
# that predates fzf-tab would silently keep the old completion.
(( $+widgets[fzf-tab-complete] )) && fzf_default_completion=fzf-tab-complete
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
