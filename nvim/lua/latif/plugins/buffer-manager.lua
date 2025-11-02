return {
	"j-morano/buffer_manager.nvim",
	enabled = true,
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local opts = { noremap = true, silent = true }
		local keymap = vim.keymap

		-- Set custom highlight groups
		vim.api.nvim_set_hl(0, "BufferManagerNormal", { bg = "#040405", fg = "#ebdbb2" })
		vim.api.nvim_set_hl(0, "BufferManagerBorder", { bg = "#040405", fg = "#565f89" })

		-- Setup buffer_manager
		require("buffer_manager").setup({
			select_menu_item_commands = {
				v = {
					key = "<C-v>",
					command = "vsplit",
				},
				h = {
					key = "<C-h>",
					command = "split",
				},
			},
			focus_alternate_buffer = false,
			short_file_names = true,
			short_term_names = true,
			loop_nav = true,
			line_keys = "", -- Remove line numbers
			-- Make window larger to reduce gray padding
			width = 0.7, -- 70% of screen width
			height = 0.5, -- 50% of screen height
			win_extra_options = {
				winhighlight = "Normal:BufferManagerNormal,NormalFloat:BufferManagerNormal,FloatBorder:BufferManagerBorder,EndOfBuffer:BufferManagerNormal",
				number = false,
				relativenumber = false,
			},
			borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		})

		-- Override the NormalFloat for ALL floating windows to use your color
		-- This will affect the gray area around buffer_manager
		local original_normalfloat = vim.api.nvim_get_hl(0, { name = "NormalFloat" })

		-- Create an autocommand to set the background when buffer_manager opens
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "buffer_manager",
			callback = function()
				-- Temporarily change NormalFloat to match your theme
				vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#040405", fg = "#ebdbb2" })
			end,
		})

		-- Restore NormalFloat when buffer_manager closes
		vim.api.nvim_create_autocmd("BufLeave", {
			pattern = "*",
			callback = function()
				if vim.bo.filetype == "buffer_manager" then
					-- Restore original NormalFloat
					vim.api.nvim_set_hl(0, "NormalFloat", original_normalfloat)
				end
			end,
		})

		-- Beautiful GUI buffer manager
		keymap.set("n", "<leader>bm", function()
			require("buffer_manager.ui").toggle_quick_menu()
		end, vim.tbl_extend("force", opts, { desc = "Buffer Manager (GUI)" }))
	end,
}
