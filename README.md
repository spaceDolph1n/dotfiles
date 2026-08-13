# 🛠️ macOS Dotfiles

Personal dotfiles for a fresh macOS install: shell, Neovim, tmux, WezTerm,
AeroSpace and git, symlinked with GNU Stow.

Setup is ten steps, in dependency order. Everything is safe to re-run.

---

## Setup, in order

### 1. Prerequisites

```bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Clone and symlink

```bash
mkdir -p ~/.config && cd ~/.config
git clone git@github-personal:spaceDolph1n/dotfiles.git   # or: gh repo clone spaceDolph1n/dotfiles
cd dotfiles

stow -t ~/.config .   # everything except zshrc lands in ~/.config
stow -t ~ zshrc       # .zshrc lands in ~
```

Re-link after adding or removing a directory:

```bash
cd ~/.config/dotfiles && stow -R -t ~/.config . && stow -R -t ~ zshrc
```

### 3. Packages

Everything is declared in [`Brewfile`](./Brewfile) — formulae, casks and taps.

```bash
brew bundle --file=~/.config/dotfiles/Brewfile
```

```bash
brew bundle check --file=~/.config/dotfiles/Brewfile --verbose   # what's missing
brew bundle cleanup --file=~/.config/dotfiles/Brewfile           # what's extra
```

> WezTerm may already exist in `/Applications` from a manual download. Adopt it
> into Homebrew once with `brew install --cask wezterm --force`.

### 4. Runtimes

Managed by **mise** — Node *and* Python, plus per-project env vars via `mise.toml`.

```bash
mise use -g node@lts
mise use -g python@latest
mise ls
```

```bash
npm install -g czg   # commit tooling, used by lazygit's `C` binding
```

> `.nvmrc` / `.node-version` support is **off by default** in mise. It is enabled
> via `idiomatic_version_file_enable_tools` in `mise/config.toml` — without that,
> walking into a repo with a `.nvmrc` silently keeps the global version.

### 5. Shell

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Built-in Oh My Zsh plugins need no cloning; these do:
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

### 6. Git & GitHub

Identity is split by directory via `includeIf` in `git/.gitconfig`:

| Path | Profile |
| --- | --- |
| `~/Documents/work/` | `.gitconfig-work` |
| `~/.config/dotfiles/`, `~/.sb/` | `.gitconfig-personal` |

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
pbcopy < ~/.ssh/id_ed25519.pub   # → GitHub → Settings → SSH and GPG keys
ssh -T git@github.com
gh auth login
```

Verify the split actually took, in both a work repo and this one:

```bash
git config user.email     # must differ per directory
```

#### The four git tools, and what each is for

They divide cleanly — that separation is the point, not an accident:

| Tool | Job |
| --- | --- |
| **lazygit** | staging, committing, branch work — the daily driver |
| **gh-dash** | triage: what needs my review, what am I blocking |
| **tuicr** | reviewing a PR properly — vim keys, inline comments, `:submit` |
| **diffnav** | reading any diff — delta plus a GitHub-style file tree |

`gh-dash` is a `gh` extension, not a formula:

```bash
gh extension install dlvhdr/gh-dash
```

**Diff rendering.** `delta` is `core.pager` in `git/.gitconfig` and the pager in
`lazygit/config.yml` (`git.pagers` — a *list*, not `paging`), so diffs look identical in the
CLI and in lazygit. `diffnav` can't be `core.pager` because that also handles `log`, `show`
and `blame`, which it would mangle — so it's on aliases instead:

```bash
git dn              # working tree, in diffnav
git dnc             # staged
git dns HEAD~2      # a specific commit
```

**gh-dash keybindings** (`gh-dash/config.yml`) — `v` and `G` open a new tmux window so the
dashboard keeps its state:

| Key | Does |
| --- | --- |
| `v` | review the PR in tuicr |
| `G` | lazygit on that repo |
| `C` | check the branch out, then lazygit |
| `d` | pipe the PR diff through diffnav |

