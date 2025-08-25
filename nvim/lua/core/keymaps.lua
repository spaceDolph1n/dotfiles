-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness
local fn = vim.fn -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jj to exit insert mode
keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode with jj" })
keymap.set("i", "jjw", "<ESC>:w!<cr>", { desc = "Exit insert mode and save" })

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

-- Keep last yanked when pasting
keymap.set("v", "p", '"_dP')

-- Octo and Prs
-- keymap.set("n", "<leader>oo", ":Octo<CR>", { desc = "Open Octo" })
-- keymap.set("n", "<leader>op", ":Octo pr list<CR>", { desc = "PR list" })
-- keymap.set("n", "<leader>oc", ":Octo pr create<CR>", { desc = "Create PR" })
-- keymap.set("n", "<leader>or", ":Octo review start<CR>", { desc = "Start PR Review" })

-- Go to the beginning and end of the line
keymap.set({ "n", "o", "v" }, "H", "^", { desc = "Go to beginning of the line" })
keymap.set({ "n", "o", "v" }, "L", "$", { desc = "Go to end of the line" })

keymap.set("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

keymap.set("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

keymap.set("n", "<leader>tr", function()
	vim.lsp.buf.rename()
end, { desc = "LSP rename" })

-- Macros

-- macro to add a console.log statement with visual selection
-- vim.cmd([[ let @l = "viwyoconsole.log('\<Esc>pa:\<Esc>la, \<Esc>pl" ]])
--
