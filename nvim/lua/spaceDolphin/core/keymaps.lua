-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode with jj" })

-- clear search highlights
keymap.set("n", "<leader>uh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
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

-- Save file
keymap.set("n", "<leader>w", ":update<CR>", { desc = "Save" })
keymap.set("n", "<leader>W", ":wa<CR>", { desc = "Save all" })
keymap.set("n", "<leader>q", ":quit<CR>", { desc = "Quit" })
keymap.set("n", "<leader>Q", ":qa<Return>", { desc = "Quit all" })

-- Find and center
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- Vertical scroll and center
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep last yanked when pasting
keymap.set("v", "p", '"_dP')

-- Octo and Prs
keymap.set("n", "<leader>oo", ":Octo<CR>", { desc = "Open Octo" })
keymap.set("n", "<leader>op", ":Octo pr list<CR>", { desc = "Octo PR list" })
keymap.set("n", "<leader>oc", ":Octo pr create<CR>", { desc = "Octo PR create" })
keymap.set("n", "<leader>or", ":Octo review start<CR>", { desc = "Start Review on PR" })

-- Run custom search and replace command in a quick fix list
keymap.set(
	"n",
	"<leader>tt",
	":SearchReplaceInQuickfix<CR>",
	{ desc = "Search and Replace", noremap = true, silent = true }
)

-- Pressing enter in normal mode will insert a new line
keymap.set("n", "<CR>", "o<Esc>", { noremap = true, silent = true })

-- Go to the beginning of the line
keymap.set("n", "B", "0", { desc = "Go to beginning of the line" })

-- Go to the end of the line
keymap.set("n", "E", "$", { desc = "Go to end of the line" })
