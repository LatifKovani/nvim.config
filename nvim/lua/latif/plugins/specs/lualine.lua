-- nvim/lua/latif/plugins/specs/lualine.lua
return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", "lewis6991/gitsigns.nvim" },
		event = "VeryLazy",
		config = function()
			-- Import from core directory instead
			local ok, m = pcall(require, "latif.core.lualine")
			if not ok or not m or type(m.setup) ~= "function" then
				return
			end
			pcall(m.setup)
		end,
	},
}
