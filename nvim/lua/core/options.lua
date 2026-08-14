local o = vim.o

-- line numbers
o.number = true
o.relativenumber = true

-- tabs & indentation (prettier defaults)
o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.autoindent = true

-- line wrapping
o.wrap = false

-- search
o.ignorecase = true
o.smartcase = true
-- Use ripgrep for :grep / :grep-driven quickfix.
o.grepprg = "rg --vimgrep --smart-case"
o.grepformat = "%f:%l:%c:%m"
-- Live preview of :s, :g and friends in a split.
o.inccommand = "split"

-- cursor & scrolling
o.cursorline = true
o.scrolloff = 10
o.sidescrolloff = 8
-- Scroll wrapped lines by screen line rather than jumping a whole line.
o.smoothscroll = true

-- appearance
-- Still set explicitly: Neovim auto-detects truecolor, but the current tmux
-- config advertises `screen-256color`, which defeats that detection.
o.termguicolors = true
o.background = "dark"
o.signcolumn = "yes"
-- 0.11+: one global default border for every floating window (LSP hover,
-- signature help, diagnostics floats, mason, lazy), replacing per-plugin
-- `border = "rounded"` settings.
o.winborder = "rounded"
-- Global statusline (lualine) + per-window filename, so splits stay labelled.
o.laststatus = 3
o.winbar = "%t"

-- Floating cmdline and message windows, built into Neovim 0.12 (`:h ui2`).
-- This is what noice.nvim used to do here -- see the note in plugins/ui.lua --
-- but in core, so it moves with Neovim instead of chasing its internals.
-- `targets = "msg"` puts native messages in the ephemeral floating window;
-- snacks.notifier still owns vim.notify, which ui2 does not touch.
--
-- cmdheight = 0 is what actually reclaims the bottom line, and it is only set
-- when ui2 is on: `:h 'cmdheight'` warns that zero is experimental and "works
-- better with |ui2| enabled", so without it the messages would go somewhere
-- invisible. `vim._core.ui2` is an underscore-private path that can be renamed
-- between releases, so a failure here leaves the cmdline exactly as it was
-- rather than breaking startup.
if pcall(function()
	require("vim._core.ui2").enable({ msg = { targets = "msg" } })
end) then
	o.cmdheight = 0
end

-- editing behaviour
o.clipboard = "unnamedplus"
o.splitright = true
o.splitbelow = true
-- Keep the text on screen in the same place when a split opens or closes.
o.splitkeep = "screen"
-- Select a rectangle in visual block mode even past end-of-line.
o.virtualedit = "block"
-- Prompt to save instead of failing on :q with unsaved changes.
o.confirm = true
o.spelloptions = "camel"

-- files & undo
-- Swap is ON. Neovim writes swap files to stdpath("state")/swap, not next to
-- your code, so the historical reason to disable it (litter in the repo) no
-- longer applies. With it off, a killed tmux session or a crash loses every
-- unsaved buffer with no recovery path -- which is exactly what nearly
-- happened when clearing out stale sessions. `:recover` needs this.
o.swapfile = true
-- Persistent undo. Previously buried in the undotree plugin's `init`, which
-- meant undo history depended on a plugin having loaded.
o.undofile = true
o.undodir = vim.fn.stdpath("state") .. "/undo"
-- Reload files changed outside Neovim (see the FocusGained autocmd).
o.autoread = true

-- CursorHold-driven features (snacks.words, LSP document highlight) sit behind
-- this. The default of 4000ms makes them feel broken.
o.updatetime = 200

-- folding: treesitter provides `foldexpr` per buffer (plugins/treesitter.lua);
-- these pin foldlevel so nothing starts folded, and `h`/`l` fold ergonomics live
-- in core/keymaps.lua. nvim-origami supplied all three until it was dropped
-- 2026-08-06 -- the removal note only accounted for foldexpr and the fold column.
o.foldenable = true
o.foldlevel = 99
o.foldlevelstart = 99

--------------------------------------------------------------------------------
-- Diagnostics
--------------------------------------------------------------------------------
-- Lives here, not in plugins/lsp.lua: `vim.diagnostic` is core and applies to
-- every diagnostic producer, so it must not depend on a plugin having loaded.
vim.diagnostic.config({
	severity_sort = true,
	update_in_insert = false,
	-- virtual_lines shows the full message under the cursor line only, so
	-- virtual_text would just duplicate it on every other line.
	virtual_text = false,
	virtual_lines = { current_line = true },
	underline = { severity = { min = vim.diagnostic.severity.WARN } },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	},
	float = { source = "if_many" },
	-- 0.11+: ]d / [d open the diagnostic float on landing.
	jump = { float = true },
})
