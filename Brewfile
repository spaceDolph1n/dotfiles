# Reproducible install: `brew bundle --file=~/.config/dotfiles/Brewfile`
# Check for drift with: `brew bundle check --verbose` / `brew bundle cleanup`
#
# This replaces the hand-maintained `brew install ...` lines that used to live
# in README.md, which had drifted from what is actually installed (it still
# listed nvm after the move to fnm, and omitted wezterm and tree-sitter-cli).

tap "felixkratz/formulae"
tap "nikitabobko/tap"

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
# Uncomment together with the [core] pager block in git/.gitconfig:
# brew "git-delta"

# ---------------------------------------------------------------------------
# Terminal / system
# ---------------------------------------------------------------------------
brew "tmux"
brew "sesh"           # tmux session picker (replaced the tmux-sessionx plugin)
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
