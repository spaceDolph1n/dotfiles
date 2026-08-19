-- kulala.nvim -- HTTP client for .http files, JetBrains compatible. Requests
-- live next to the code they exercise, so an endpoint and its example change in
-- the same PR. Requires curl, git and tree-sitter-cli (all in the Brewfile).
return {
	"mistweaverco/kulala.nvim",
	ft = { "http", "rest" },
	cmd = { "Kulala" },
	keys = {
		{ "<leader>rs", desc = "Send request" },
		{ "<leader>ra", desc = "Send all requests" },
		{ "<leader>rr", desc = "Replay last request" },
		{ "<leader>rb", desc = "Open scratchpad" },
		{ "<leader>ri", desc = "Inspect request" },
		{ "<leader>rc", desc = "Copy as cURL" },
		{ "<leader>re", desc = "Select environment" },
	},
	opts = {
		-- kulala installs its own <leader>R* set by default; remap onto the
		-- lowercase group so it matches <leader>f / g / l and needs no shift.
		global_keymaps = true,
		global_keymaps_prefix = "<leader>r",
		kulala_keymaps_prefix = "",
		-- Split the response next to the request rather than replacing it.
		display_mode = "split",
		split_direction = "vertical",
		default_view = "body",
		-- Keep secrets out of the repo: values resolve from the environment.
		environment_scope = "b",
	},
}
