return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		icons = {
			breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
			separator = "➜", -- symbol used between a key and it's label
			group = "", -- symbol prepended to a group
		},
		preset = "classic",
		win = {
			border = vim.g.border_enabled and "rounded" or "none",
			no_overlap = false,
		},
		delay = function()
			return 0
		end,
	},
	config = function(_, opts)
		require("which-key").setup(opts)
		require("which-key").add({
			{
				{ "<leader>s", group = "Sessions", icon = "󰔚" },
				{ "<leader>e", group = "FileExplorer", icon = "󰮗" },
				{ "<leader>f", group = "Find", icon = "" },
				{ "<leader>h", group = "LSP", icon = "" },
				{ "<leader>r", group = "Neovim", icon = "" },
				{ "<leader>o", group = "Options", icon = "" },
				{ "<leader>t", group = "Terminal", icon = "" },
				{ "<leader>x", group = "Diagnostics", icon = "" },
				{ "<leader>k", group = "Buffers", icon = "" },
				{ "<leader>l", group = "Git", icon = "" },
				{ "<leader>G", group = "Git", icon = "" },
			},
		})
		vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "#040405" }) -- Main background
		vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "#040405", fg = "#565f89" }) -- Border color
		vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "#040405" }) -- Normal text background
	end,
}
