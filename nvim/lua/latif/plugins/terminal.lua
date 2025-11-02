return {
	"akinsho/toggleterm.nvim",
	init = function()
		vim.keymap.set(
			"n",
			"<leader>tf",
			"<cmd>TermNew direction=float<cr>",
			{ desc = "ToggleTerm | New Float Terminal", silent = true }
		)
		vim.keymap.set(
			"n",
			"<leader>tF",
			"<cmd>ToggleTerm direction=float<cr>",
			{ desc = "ToggleTerm | Toggle Float Terminal", silent = true }
		)
		vim.keymap.set(
			"n",
			"<leader>th",
			"<cmd>TermNew direction=horizontal<cr>",
			{ desc = "ToggleTerm | New Horizontal Terminal", silent = true }
		)
		vim.keymap.set(
			"n",
			"<leader>tH",
			"<cmd>ToggleTerm direction=horizontal<cr>",
			{ desc = "ToggleTerm | Toggle Horizontal Terminal", silent = true }
		)
		vim.keymap.set(
			"n",
			"<leader>tv",
			"<cmd>TermNew direction=vertical<cr>",
			{ desc = "ToggleTerm | New Vertical Terminal", silent = true }
		)
		vim.keymap.set(
			"n",
			"<leader>tV",
			"<cmd>ToggleTerm direction=vertical<cr>",
			{ desc = "ToggleTerm | Toggle Vertical Terminal", silent = true }
		)
		vim.keymap.set(
			"n",
			"<leader>ts",
			"<cmd>TermSelect<cr>",
			{ desc = "ToggleTerm | Select Terminal", silent = true }
		)
		vim.keymap.set(
			"n",
			"<leader>tt",
			"<cmd>ToggleTermToggleAll<cr>",
			{ desc = "ToggleTerm | Toggle/Close All Terminal", silent = true }
		)
	end,
	config = function()
		-- Set custom highlight groups for toggleterm
		vim.api.nvim_set_hl(0, "ToggleTermNormal", { bg = "#040405", fg = "#ebdbb2" })
		vim.api.nvim_set_hl(0, "ToggleTermBorder", { bg = "#040405", fg = "#565f89" })

		-- Terminal mode keymaps for easier exit
		vim.keymap.set("t", "<C-q>", "<C-\\><C-n>:q<CR>", { noremap = true, silent = true, desc = "Quit terminal" })
		vim.keymap.set("t", "jk", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Exit terminal mode" })
		vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Exit terminal mode" })

		require("toggleterm").setup({
			size = function(term)
				if term.direction == "horizontal" then
					return vim.o.lines * 0.4
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.5
				end
			end,
			open_mapping = [[<c-\>]],
			hide_numbers = true,
			shade_terminals = false,
			insert_mappings = true,
			persist_size = true,
			direction = "float",
			close_on_exit = true,
			shell = vim.o.shell,
			autochdir = true,
			highlights = {
				Normal = {
					link = "ToggleTermNormal",
				},
				NormalFloat = {
					link = "ToggleTermNormal",
				},
				FloatBorder = {
					link = "ToggleTermBorder",
				},
			},
			float_opts = {
				border = "single", -- Same border style as buffer-manager
				height = math.ceil(vim.o.lines * 1.0 - 4),
				width = math.ceil(vim.o.columns * 0.8),
				winblend = 0,
			},
		})
	end,
}
