# Reproducible install: `brew bundle --file=~/.config/dotfiles/Brewfile`
# Check for drift with: `brew bundle check --verbose` / `brew bundle cleanup`
#
# This replaces the hand-maintained `brew install ...` lines that used to live
# in README.md, which had drifted from what is actually installed (it still
# listed nvm after the move to fnm, and omitted wezterm and tree-sitter-cli).

tap "felixkratz/formulae"
tap "nikitabobko/tap"
tap "raine/workmux"

# ---------------------------------------------------------------------------
# Shell & core CLI
# ---------------------------------------------------------------------------
brew "bash"           # modern bash for scripts/ (macOS ships 3.2)
brew "starship"       # prompt
brew "stow"           # dotfile symlink manager
brew "zoxide"         # frecency-based cd
brew "atuin"          # SQLite shell history (local-only unless `atuin login`)

# ---------------------------------------------------------------------------
# Search & file tools
# ---------------------------------------------------------------------------
brew "bat"            # cat with syntax highlighting
brew "eza"            # ls replacement
brew "fd"             # find replacement
brew "fzf"            # fuzzy finder
brew "fzf-tab"        # fzf-powered zsh completion menu
brew "ripgrep"        # grep replacement; also backs :grep in Neovim
brew "ast-grep"       # structural search/replace engine for grug-far.nvim
brew "yazi"           # TUI file manager

# ---------------------------------------------------------------------------
# Editor & language tooling
# ---------------------------------------------------------------------------
brew "neovim"
# Required by nvim-treesitter's `main` branch to build parsers (:TSUpdate).
# Note: the `tree-sitter` formula is the C library only -- this is the CLI.
brew "tree-sitter-cli"
# mise manages Node *and* Python, and supplies per-project env via .mise.toml.
# It replaced fnm, which replaced nvm.
brew "mise"
brew "pnpm"
brew "yarn"

# ---------------------------------------------------------------------------
# Git
# ---------------------------------------------------------------------------
brew "gh"
brew "lazygit"
# Code-review TUI with vim keys: local ranges (`tuicr -r main..HEAD`),
# uncommitted work (`tuicr -w`) and real GitHub PRs (`tuicr pr 123`),
# submitting inline comments back with `:submit`.
brew "tuicr"
# gh-dash is a gh CLI extension rather than a formula, so it is not listed
# here. Install with:  gh extension install dlvhdr/gh-dash
#   Configured in gh-dash/config.yml: `v` opens tuicr on the PR, `G` opens
#   lazygit, `d` pipes the diff through diffnav.
brew "git-delta"      # diff renderer — [core] pager in git/.gitconfig, and lazygit paging
brew "diffnav"        # delta plus a GitHub-style file tree; gh-dash's diff pager
brew "yt-dlp"         # pull video transcripts: yt-dlp --skip-download --write-auto-subs
brew "poppler"        # pdftotext — extract book/PDF text locally for the vault
brew "pandoc"         # epub/docx -> markdown, same job for non-PDF books

# ---------------------------------------------------------------------------
# Terminal / system
# ---------------------------------------------------------------------------
brew "tmux"
brew "sesh"           # tmux session picker (replaced the tmux-sessionx plugin)
# git worktree + tmux window per task, for parallel agents.
# Global config is stowed from workmux/; per-repo overrides in .workmux.yaml.
brew "raine/workmux/workmux"
brew "btop"
brew "openssh"
brew "ykman"                        # YubiKey manager (SSH signing key)
brew "felixkratz/formulae/borders"  # window borders, started by aerospace

# ---------------------------------------------------------------------------
# Applications
# ---------------------------------------------------------------------------
cask "wezterm"
cask "aerospace"
cask "1password"
cask "1password-cli"
cask "hiddenbar"
cask "homerow"
cask "notion-calendar"
cask "notion-mail"
cask "obsidian"       # backs the ~/.sb/second-brain obsidian.nvim workspace
cask "raycast"
cask "spotify"
cask "todoist-app"
