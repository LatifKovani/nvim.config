return {
	"j-morano/buffer_manager.nvim",
	enabled = true,
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local opts = { noremap = true, silent = true }
		local keymap = vim.keymap

		-- Beautiful GUI buffer manager
		keymap.set("n", "<leader>bm", function()
			require("buffer_manager.ui").toggle_quick_menu()
		end, vim.tbl_extend("force", opts, { desc = "Buffer Manager (GUI)" }))
	end,
}
