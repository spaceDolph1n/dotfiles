-- Completion. blink.cmp is still the right call here: the matcher is a Rust
-- binary, it is the fastest of the current options, and Neovim's own
-- `vim.lsp.completion` has no snippet expansion, no fuzzy sorting and no
-- cmdline support -- so it is not yet a like-for-like replacement.
--
-- The Copilot source is gone along with the rest of the AI plugins.
return {
	"saghen/blink.cmp",
	dependencies = { "rafamadriz/friendly-snippets" },
	version = "1.*",
	-- Not lazy-loaded on an event: plugins/lsp.lua takes blink as a dependency
	-- so it can read `get_lsp_capabilities()` before servers are enabled, which
	-- forces it to load at startup anyway.

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = {
			preset = "none",
			["<CR>"] = { "accept", "fallback" },
			-- Tab now also drives snippet placeholders, so tabbing through a
			-- friendly-snippets expansion works instead of falling through.
			["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
			["<C-e>"] = { "hide", "fallback" },
			["<C-u>"] = { "scroll_documentation_up", "fallback" },
			["<C-d>"] = { "scroll_documentation_down", "fallback" },
		},

		appearance = {
			nerd_font_variant = "mono",
		},

		completion = {
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
			},
			-- Don't preselect: <CR> should insert a newline unless something
			-- was deliberately chosen with Tab.
			list = { selection = { preselect = false, auto_insert = true } },
			ghost_text = { enabled = true },
			menu = {
				draw = {
					treesitter = { "lsp" },
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind_icon", "kind", gap = 1 },
					},
				},
			},
		},

		-- Off by default in blink; the LSP already provides it and Neovim's
		-- native <C-s> signature help only works in insert mode on demand.
		signature = { enabled = true },

		-- Completion for `:` commands and `/` search.
		cmdline = {
			keymap = { preset = "inherit" },
			completion = { menu = { auto_show = true } },
		},

		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},

		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
