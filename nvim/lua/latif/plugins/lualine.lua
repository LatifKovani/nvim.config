return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local devicons = require("nvim-web-devicons")

		local function folder_and_file()
			local filepath = vim.fn.expand("%:p")
			if filepath == "" then
				return ""
			end
			local relpath = vim.fn.fnamemodify(filepath, ":~:.")
			local folder_icon = ""
			local folder = vim.fn.fnamemodify(relpath, ":h")
			local fname = vim.fn.fnamemodify(relpath, ":t")
			if folder and folder ~= "." and folder ~= "" then
				return string.format("%s %s/%s", folder_icon, folder, fname)
			else
				return string.format("%s %s", folder_icon, fname)
			end
		end

		local function github_repo()
			local remote = vim.fn.systemlist("git remote get-url origin")[1] or ""
			local icon = ""
			local repo = remote:match("github.com[:/](.+).git") or ""
			if repo ~= "" then
				return string.format("%s %s", icon, repo)
			end
			return ""
		end

		local function lsp_name()
			local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
			if #buf_clients == 0 then
				return ""
			end
			for _, client in ipairs(buf_clients) do
				if client.name ~= "null-ls" then
					return client.name
				end
			end
			return ""
		end

		local function progress_block()
			local current = vim.fn.line(".")
			local total = vim.fn.line("$")
			local percent = (total ~= 0) and math.floor((current / total) * 100) or 0
			local crosshairs_icon = ""
			local bar_icon = "≡"
			local location = ("%d:%d"):format(current, vim.fn.col("."))
			return string.format("  %s %s  %s  %s  ", crosshairs_icon, location, bar_icon, percent .. "%%")
		end

		require("lualine").setup({
			options = {
				theme = "nordic",
				icons_enabled = true,
				component_separators = "",
				section_separators = { left = "", right = "" },
				always_divide_middle = false,
				globalstatus = true,
			},
			sections = {
				lualine_a = {
					{
						"mode",
						fmt = function(str)
							return " " .. str
						end,
						separator = { left = "" },
						right_padding = 2,
					},
				},
				lualine_b = {
					folder_and_file,
					github_repo,
					{
						"diff",
						symbols = { added = " ", modified = " ", removed = " " },
						colored = true,
						diff_color = {
							added = { fg = "#7a7c86" },
							modified = { fg = "#7a7c86" },
							removed = { fg = "#7a7c86" },
						},
					},
				},
				lualine_c = {},
				lualine_x = {
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						sections = { "error", "warn" },
						symbols = { error = " ", warn = " " },
						colored = true,
						update_in_insert = false,
						always_visible = true,
						diagnostics_color = {
							error = { fg = "#ef4444", bg = "#191D24" }, -- bright red
							warn = { fg = "#eed202", bg = "#191D24" }, -- yellow
						},
					},
					lsp_name,
				},
				lualine_y = {},
				lualine_z = {
					{
						progress_block,
						separator = { left = "", right = "" },
						color = { fg = "#232731", bg = "#e0a080", gui = "bold" },
						padding = 0,
					},
				},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { folder_and_file },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			extensions = {},
		})

		local modes = { "normal", "insert", "visual", "replace", "command", "terminal" }
		for _, mode in ipairs(modes) do
			vim.api.nvim_set_hl(0, "LualineDiagnosticsError_" .. mode, { fg = "#ff3333", bg = "#191D24" })
			vim.api.nvim_set_hl(0, "LualineDiagnosticsWarn_" .. mode, { fg = "#eed202", bg = "#191D24" })
		end

		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "*",
			callback = function()
				for _, mode in ipairs(modes) do
					vim.api.nvim_set_hl(0, "LualineDiagnosticsError_" .. mode, { fg = "#ff3333", bg = "#191D24" })
					vim.api.nvim_set_hl(0, "LualineDiagnosticsWarn_" .. mode, { fg = "#eed202", bg = "#191D24" })
				end
			end,
		})
	end,
}

-- return {
--   "nvim-lualine/lualine.nvim",
--   dependencies = { "nvim-tree/nvim-web-devicons" },
--   config = function()
--     local lualine = require("lualine")
--     local lazy_status = require("lazy.status") -- to configure lazy pending updates count
--
--     local colors = {
--       blue = "#65D1FF",
--       green = "#3EFFDC",
--       violet = "#FF61EF",
--       yellow = "#FFDA7B",
--       red = "#FF4A4A",
--       fg = "#c3ccdc",
--       bg = "#112638",
--       inactive_bg = "#2c3043",
--     }
--
--     local my_lualine_theme = {
--       normal = {
--         a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
--         b = { bg = colors.bg, fg = colors.fg },
--         c = { bg = colors.bg, fg = colors.fg },
--       },
--       insert = {
--         a = { bg = colors.green, fg = colors.bg, gui = "bold" },
--         b = { bg = colors.bg, fg = colors.fg },
--         c = { bg = colors.bg, fg = colors.fg },
--       },
--       visual = {
--         a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
--         b = { bg = colors.bg, fg = colors.fg },
--         c = { bg = colors.bg, fg = colors.fg },
--       },
--       command = {
--         a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
--         b = { bg = colors.bg, fg = colors.fg },
--         c = { bg = colors.bg, fg = colors.fg },
--       },
--       replace = {
--         a = { bg = colors.red, fg = colors.bg, gui = "bold" },
--         b = { bg = colors.bg, fg = colors.fg },
--         c = { bg = colors.bg, fg = colors.fg },
--       },
--       inactive = {
--         a = { bg = colors.inactive_bg, fg = colors.semilightgray, gui = "bold" },
--         b = { bg = colors.inactive_bg, fg = colors.semilightgray },
--         c = { bg = colors.inactive_bg, fg = colors.semilightgray },
--       },
--     }
--
--     -- configure lualine with modified theme
--     lualine.setup({
--       options = {
--         theme = my_lualine_theme,
--       },
--       sections = {
--         lualine_x = {
--           {
--             lazy_status.updates,
--             cond = lazy_status.has_updates,
--             color = { fg = "#ff9e64" },
--           },
--           { "encoding" },
--           { "fileformat" },
--           { "filetype" },
--         },
--       },
--     })
--   end,
-- }
