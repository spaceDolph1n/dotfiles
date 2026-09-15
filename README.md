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

CLIs that ship as npm packages go through mise too — **never `npm install -g`**:

```bash
mise use -g "npm:czg@latest"             # commit tooling, lazygit's `C` binding
mise use -g "npm:@openai/codex@latest"   # Codex CLI, used by the codex consult
```

> **Which manager?** Decide by what the thing *ships as*, not by preference:
> language runtimes and npm-delivered CLIs → **mise** (tracked in `mise/config.toml`);
> compiled binaries and apps → **brew** (tracked in `Brewfile`). Keep `npm -g`,
> `pnpm -g` and `bun -g` empty. An `npm -g` install binds to whichever Node is
> active and silently breaks when that changes — and nothing declares it, so a new
> machine never gets it back.

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
| `C` | check the branch out, then nvim left / dev server right |
| `d` | pipe the PR diff through diffnav |

`C` runs the checkout **before** creating the tmux window, so the dev server pane can never
build the branch you were on a moment ago, and a failed checkout (dirty tree) aborts without
leaving a stray window behind.

**tuicr** (`tuicr/config.toml`) — config keys of note: `appearance` (light/dark/system),
`theme_dark` / `theme_light`, `diff_view`, `transparent_background`, `comment_types`.

| Where | What |
| --- | --- |
| `tuicr/config.toml` | `appearance = "system"`, dark → the active theme |
| `tuicr/themes/*.toml` | **generated** by `scripts/theme`, one per theme |

The bundled `dark` theme leaves the chip foregrounds too light, so the mode indicator, the
message banners and the update badge render light-on-light and are unreadable on this
terminal — the same failure as gh-dash's `faint`. A generated theme fixes it because every
`*_fg` is pinned explicitly. See section 8.

Audition a bundled theme without editing anything:

```bash
tuicr --theme tokyo-night-storm pr 6209   # 24 bundled; an invalid name lists them all
```

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

### 8. Colours — one palette, every tool

`scripts/theme` is the switch. One command repaints the whole terminal:

```sh
theme                    # print the active theme
theme kanagawa-dragon    # switch everything
theme --check            # render without writing; non-zero on a problem
scripts/theme.test.sh    # 23 assertions
```

**Palettes are never transcribed.** `scripts/theme-palette <theme>` reads the palette out of
the nvim plugin already on disk, so this and the editor cannot disagree. Both theme plugins
are `enabled = true` with `lazy = true` on the inactive one, pinned by `lazy-lock.json`.

**Surfaces are `*.tmpl` files.** Each renders to the same path without the suffix, with
`<<role>>` interpolated. `<<kanso:role>>` names a specific theme, for files holding every
theme at once; `<<theme>>` is the active theme's name. A template path containing `{theme}`
renders once per theme — which is how tuicr and yazi get a file each. `<<>>` was chosen
because `$`, `{}`, `{{}}` and `#{}` are already spoken by starship, gh-dash and tmux.

| Surface | How it switches |
| --- | --- |
| **wezterm** | generated; the only ANSI definition on this machine — tmux, starship, fzf and eza all resolve colour names through it |
| **tmux** | generated `tmux/theme.conf`, sourced after tpm |
| **workmux** | generated; the agent-status dots |
| **nvim** | generated `nvim/lua/active-theme.lua`, read by `theme.lua` |
| **hunk** | both themes resident in `config.toml`; `theme` flips |
| **tuicr** | a file per theme; `theme_dark` flips |
| **yazi** | a flavour per theme; `[flavor] dark` flips |
| **lazygit**, **starship**, **gh-dash**, `[delta]`, `scripts/vault-graph` | generated inline |

The role contract is the **intersection** of what both themes emit — kanso ships 82 roles and
dragon 75. Anything outside it is aliased or derived in `theme-palette`, and a template naming
a role no palette has aborts the whole run before a single file is written. Two of the derived
values reproduce colours that were hand-tuned here first, which is what the tests assert.

**Nothing hand-edits generated output.** Change the `.tmpl`, run `theme`. hunk is the one to
watch: it rewrites `config.toml` when you accept "save view changes?" on quit, so answer *no*
and put the preference in the template instead.

The wezterm block must keep `force_reverse_video_cursor = true`. Without it the cursor uses
`cursor_bg`/`cursor_fg` literally, which in this palette is dark-on-dark and near invisible.

The yazi flavours carry no `tmtheme.xml`, so file *previews* keep yazi's default syntax
highlighting; only the chrome is themed. `theme.toml` holds nothing but `[flavor]` — anything
else there overrides the flavour rather than extending it.

### 9. tmux

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins    # or `prefix + I` inside tmux
```

Prefix is `C-a`. After any edit to `tmux.conf`, reload with **`prefix + R`** —
otherwise new bindings silently do nothing.

### 10. Daily auto-commit (optional)

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

### 11. Verify

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
| yazi won't start, `at least one of \`url\` or \`mime\`` | The vendored Kansō flavour targets an older yazi — `name =` → `url =`, `[manager]` → `[mgr]` |
| yazi looks unthemed | `theme.toml` must contain `[flavor]`; the flavour name must match the `flavors/<name>.yazi` dir minus the suffix |
| tuicr chips unreadable (mode, banners, update badge) | The bundled themes leave `*_fg` unset; use `theme_dark = "kanso-zen"` or try `transparent_background` |
| Commits authored as `user@hostname` | `GIT_CONFIG_GLOBAL` unset — see step 9 |
| `.nvmrc` ignored | `idiomatic_version_file_enable_tools` in `mise/config.toml` |
| `mise ERROR No version is set for shim: <tool>` | Orphaned shim — the tool isn't in `mise/config.toml`. `mise which <tool>` confirms it; re-add with `mise use -g`. `mise doctor` will **not** catch this |

---