local function augroup(name)
	return vim.api.nvim_create_augroup("core_" .. name, { clear = true })
end

-- Restore the last cursor position when reopening a file.
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("last_cursor"),
	callback = function(ev)
		-- Commit messages and rebase todos should always open at the top.
		if vim.list_contains({ "gitcommit", "gitrebase" }, vim.bo[ev.buf].filetype) then
			return
		end
		local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
		local lcount = vim.api.nvim_buf_line_count(ev.buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Briefly highlight yanked text.
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
})

-- Pick up changes made outside Neovim (branch switches, rebases, formatters
-- run from another pane) instead of sitting on a stale buffer.
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd.checktime()
		end
	end,
})

-- Conceal markdown syntax (links, emphasis) so render-markdown can draw it.
-- Was a `vim.cmd([[autocmd ...]])` block in options.lua.
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("markdown"),
	pattern = { "markdown", "mdx" },
	callback = function()
		vim.opt_local.conceallevel = 1
		vim.opt_local.wrap = true
		-- Wrap at words; wrapped list items indent under their text.
		vim.opt_local.linebreak = true
		vim.opt_local.breakindent = true
		vim.opt_local.breakindentopt = "list:-1"
		vim.opt_local.formatlistpat = [[^\s*\(\d\+[.)]\|[-*+]\)\s\+\(\[.\]\s\+\)\?]]
		vim.opt_local.spell = true
	end,
})

-- A dead nvim's swap whose recovered text already matches the file: delete it without asking.
vim.api.nvim_create_autocmd("SwapExists", {
	group = augroup("stale_swap"),
	callback = function(ev)
		local choice = require("core.swap").choice(vim.v.swapname, vim.fn.fnamemodify(ev.file, ":p"))
		if choice then
			vim.v.swapchoice = choice
			vim.notify("Deleted a stale swap: its text matched the file.", vim.log.levels.INFO)
		end
	end,
})
