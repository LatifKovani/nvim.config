return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", "lewis6991/gitsigns.nvim" },
		event = "VeryLazy",
		config = function()
			local ok, m = pcall(require, "latif.plugins.lualine")
			if not ok or not m or type(m.setup) ~= "function" then
				return
			end
			pcall(m.setup)
		end,
	},
}
