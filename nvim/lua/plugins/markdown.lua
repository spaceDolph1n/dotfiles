return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		-- Rendering needs the `markdown` + `markdown_inline` parsers, which
		-- core bundles -- no nvim-treesitter dependency required.
		dependencies = { "echasnovski/mini.icons" },
		ft = { "markdown", "mdx" },
		---@module 'render-markdown'
		---@type fun(): render.md.UserConfig
		opts = function()
			-- Options merge into the defaults, so the per-domain link icons have to be
			-- blanked one by one rather than replaced with an empty table.
			local custom = {}
			for name in pairs(require("render-markdown.settings").link.default.custom) do
				custom[name] = { icon = "" }
			end
			-- Virtual rows around each code block: padding above and below, and under
			-- a language a divider that gets space of its own. Also dims frontmatter.
			local query = vim.treesitter.query.parse("markdown", "[(fenced_code_block) @block (minus_metadata) @meta]")
			local function extra_marks(ctx)
				local width = vim.o.columns
				local pad = { { (" "):rep(width), "RenderMarkdownCodeHeader" } }
				local divider = { { "  ", "RenderMarkdownCodeDivider" }, { ("─"):rep(width), "RenderMarkdownCodeDivider" } }
				local function row(start_row, conceal, opts)
					return { conceal = conceal, start_row = start_row, start_col = 0, opts = opts }
				end
				local marks = {}
				for id, node in query:iter_captures(ctx.root, ctx.buf) do
					local first, _, last, last_col = node:range()
					-- Nodes end at column 0 of the line after their closing delimiter.
					local closing = last_col == 0 and last - 1 or last
					if query.captures[id] == "meta" then
						marks[#marks + 1] = row(first, false, {
							end_row = closing + 1,
							hl_group = "RenderMarkdownFrontmatter",
							priority = 250,
						})
					elseif closing - 1 > first then
						local info = node:named_child(1)
						local has_language = info ~= nil and info:type() == "info_string"
						-- Mermaid blocks are left to snacks.image, which draws them as diagrams.
						local diagram = has_language and vim.treesitter.get_node_text(info, ctx.buf):match("^mermaid")
						if not diagram then
							-- Without a language both fences are hidden, so the padding sits
							-- on the code itself.
							marks[#marks + 1] = row(has_language and first or first + 1, false, { virt_lines = { pad }, virt_lines_above = true })
							if has_language then
								marks[#marks + 1] = row(first, true, { virt_lines = { divider } })
							end
							marks[#marks + 1] = row(closing - 1, false, { virt_lines = { pad } })
						end
					end
				end
				return marks
			end
			return {
				-- "codecompanion" dropped along with the AI plugins.
				ft = { "markdown", "mdx" },
				heading = { sign = false, icons = { "" }, position = "inline", backgrounds = {} },
				bullet = { icons = { "•", "◦" } },
				code = {
					-- snacks.image draws these as diagrams. Hiding their fences here would
					-- hide the image too: snacks anchors it below the closing fence.
					disable = { "mermaid" },
					sign = false,
					-- Hides the closing fence; the opening one stays because it shows the language.
					border = "hide",
					left_pad = 2,
					language_pad = 2,
					-- Spaces on the code background, so the language row is part of the block.
					language_border = " ",
					highlight_border = "RenderMarkdownCodeHeader",
					highlight_language = "RenderMarkdownCodeHeader",
				},
				link = {
					hyperlink = "",
					email = "",
					wiki = { icon = "", scope_highlight = "RenderMarkdownLinkUnderline" },
					custom = custom,
				},
				-- The states obsidian.nvim's <CR> cycles through between [ ] and [x].
				checkbox = {
					checked = { scope_highlight = "RenderMarkdownDone" },
					custom = {
						progress = { raw = "[~]", rendered = "󰔟 ", highlight = "DiagnosticInfo" },
						important = { raw = "[!]", rendered = "󰀦 ", highlight = "DiagnosticError" },
						forwarded = { raw = "[>]", rendered = "󰒊 ", highlight = "Comment" },
					},
				},
				html = { tag = { kbd = { icon = "", scope_highlight = "RenderMarkdownCodeInline" } } },
				custom_handlers = { markdown = { extends = true, parse = extra_marks } },
			}
		end,
		config = function(_, opts)
			require("render-markdown").setup(opts)
			-- Colours come from theme groups, not hex, so every theme gets its own.
			-- DiagnosticWarn is orange or gold in all three, and no H1-H3 uses it.
			local function restyle()
				local function hl(name)
					return vim.api.nvim_get_hl(0, { name = name, link = false })
				end
				local bold = hl("DiagnosticWarn").fg
				vim.api.nvim_set_hl(0, "@markup.strong", { fg = bold, bold = true })
				vim.api.nvim_set_hl(0, "RenderMarkdownFrontmatter", { fg = hl("Comment").fg })
				vim.api.nvim_set_hl(0, "RenderMarkdownDone", { fg = hl("Comment").fg, strikethrough = true })
				-- rose-pine puts a background behind a ticked checkbox; keep only its colour.
				for _, group in ipairs({ "@markup.list.checked", "@markup.list.checked.markdown" }) do
					vim.api.nvim_set_hl(0, group, { fg = hl(group).fg })
				end

				-- Links need a colour nothing else uses. rose-pine gives them its H1
				-- colour, so fall back to one no heading or bold claims.
				local taken = { [bold] = true }
				for level = 1, 3 do
					taken[hl("@markup.heading." .. level .. ".markdown").fg or 0] = true
				end
				local link = hl("@markup.link.label.markdown_inline").fg or hl("@markup.link.label").fg
				if taken[link] then
					link = hl("DiagnosticError").fg
				end
				-- The markdown_inline variant is what themes colour, and marksman's
				-- semantic token (class) paints over both, so all of them need it.
				local link_groups = {
					"@markup.link.label",
					"@markup.link.label.markdown_inline",
					"@lsp.type.class.markdown",
					"RenderMarkdownWikiLink",
					"RenderMarkdownLink",
				}
				for _, group in ipairs(link_groups) do
					vim.api.nvim_set_hl(0, group, { fg = link })
				end
				-- Underline goes only on real links. These groups also cover `[~]`-style
				-- checkboxes, whose icons are drawn combined and would inherit it.
				for _, group in ipairs({ "RenderMarkdownLinkUnderline", "@markup.link.underline" }) do
					vim.api.nvim_set_hl(0, group, { fg = link, underline = true })
				end

				-- kanagawa and kanso leave code blocks transparent; ColorColumn is a
				-- subtle step off the background in all three themes.
				local muted, code_bg = hl("Comment").fg, hl("RenderMarkdownCode").bg
				if not code_bg then
					code_bg = hl("ColorColumn").bg
					vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = code_bg })
				end
				vim.api.nvim_set_hl(0, "RenderMarkdownCodeHeader", { fg = muted, bg = code_bg })
				vim.api.nvim_set_hl(0, "RenderMarkdownCodeDivider", { fg = muted, bg = code_bg })
				-- The fill spaces use a group the plugin derives from the one above,
				-- keeping only its bg (as fg). Derive it first so it is cached, then
				-- overwrite it to keep the bg; ColorScheme re-derives it before this runs.
				local derived = require("render-markdown.core.colors").bg_as_fg("RenderMarkdownCodeHeader", true)
				if derived then
					vim.api.nvim_set_hl(0, derived, { bg = code_bg })
				end
			end
			restyle()
			vim.api.nvim_create_autocmd("ColorScheme", { callback = restyle })
		end,
	},
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*",
		ft = "markdown",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		init = function()
			-- The defaults bind [o/]o per buffer, which shadows mini.bracketed's
			-- oldfile jump. Keep <CR> as it was; link hops move to [k/]k.
			vim.g.obsidian_default_keymap = false
			vim.api.nvim_create_autocmd("User", {
				pattern = "ObsidianNoteEnter",
				callback = function(ev)
					local actions = require("obsidian.actions")
					local map = function(lhs, rhs, desc, expr)
						vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc, expr = expr })
					end
					map("<CR>", actions.smart_action, "Obsidian smart action", true)
					map("]k", function() actions.nav_link("next") end, "Next link")
					map("[k", function() actions.nav_link("prev") end, "Previous link")
				end,
			})
		end,
		-- Links only go one way in the file itself. These make the vault
		-- navigable in both directions from inside Neovim, which is the whole
		-- reason to keep obsidian.nvim now that Obsidian itself is gone.
		keys = {
			{ "<leader>kb", "<cmd>Obsidian backlinks<cr>", ft = "markdown", desc = "Backlinks to this note" },
			{ "<leader>kl", "<cmd>Obsidian links<cr>", ft = "markdown", desc = "Links in this note" },
			-- Note *creation* is unbound on purpose: notes are made in mini.files,
			-- so note_id_func never runs and cannot impose timestamp IDs over the
			-- kebab-case convention. Finding notes is the snacks pickers' job.
			{
				"<leader>ki",
				"<cmd>Obsidian link<cr>",
				mode = { "n", "v" },
				ft = "markdown",
				desc = "Link word to existing note",
			},
			{ "<leader>kt", "<cmd>Obsidian tags<cr>", ft = "markdown", desc = "Tags" },
			{ "<leader>kc", "<cmd>Obsidian toc<cr>", ft = "markdown", desc = "Table of contents" },
		},
		---@module 'obsidian'
		---@type obsidian.config
		opts = {
			-- Fixes legacy command deprecation warning
			legacy_commands = false,
			workspaces = {
				{
					name = "second brain",
					path = "~/.sb/second-brain/",
				},
			},
			-- Removed deprecated 'completion' block.
			-- obsidian-ls (built-in LSP) now handles completion automatically via blink.cmp
			picker = {
				name = "snacks.picker",
			},
			-- render-markdown.nvim does all the rendering; running obsidian.nvim's
			-- UI as well double-conceals the same syntax.
			ui = { enable = false },
			-- Written on save for any vault note, which is what gives files made in
			-- mini.files a header. Matches the vault schema; the builtin only emits
			-- id/aliases/tags.
			frontmatter = {
				enabled = true,
				func = function(note)
					local out = {
						id = note.id,
						aliases = note.aliases,
						tags = note.tags,
					}
					-- Carry over fields obsidian.nvim doesn't know about --
					-- `created`, `found-in`, and anything added later.
					if note.metadata and not vim.tbl_isempty(note.metadata) then
						for key, value in pairs(note.metadata) do
							out[key] = value
						end
					end
					-- Stamped once, on the first write; never rewritten after.
					out.created = out.created or os.date("%Y-%m-%d")

					-- `type` is OKF's one required field, and vault-lint flags a
					-- note without it. Default from the folder, which is right
					-- nearly always; anything else is a one-word edit. Never
					-- overwritten, so a corrected type stays corrected.
					if not out.type then
						local path = tostring(note.path or "")
						if path:find("00 %- zettelkasten") then
							out.type = "concept"
						elseif path:find("0 %- inbox") then
							out.type = "inbox"
						end
					end

					return out
				end,
				-- `type` is OKF's one required field and belongs with the other
				-- identity keys. status/stale_after/sources are OKF-optional and
				-- absent unless the note has something to say with them.
				sort = {
					"id",
					"aliases",
					"tags",
					"type",
					"status",
					"stale_after",
					"created",
					"found-in",
					"sources",
				},
			},
		},
	},
}
