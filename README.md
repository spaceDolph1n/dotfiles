# 🛠️ macOS Dotfiles

Personal dotfiles for a fresh macOS install: shell, Neovim, tmux, WezTerm,
AeroSpace and git, symlinked with GNU Stow.

---

## ✅ Prerequisites

```bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

## 📦 Packages

Everything is declared in [`Brewfile`](./Brewfile) — formulae, casks and taps.

```bash
brew bundle --file=~/.config/dotfiles/Brewfile
```

Useful follow-ups:

```bash
brew bundle check --file=~/.config/dotfiles/Brewfile --verbose   # what's missing
brew bundle cleanup --file=~/.config/dotfiles/Brewfile           # what's extra
```

> WezTerm may already exist in `/Applications` from a manual download. Adopt it
> into Homebrew once with `brew install --cask wezterm --force`.

### Runtimes

Managed by **mise** (replaced fnm, which replaced nvm). It handles Node *and*
Python, and can set per-project env vars through `mise.toml`.

`.nvmrc` / `.node-version` support is **off by default** in mise — it is turned
on via `idiomatic_version_file_enable_tools` in `mise/config.toml`. Without that
setting, walking into a repo with a `.nvmrc` silently keeps the global version.

```bash
mise use -g node@lts
mise use -g python@latest
mise ls
```

Commit tooling (`czg`, used by lazygit's `C` binding) is a global npm package:

```bash
npm install -g czg
```


---

## 🐚 Shell Setup

### Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Third-party Zsh plugins

Built-in Oh My Zsh plugins need no cloning; these do:

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

---

## 📂 Symlinking (Stow)

```bash
mkdir -p ~/.config && cd ~/.config
gh repo clone spaceDolph1n/dotfiles
cd dotfiles

stow -t ~/.config .   # everything except zshrc lands in ~/.config
stow -t ~ zshrc       # .zshrc lands in ~
```

To re-link after adding or removing a directory:

```bash
cd ~/.config/dotfiles
stow -R -t ~/.config .
stow -R -t ~ zshrc
```

---

## 🔑 Git & GitHub

Identity is split by directory via `includeIf` in `git/.gitconfig`:

| Path              | Profile                   |
| ----------------- | ------------------------- |
| `~/Documents/work/` | `.gitconfig-work`       |
| `~/.config/dotfiles/`, `~/.sb/` | `.gitconfig-personal` |

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
pbcopy < ~/.ssh/id_ed25519.pub   # → GitHub → Settings → SSH and GPG keys
ssh -T git@github.com
gh auth login
```

---

## ⌨️ Neovim

Requires **Neovim 0.12+**. Plugins are managed by lazy.nvim and bootstrap
themselves on first launch.

Layout:

| Path                | Purpose                                              |
| ------------------- | ---------------------------------------------------- |
| `nvim/lua/core/`    | options, keymaps, autocmds, diagnostics               |
| `nvim/lua/plugins/` | one lazy.nvim spec per concern                        |
| `nvim/lsp/`         | per-server config, read natively off the runtimepath  |

### Treesitter

`nvim-treesitter` tracks the **`main`** branch — the 0.12 rewrite, where the
plugin only installs parsers and queries while core `vim.treesitter` does the
highlighting and folding. Building parsers needs the CLI:

```bash
brew install tree-sitter-cli   # NB: the `tree-sitter` formula is the C library only
```

Parsers install to `~/.local/share/nvim/site/parser`. Refresh with `:TSUpdate`.

### Native 0.11/0.12 defaults worth remembering

These come from core Neovim. Nothing in this config defines them, and several
plugin mappings were removed because these already existed.

**LSP** (all prefixed `gr`, no leader):

| Key | Action |
| --- | --- |
| `grn` | Rename symbol (replaced `<leader>xr`) |
| `gra` | Code action — normal and visual |
| `grr` | References |
| `gri` | Implementation |
| `grt` | Type definition |
| `grl` | Codelens run |
| `gO`  | Document symbols (outline) |
| `gd` / `gD` | Definition / declaration |
| `K` | Hover docs |
| `<C-s>` | Signature help (insert mode) |
| `[d` / `]d` | Previous / next diagnostic |
| `<C-w>d` | Open diagnostic float |

**Navigation** (0.11+ bracket pairs — mini.bracketed's overlapping suffixes are
disabled in favour of these):

| Key | Action |
| --- | --- |
| `[b` / `]b` | Previous / next buffer |
| `[B` / `]B` | First / last buffer |
| `[q` / `]q` | Previous / next quickfix item |
| `[l` / `]l` | Previous / next location-list item |
| `[t` / `]t` | Previous / next tag |
| `[a` / `]a` | Previous / next arglist file |
| `[f` / `]f` | Previous / next file in the directory |
| `[<Space>` / `]<Space>` | Blank line above / below |

**Editing:**

| Key | Action |
| --- | --- |
| `gc` / `gcc` / `gbc` | Comment operator / line / block (native since 0.10) |
| `gx` | Open URL under cursor |
| `g==` | Execute the Lua/Vim code under the cursor |
| `zi` | Toggle folds (treesitter folds are on) |
| `y` then `:h quickfix` | — |
| `:Inspect` | Show highlight groups / treesitter captures under cursor |
| `:InspectTree` | Live treesitter syntax tree |
| `:checkhealth` | Diagnose the whole config |

**Terminal:** `<C-\><C-n>` leaves terminal-insert mode.

### Language servers

Servers and CLI tools are declared at the top of `nvim/lua/plugins/lsp.lua` and
installed by Mason on startup. ESLint picks flat vs. legacy `.eslintrc` config
**per project root** (see `nvim/lsp/eslint.lua`) — there is deliberately no
global `ESLINT_USE_FLAT_CONFIG` export in `.zshrc`.

---

## 🔌 Tmux

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins    # or `prefix + I` inside tmux
```

The Kanso theme is re-linked into the catppuccin plugin directory automatically
by a `run-shell` line in `tmux.conf`, so `prefix + U` no longer breaks it — no
manual `ln -sf` step.

Prefix is `C-a`. Session switching is **sesh** on `prefix + o` (replaced the
tmux-sessionx plugin). `C-h/j/k/l` moves between Neovim splits and tmux panes
interchangeably via vim-tmux-navigator.

---

## ⚠️ Troubleshooting

| Symptom                    | Fix                                                       |
| -------------------------- | --------------------------------------------------------- |
| Broken/stale symlinks      | `stow -R -t ~/.config .`                                   |
| Homebrew path issues       | `brew doctor`                                              |
| No syntax highlighting     | `:checkhealth nvim-treesitter`, then `:TSUpdate`           |
| LSP not attaching          | `:checkhealth lsp` and `:Mason` to confirm the binary      |
| Formatter not running      | `:ConformInfo`                                             |
