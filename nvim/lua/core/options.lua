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

-- Floating cmdline and messages, native in 0.12 (`:h ui2`) -- what noice.nvim
-- used to do here. cmdheight = 0 sits inside the guard because it needs ui2 on,
-- and `vim._core.ui2` is private, so a rename must not break startup.
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
-- Swap is ON: Neovim writes to stdpath("state")/swap, not next to the code, so
-- the old reason to disable it is gone. Off, a crash or killed tmux session
-- loses every unsaved buffer with no `:recover`.
o.swapfile = true
-- Persistent undo, in core so it does not depend on a plugin having loaded.
o.undofile = true
o.undodir = vim.fn.stdpath("state") .. "/undo"
-- Reload files changed outside Neovim (see the FocusGained autocmd).
o.autoread = true

-- CursorHold-driven features (snacks.words, LSP document highlight) sit behind
-- this. The default of 4000ms makes them feel broken.
o.updatetime = 200

-- folding: treesitter sets `foldexpr` per buffer (plugins/treesitter.lua) and
-- the h/l fold ergonomics live in core/keymaps.lua; these only pin foldlevel so
-- nothing starts folded.
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