### 7. Neovim

Requires **Neovim 0.12+**. Plugins are managed by lazy.nvim and bootstrap
themselves on first launch.

`nvim-treesitter` tracks the **`main`** branch — the 0.12 rewrite, where the plugin
installs only parsers and queries while core `vim.treesitter` does highlighting and
folding. Building parsers needs the CLI:

```bash
brew install tree-sitter-cli   # NB: the `tree-sitter` formula is the C library only
```

Parsers install to `~/.local/share/nvim/site/parser`. Refresh with `:TSUpdate`.

Language servers and CLI tools are declared at the top of
`nvim/lua/plugins/lsp.lua` and installed by Mason on first start. Give it a minute,
then `:Mason` to confirm.

Layout:

| Path | Purpose |
| --- | --- |
| `nvim/lua/core/` | options, keymaps, autocmds, diagnostics |
| `nvim/lua/plugins/` | one lazy.nvim spec per concern |
| `nvim/after/lsp/` | per-server config; `after/` so it wins over nvim-lspconfig |

### 8. tmux

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins    # or `prefix + I` inside tmux
```

Prefix is `C-a`. After any edit to `tmux.conf`, reload with **`prefix + R`** —
otherwise new bindings silently do nothing.

### 9. Daily auto-commit (optional)

`scripts/daily-snapshot` commits and pushes anything uncommitted in this repo and
in a notes repo at `~/.sb/second-brain`. The repo list is hardcoded at the top of
the script — **edit it before enabling**, or skip this step entirely.

Install the LaunchAgent that runs it daily at 23:00 and at login:

```bash
ln -sf ~/.config/dotfiles/launchd/com.spacedolph1n.daily-snapshot.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.spacedolph1n.daily-snapshot.plist
tail -f /tmp/daily-snapshot.log
```

It checks `git status` per repo first and exits immediately when everything is
clean, so a quiet day costs nothing.

`scripts/raycast/` holds Raycast Script Commands — register that directory under
Raycast → Extensions → Script Commands if you use Raycast.

> **Why the scripts set `GIT_CONFIG_GLOBAL` explicitly:** anything launched by
> launchd, Raycast or Shortcuts does **not** source `.zshrc`, so the variable is
> unset, git never reads `~/.config/git/.gitconfig`, and commits get authored as
> `user@hostname`. Do not remove those lines.

### 10. Verify

```bash
ls -l ~/.config | grep ' -> '        # symlinks resolve
git config user.email                # correct identity per directory
nvim --version | head -1             # 0.12+
nvim +checkhealth                    # treesitter, lsp, conform all green
tmux new -d && tmux ls && tmux kill-server
launchctl list | grep daily-snapshot
```

---

## ⚠️ Troubleshooting

| Symptom | Fix |
| --- | --- |
| Broken/stale symlinks | `stow -R -t ~/.config .` |
| Homebrew path issues | `brew doctor` |
| No syntax highlighting | `:checkhealth nvim-treesitter`, then `:TSUpdate` |
| LSP not attaching | `:checkhealth lsp`, then `:Mason` to confirm the binary |
| Formatter not running | `:ConformInfo` |
| New tmux binding does nothing | `prefix + R` to reload `tmux.conf` |
| lazygit diffs look unstyled | The key is `git.pagers` (a **list**), not `paging` — a wrong key is ignored silently |
| `git dn` opens nothing | diffnav is a TUI; it needs a real terminal, not a pipe into another command |
| gh-dash `v`/`G` do nothing | They shell out to `tmux new-window`; outside tmux they fall back to running in place |
| Commits authored as `user@hostname` | `GIT_CONFIG_GLOBAL` unset — see step 9 |
| `.nvmrc` ignored | `idiomatic_version_file_enable_tools` in `mise/config.toml` |

---