return {
	"utilyre/barbecue.nvim",
	name = "barbecue",
	version = "*",
	dependencies = {
		"SmiteshP/nvim-navic",
		"nvim-tree/nvim-web-devicons", -- optional dependency
	},
	opts = {
		theme = {
			normal = { bg = "#040405", fg = "#f9e2af" },
			context = { bg = "#040405", fg = "#f9e2af" },
			dirname = { bg = "#040405", fg = "#aba79f" },
			seperator = { bg = "#040405", fg = "#cdd6f4" },
		},
	},
}
