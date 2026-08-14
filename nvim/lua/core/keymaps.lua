-- Leader is set in init.lua, before any plugin spec is loaded.

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- Exit insert mode.
--
-- `jjw` (exit + save) used to exist alongside this. Because `jj` was a prefix
-- of it, every single insert-mode exit blocked for `timeoutlen` (500ms) waiting
-- to see whether a `w` was coming. `<leader>w` already saves.
keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode with jj" })

-- clear search highlights
keymap.set("n", "<leader>uh", ":nohl<CR>", { desc = "Clear search highlights" })

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>ss", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Reselect visual selection after indenting.
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Maintain the cursor position when yanking a visual selection.
keymap.set("v", "y", "myy`y")
keymap.set("v", "Y", "myY`y")

-- When text is wrapped, move by terminal rows, not lines, unless a count is provided.
keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- Fold with h / l, the one thing lost when nvim-origami was dropped. Treesitter
-- still supplies `foldexpr`; this is only the ergonomics.
--   h  closes the fold when the cursor sits at or before the first non-blank
--   l  opens a closed fold
-- Both fall through to normal motion otherwise, and with any count, so `5h`
-- and `d2l` are untouched.
keymap.set("n", "h", function()
	if vim.v.count > 0 or vim.fn.foldlevel(".") == 0 then
		return "h"
	end

	local firstNonBlank = vim.fn.match(vim.fn.getline("."), "\\S") + 1
	local isAtIndent = firstNonBlank > 0 and vim.fn.col(".") <= firstNonBlank

	return isAtIndent and "zc" or "h"
end, { expr = true, desc = "Close fold at indent, else left" })

keymap.set("n", "l", function()
	if vim.v.count > 0 then
		return "l"
	end

	return vim.fn.foldclosed(".") ~= -1 and "zo" or "l"
end, { expr = true, desc = "Open a closed fold, else right" })

-- Paste replace visual selection without copying it.
keymap.set("v", "p", '"_dP')

-- Easy insertion of a trailing ; or , from insert mode.
keymap.set("i", ";;", "<Esc>A;<Esc>")
keymap.set("i", ",,", "<Esc>A,<Esc>")

-- Sending single char delete to black hole register
keymap.set("n", "x", '"_x')

-- Sending Visual mode deletions to black hole register
keymap.set("v", "x", '"_d', { noremap = true, silent = true })

-- Save file
keymap.set("n", "<leader>w", ":update<CR>")
keymap.set("n", "<leader>W", ":wa<CR>")
keymap.set("n", "<leader>q", ":quit<CR>")
keymap.set("n", "<leader>Q", ":qa<Return>")

-- Find and center
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- Vertical scroll and center
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- (The "keep last yanked when pasting" mapping for `v p` is already set above;
--  it used to be defined a second time here.)

-- Go to the beginning and end of the line
keymap.set({ "n", "o", "v" }, "H", "^", { desc = "Go to beginning of the line" })
keymap.set({ "n", "o", "v" }, "L", "$", { desc = "Go to end of the line" })

keymap.set("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

keymap.set("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

-- `<leader>xr` (LSP rename) removed: Neovim 0.11+ binds this natively as `grn`.
-- See the native-defaults list in the README.

-- Macros

-- macro to add a console.log statement with visual selection
-- vim.cmd([[ let @l = "viwyoconsole.log('\<Esc>pa:\<Esc>la, \<Esc>pl" ]])
--
