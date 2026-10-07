-- Stale swap files: nvim already deletes a dead owner's swap that holds no changes, so every
-- swap that still prompts has unsaved edits. Delete one silently only when its recovered text
-- is identical to the file on disk; otherwise the normal prompt decides.
local M = {}

local function owner_alive(pid)
	return pid and pid > 0 and vim.uv.kill(pid, 0) == 0
end

-- Returns "d" when the swap can go with nothing lost, nil to leave it to the prompt.
function M.choice(swapname, path)
	local info = vim.fn.swapinfo(swapname)
	if info.error or owner_alive(info.pid) or vim.fn.filereadable(path) == 0 then
		return nil
	end
	local recovered = vim.fn.tempname()
	vim.system({
		"nvim", "--headless", "-n", "--clean", "-r", swapname,
		"+silent! write! " .. vim.fn.fnameescape(recovered), "+qa!",
	}):wait(5000)
	local same = vim.fn.filereadable(recovered) == 1
		and table.concat(vim.fn.readfile(recovered, "b"), "\n") == table.concat(vim.fn.readfile(path, "b"), "\n")
	vim.fn.delete(recovered)
	return same and "d" or nil
end

return M
