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
| `nvim/after/lsp/`   | per-server config; `after/` so it wins over nvim-lspconfig |

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
| `grr` | References (mini.operators' `gr` moved to `cr` so this works) |
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
| `gX` | Open URL under cursor (mini.operators owns `gx`) |
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
**per project root** (see `nvim/after/lsp/eslint.lua`) — there is deliberately no
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

## 🧠 Second brain

The vault lives at `~/.sb/second-brain` (its own repo). Capture is one command,
reachable from a shell, Raycast, and later Siri:

```bash
brain "Marco knows the payments service"      # -> log.md, concepts auto-linked
brain -d "Dropped the queue" [why] [expected] # -> decisions.md
brain --relink                                # link past entries to newer notes
```

`brain` only writes files — it never touches git. Committing is separate:

```bash
brain-commit             # commit and push
brain-commit --no-push   # commit only
```

A LaunchAgent runs `brain-commit` daily at 23:00 and at login. Install it with:

```bash
ln -sf ~/.config/dotfiles/launchd/com.spacedolph1n.brain-commit.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.spacedolph1n.brain-commit.plist
tail -f /tmp/brain-commit.log
```

> Anything launched by launchd, Raycast or Shortcuts does **not** source
> `.zshrc`, so `GIT_CONFIG_GLOBAL` is unset, git never reads
> `~/.config/git/.gitconfig`, and commits get authored as `user@hostname`.
> Both scripts set it explicitly for that reason.

Raycast Script Commands live in `~/.config/scripts/raycast` — add that directory
under Raycast → Extensions → Script Commands.

---

## ⚠️ Troubleshooting

| Symptom                    | Fix                                                       |
| -------------------------- | --------------------------------------------------------- |
| Broken/stale symlinks      | `stow -R -t ~/.config .`                                   |
| Homebrew path issues       | `brew doctor`                                              |
| No syntax highlighting     | `:checkhealth nvim-treesitter`, then `:TSUpdate`           |
| LSP not attaching          | `:checkhealth lsp` and `:Mason` to confirm the binary      |
| Formatter not running      | `:ConformInfo`                                             |

---

# 🔁 Changelog — 2026-08-06 overhaul

Everything below changed in a single session. The tables marked **retrain**
are the ones that will fight existing muscle memory.

## 1. Keys that MOVED — retrain

| Was | Now | What |
| --- | --- | --- |
| `sa` `sd` `sr` `sf` `sh` | **`gsa` `gsd` `gsr` `gsf` `gsh`** | Surround (add/delete/replace/find/highlight). Moved so `s` (flash jump) fires instantly instead of waiting 500ms behind 16 surround maps. |
| `gr` | **`cr`** | mini.operators *replace* — it was shadowing native LSP `gr*`. |
| `gs` | **`gz`** | mini.operators *sort* — it had become a prefix of the surround maps. |
| `gx` | **`gX`** | Open URL under cursor (mini.operators owns `gx` for exchange). |
| `<leader>l*` | **`<leader>g*`** | Git: `gg` lazygit · `gb` blame · `gd` diff overlay · `gf` file history · `gl` log |
| `<leader>g*` | **`<leader>l*`** | LSP: `ld` definition · `lr` references · `li` implementation · `lt` type · `ls` symbols |
| `<leader>xsw` `<leader>xsc` | **`<leader>xw` `<leader>xc`** | Search & replace sub-commands (so `<leader>xs` fires immediately). |
| `jjw` | **gone** | Use `<leader>w` to save. Its existence made every `jj` wait 500ms. |
| `<leader>xr` | **`grn`** | Rename — native since 0.11. |
| `<leader>xS` | gone | Was a duplicate of `<leader>xs`. |

## 2. New keys

| Key | Does |
| --- | --- |
| `<leader>1`–`<leader>4` | Jump to pinned file (harpoon, per-repo) |
| `<leader>ha` / `<leader>hh` | Pin current file / open pinned list |
| `<leader>aa` / `<leader>ac` | Toggle AI CLI / focus Claude (runs in tmux) |
| `<leader>af` / `<leader>ad` | Send file / diagnostics to the AI CLI |
| `<leader>ap` / `<leader>as` | Prompt picker / send visual selection |
| `<leader>rs` `<leader>ra` `<leader>rr` | HTTP: send request / send all / replay (in `.http` files) |
| `<leader>rb` | HTTP scratchpad |
| `<leader>go` | Open current line (or selection) **on GitHub** |
| `<leader>xa` | Structural find/replace via ast-grep |
| `<leader>xs` `<leader>xw` `<leader>xc` | Search & replace: project / word / current file |
| `<leader>uf` | Toggle format-on-save |
| `<leader>d*` | Debugger — `dc` start · `db` breakpoint · `do/di/dO` step · `du` UI · `de` eval |

## 3. Native Neovim keys now relied on

These replaced plugin mappings. Nothing in the config defines them.

| Key | Does |
| --- | --- |
| `grn` `gra` `grr` `gri` `grt` | Rename · code action · references · implementation · type def |
| `gO` | Document symbols (outline) |
| `K` / `<C-s>` | Hover / signature help (insert) |
| `[d` `]d` | Prev/next diagnostic (opens float on landing) |
| `[b` `]b` / `[q` `]q` | Prev/next buffer / quickfix item |
| `gc` `gcc` | Comment operator / line |
| `zi` | Toggle folds (treesitter-based) |
| `:Inspect` / `:InspectTree` | Highlight groups / live syntax tree |

## 4. New CLI tools

| Tool | Use |
| --- | --- |
| **`tuicr`** | Code review TUI, vim keys. `tuicr -w` uncommitted · `tuicr -r main..HEAD` branch · `tuicr pr 123` GitHub PR. `c` comment, `:submit` to approve/request-changes with inline comments. `--stdout` pipes markdown to an agent. |
| **`gh dash`** | PR/issue triage dashboard. `a` approve, `o` checkout. |
| **`sesh`** | Session picker — `prefix + o` in tmux. Creates the session if it doesn't exist. |
| **`atuin`** | `Ctrl-R` history search. `Tab` cycles filter modes — *directory* mode shows only commands run in this repo. |
| **`mise`** | Runtimes. Honours `.nvmrc`; `mise use node@22` writes a local `mise.toml`. |
| **`ast-grep`** | Structural search, backs `<leader>xa`. |

## 5. Behaviour changes worth knowing

- **Format on save no longer runs twice.** `prettierd` is used, falling back to `prettier`; both honour the repo's local binary *and* its pinned major version.
- **ESLint picks flat vs legacy `.eslintrc` per project root** — no global env var. Legacy repos need nothing special.
- **Editing an executable prettier config** (`.prettierrc.js`, `prettier.config.mjs`) restarts `prettierd` automatically; static configs never needed it.
- **Renaming a file in the explorer updates imports** (LSP-aware, via mini.files).
- **Large files** skip treesitter/LSP automatically.
- **`C-h/j/k/l`** now crosses Neovim splits *and* tmux panes seamlessly.
- **Undercurl works inside tmux** (`tmux-256color` + `usstyle`).
- **Python**: `ruff` (lint/format/imports) + `basedpyright` (types).
- Sessions are **not** restored automatically any more — create them on demand with `sesh`.

## 6. Removed

`noice.nvim`, `nui.nvim`, `nvim-origami`, `FixCursorHold.nvim`, `nvim-lint`,
`nvim-spectre` (→ grug-far), `telescope.nvim`, `neogen`, `Comment.nvim` +
`nvim-ts-context-commentstring` (→ ts-comments), `nvim-web-devicons` (→
mini.icons), `mason-conform.nvim`, all Copilot/CodeCompanion plugins, all PHP
support, `neotest-phpunit/-plenary/-bash`, `fnm` (→ mise), Ghostty config.

## 7. Not yet verified in real use

Everything below was wired up and checked as far as a scratch fixture allows,
but never exercised against a real project. If something misbehaves, start here.

| # | What to test | What good looks like | If it fails |
| - | ------------ | -------------------- | ----------- |
| 1 | **DAP · TypeScript** — breakpoint in a Next.js route, `<leader>db` then `<leader>dc` → *Attach to running Node process* (start `next dev` first) | Execution stops on the line; dap-ui opens with scopes | `:checkhealth dap`; confirm `js-debug-adapter` in `:Mason` |
| 2 | **DAP · Python** — breakpoint in a FastAPI handler, `<leader>dc` → *FastAPI (uvicorn)* | Stops on request; variables populate | Check `debugpy` in `:Mason` |
| 3 | **neotest · jest vs vitest** — open a repo with `*.test.ts` and `<leader>ts` | Each test appears **once**, run by the right runner | Both adapters can claim the same files. If duplicated, drop the unused adapter from `plugins/test.lua` |
| 4 | **neotest · discovery** — `<leader>tr` on a test | Test runs, output in summary | Discovery is treesitter-driven; `:TSUpdate` if empty |
| 5 | **ESLint · work repo** — open a file in `work/web` | Diagnostics match `npx eslint` on the same file | Compare `:LspInfo` root with the repo root; see `nvim/after/lsp/eslint.lua` |
| 6 | **Formatting · work repo** — save a `.ts` file | Diff matches `npx prettier --write` exactly | `:ConformInfo` shows which binary ran |
| 7 | **kulala** — real endpoint with auth/env vars in a `.http` file | `<leader>rs` returns the response in a split | Env vars resolve per `environment_scope`; `<leader>re` selects environment |
| 8 | **sidekick** — `<leader>ac`, then `<leader>af` to send the file | Claude session opens in tmux with the file as context; survives closing nvim | `:checkhealth sidekick` |
| 9 | **harpoon** — pin 3 files, close nvim, reopen | Same pins, per repo. A different repo has its own | Keyed by cwd — check you reopened from the same directory |
| 10 | **tuicr** — `tuicr pr <n>` on a real PR, comment, `:submit` → *Comment* | Inline comments land on the right lines on GitHub | Try `tuicr -r main..HEAD` locally first |
| 11 | **swap recovery** — open a file, edit without saving, `kill -9` the nvim, reopen | Neovim offers `:recover` | Requires `swapfile = true` (now on) |
| 12 | **`prefix + O`** — pick a project | Opens as a *new numbered window*, runs its `sesh.toml` startup command; picking it again selects the existing window | After editing `tmux.conf` you must reload with `prefix + R` |
| 13 | **`<leader>go`** — cursor on a line, in a repo with a GitHub remote | Browser opens at that line, pinned to the commit | |
| 14 | **LSP rename via explorer** — `<leader>e`, rename a component file | Imports across the project update automatically | Needs the LSP attached before renaming |

