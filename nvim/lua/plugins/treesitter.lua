-- nvim-treesitter `main` branch: the 0.12-native rewrite.
--
-- Unlike the old `master` branch, this plugin no longer owns highlighting,
-- folding or indentation -- it only installs parsers + queries. The features
-- themselves come from core `vim.treesitter`, enabled by the FileType autocmd
-- below. `master` is frozen upstream and only maintained for Nvim 0.11.
--
-- Requires the `tree-sitter` CLI (brew install tree-sitter-cli).
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false, -- upstream explicitly does not support lazy-loading
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup({
			-- Prepended to runtimepath, so these win over the parsers Neovim bundles.
			install_dir = vim.fn.stdpath("data") .. "/site",
		})

		require("nvim-treesitter").install({
			-- Core
			"bash",
			"diff",
			"git_rebase",
			"gitcommit",
			"lua",
			"luadoc",
			"query",
			"regex",
			"vim",
			"vimdoc",

			-- Web fundamentals
			"css",
			"html",
			"javascript",
			"jsdoc",
			"typescript",
			"tsx", -- was missing despite Next.js/React in the stack

			-- Frameworks & templating
			"graphql",
			"prisma",
			"vue",

			-- Backend
			"python", -- was missing despite FastAPI in the stack
			"sql",

			-- Data & config formats
			-- (no `jsonc` parser upstream; the `jsonc` filetype resolves to
			--  the `json` parser through core's filetype->lang mapping)
			"json",
			"toml",
			"yaml",

			-- Docs
			"markdown",
			"markdown_inline",
		})

		-- Core owns highlighting/folding now; opt in per-buffer.
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
			callback = function(ev)
				-- `get_lang` falls back to returning the filetype itself, so this
				-- is never nil for plugin UI buffers like `minifiles` or `lazy`.
				local lang = vim.treesitter.language.get_lang(ev.match)
				if not lang then
					return
				end

				-- `language.add()` returns false/nil when no parser is installed
				-- and does NOT raise, so pcall's first value only tells us it
				-- did not throw -- the second is the one that matters. Checking
				-- pcall alone lets every parser-less filetype through to
				-- `start()`, which then asserts: opening a directory hit
				-- mini.files' `minifiles` buffer and errored on every plugin UI
				-- buffer thereafter.
				local ok, added = pcall(vim.treesitter.language.add, lang)
				if not ok or not added then
					return -- no parser for this filetype; leave regex syntax alone
				end

				if not pcall(vim.treesitter.start, ev.buf, lang) then
					return
				end

				-- Treesitter folds. `foldlevel`/`foldlevelstart` are pinned to 99
				-- in core/options.lua, so nothing is folded on open.
				pcall(function()
					vim.wo[0][0].foldmethod = "expr"
					vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
				end)

				-- Note: treesitter indentation (`indentexpr`) is still flagged
				-- experimental upstream and fights prettier on .vue/.tsx, so it
				-- is deliberately left off.
			end,
		})
	end,
}
