return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local colors = {
			blue = "#539bf5",
			cyan = "#76E3EA",
			black = "#22272e",
			white = "adbac7",
			red = "#A05350",
			violet = "#DCBDFB",
			grey = "#303030",
			green = "#8DDB8C",
		}

		local bubbles_theme = {
			normal = {
				a = { fg = colors.black, bg = colors.blue },
				b = { fg = colors.white, bg = colors.grey },
				c = { fg = colors.white, bg = colors.black },
			},

			insert = { a = { fg = colors.black, bg = colors.green } },
			visual = { a = { fg = colors.black, bg = colors.cyan } },
			replace = { a = { fg = colors.black, bg = colors.red } },
			command = { a = { fg = colors.black, bg = colors.violet } },

			inactive = {
				a = { fg = colors.white, bg = colors.black },
				b = { fg = colors.white, bg = colors.black },
				c = { fg = colors.white, bg = colors.black },
			},
		}

		vim.api.nvim_create_autocmd({ "UiEnter", "ColorScheme" }, {
			callback = function()
				local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
				local statusline = vim.api.nvim_get_hl(0, { name = "StatusLine" })
				-- Create a new table for the updated highlight group
				local updated_statusline = vim.tbl_extend("force", statusline, { bg = normal.bg })
				vim.api.nvim_set_hl(0, "StatusLine", updated_statusline)
			end,
		})

		require("lualine").setup({
			options = {
				theme = bubbles_theme,
				component_separators = "",
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
				lualine_b = { "filename", "branch" },
				lualine_c = {
					"%=",
				},
				lualine_x = {},
				lualine_y = { "filetype", "progress" },
				lualine_z = {
					{ "location", separator = { right = "" }, left_padding = 2 },
				},
			},
			inactive_sections = {
				lualine_a = { "filename" },
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = { "location" },
			},
			tabline = {},
			extensions = {},
		})
	end,
}

-- return {
-- 	"nvim-lualine/lualine.nvim",
-- 	dependencies = { "nvim-tree/nvim-web-devicons" },
-- 	config = function()
-- 		local devicons = require("nvim-web-devicons")
--
-- 		local function folder_and_file()
-- 			local filepath = vim.fn.expand("%:p")
-- 			if filepath == "" then
-- 				return ""
-- 			end
-- 			local relpath = vim.fn.fnamemodify(filepath, ":~:.")
-- 			local folder_icon = ""
-- 			local folder = vim.fn.fnamemodify(relpath, ":h")
-- 			local fname = vim.fn.fnamemodify(relpath, ":t")
-- 			if folder and folder ~= "." and folder ~= "" then
-- 				return string.format("%s %s/%s", folder_icon, folder, fname)
-- 			else
-- 				return string.format("%s %s", folder_icon, fname)
-- 			end
-- 		end
--
-- 		local function github_repo()
-- 			local remote = vim.fn.systemlist("git remote get-url origin")[1] or ""
-- 			local icon = ""
-- 			local repo = remote:match("github.com[:/](.+).git") or ""
-- 			if repo ~= "" then
-- 				return string.format("%s %s", icon, repo)
-- 			end
-- 			return ""
-- 		end
--
-- 		local function lsp_name()
-- 			local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
-- 			if #buf_clients == 0 then
-- 				return ""
-- 			end
-- 			for _, client in ipairs(buf_clients) do
-- 				if client.name ~= "null-ls" then
-- 					return client.name
-- 				end
-- 			end
-- 			return ""
-- 		end
--
-- 		local function progress_block()
-- 			local current = vim.fn.line(".")
-- 			local total = vim.fn.line("$")
-- 			local percent = (total ~= 0) and math.floor((current / total) * 100) or 0
-- 			local crosshairs_icon = ""
-- 			local bar_icon = "≡"
-- 			local location = ("%d:%d"):format(current, vim.fn.col("."))
-- 			return string.format("  %s %s  %s  %s  ", crosshairs_icon, location, bar_icon, percent .. "%%")
-- 		end
--
-- 		require("latif.plugins.lualine1").setup({
-- 			options = {
-- 				theme = "nordic",
-- 				icons_enabled = true,
-- 				component_separators = "",
-- 				section_separators = { left = "", right = "" },
-- 				always_divide_middle = false,
-- 				globalstatus = true,
-- 			},
-- 			sections = {
-- 				lualine_a = {
-- 					{
-- 						"mode",
-- 						fmt = function(str)
-- 							return " " .. str
-- 						end,
-- 						separator = { left = "" },
-- 						right_padding = 2,
-- 					},
-- 				},
-- 				lualine_b = {
-- 					{
-- 						folder_and_file,
-- 						color = { bg = "#040405" },
-- 					},
-- 					{
-- 						github_repo,
-- 						color = { bg = "#040405" },
-- 					},
-- 					{
-- 						"diff",
-- 						symbols = { added = " ", modified = " ", removed = " " },
-- 						colored = true,
-- 						diff_color = {
-- 							added = { fg = "#C0C8D8" },
-- 							modified = { fg = "#C0C8D8" },
-- 							removed = { fg = "#C0C8D8" },
-- 						},
-- 						color = { bg = "#040405" },
-- 					},
-- 				},
-- 				lualine_c = {},
-- 				lualine_x = {
-- 					{
-- 						"diagnostics",
-- 						sources = { "nvim_diagnostic" },
-- 						sections = { "error", "warn" },
-- 						symbols = { error = " ", warn = " " },
-- 						colored = true,
-- 						update_in_insert = false,
-- 						always_visible = true,
-- 						diagnostics_color = {
-- 							error = { fg = "#ef4444", bg = "#040405" },
-- 							warn = { fg = "#eed202", bg = "#040405" },
-- 						},
-- 					},
-- 					{
-- 						lsp_name,
-- 						color = { fg = "#ffffff", bg = "#040405" },
-- 						padding = { left = 1, right = 1 },
-- 					},
-- 				},
-- 				lualine_y = {},
-- 				lualine_z = {
-- 					{
-- 						progress_block,
-- 						separator = { left = "", right = "" },
-- 						color = { fg = "#232731", bg = "#e0a080", gui = "bold" },
-- 					},
-- 				},
-- 			},
-- 			inactive_sections = {
-- 				lualine_a = {},
-- 				lualine_b = {},
-- 				lualine_c = {},
-- 				lualine_x = {},
-- 				lualine_y = {},
-- 				lualine_z = {},
-- 			},
-- 			tabline = {},
-- 			extensions = {},
-- 		})
--
-- 		local modes = { "normal", "insert", "visual", "replace", "command", "terminal" }
-- 		for _, mode in ipairs(modes) do
-- 			vim.api.nvim_set_hl(0, "LualineDiagnosticsError_" .. mode, { fg = "#ff3333", bg = "#040405" })
-- 			vim.api.nvim_set_hl(0, "LualineDiagnosticsWarn_" .. mode, { fg = "#eed202", bg = "#040405" })
-- 		end
--
-- 		vim.api.nvim_create_autocmd("ColorScheme", {
-- 			pattern = "*",
-- 			callback = function()
-- 				for _, mode in ipairs(modes) do
-- 					vim.api.nvim_set_hl(0, "LualineDiagnosticsError_" .. mode, { fg = "#ff3333", bg = "#040405" })
-- 					vim.api.nvim_set_hl(0, "LualineDiagnosticsWarn_" .. mode, { fg = "#eed202", bg = "#040405" })
-- 				end
-- 			end,
-- 		})
-- 	end,
-- }
