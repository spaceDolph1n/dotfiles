-- Set conceallevel to 1 for markdown files
vim.cmd([[
  autocmd FileType markdown setlocal conceallevel=1
]])

vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt -- for conciseness

-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
opt.wrap = false -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line

opt.scrolloff = 10 -- scrolloff by 10 lines top and bottom

-- appearance

-- turn on termguicolors for nightfly colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- views can only be fully collapsed with the global statusline
opt.laststatus = 3

vim.api.nvim_create_user_command("SearchReplaceInQuickfix", function()
	-- Prompt the user for the "find" and "replace" strings, separated by a comma
	local input = vim.fn.input("Find and Replace (comma separated): ") -- example input: "myFunction, anotherF"

	-- Split the input into two parts based on the comma, preserving spaces
	local find, replace = input:match("^(.-),(.+)$")

	if find and replace then
		-- Escape special characters to prevent issues with the `:s` command
		find = vim.fn.escape(find, "/\\")
		replace = vim.fn.escape(replace, "/\\")

		-- Construct the command for search and replace in all files in the quickfix list
		local cmd = string.format("cfdo %s s/%s/%s/gc", "%", find, replace)

		-- Execute the command
		vim.cmd(cmd)
	else
		print("Please provide both find and replace strings, separated by a comma.")
	end
end, { nargs = 0 })

vim.api.nvim_create_user_command("ReplaceAll", function()
	local find = vim.fn.expand("<cword>")
	local replace = vim.fn.input('Replace "' .. find .. '" with: ')
	if replace ~= "" then
		local choice = vim.fn.input('Replace all "' .. find .. '" with "' .. replace .. '"? [y/n]: ')
		if choice:lower() == "y" then
			vim.cmd(":%s/" .. vim.fn.escape(find, "/\\") .. "/" .. vim.fn.escape(replace, "/\\") .. "/g")
			print("Replaced all occurrences")
		else
			print("Cancelled")
		end
	end
end, {})
