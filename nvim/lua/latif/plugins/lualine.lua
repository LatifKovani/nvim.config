-- lua/latif/plugins/lualine.lua
-- Single-file, self-contained lualine config inspired by Alex's layout/photo.
-- Place this file at lua/latif/plugins/lualine.lua and load it from your lazy.nvim spec.
--
-- Behaviour:
-- - Recreates bubble-like separators and icons.
-- - Components: mode (fixed width), filename/branch/diff, diagnostics, LSP clients for current buffer,
--   recording indicator, virtual-diagnostics/format/zen indicators, progress/location.
-- - Safe fallbacks: uses builtin APIs (vim.diagnostic, vim.lsp) and checks for gitsigns/web-devicons.
-- - Exposes M.setup() and M.refresh_statusline() for plugin loader use and toggles.
--
-- Notes:
-- - Uses Nerd Font glyphs. Replace icons if your font lacks them.
-- - Minimal, local colour table is embedded; change hex values if desired.

local M = {}

local function safe_require(name)
	local ok, mod = pcall(require, name)
	if ok then
		return mod
	end
	return nil
end

-- Helpers (no external alex.* deps required)
local function is_recording()
	local ok, rec = pcall(vim.fn.reg_recording)
	if not ok then
		return false
	end
	return rec ~= ""
end

local diagnostic_signs = {
	error = "",
	warn = "",
	info = "",
	hint = "",
	other = "",
}

local function current_buffer_lsp()
	local clients = vim.lsp.get_active_clients({ bufnr = 0 })
	if not clients or vim.tbl_isempty(clients) then
		return ""
	end
	local names = {}
	for _, c in ipairs(clients) do
		table.insert(names, c.name)
	end
	return table.concat(names, ", ")
end

local function short_cwd()
	return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
end

local function diff_source()
	local gitsigns = vim.b.gitsigns_status_dict
	if gitsigns then
		return { added = gitsigns.added, modified = gitsigns.changed, removed = gitsigns.removed }
	end
end

-- Embedded palette (change to match your theme)
local C = {
	blue = "#539bf5",
	cyan = "#76E3EA",
	black = "#22272e",
	white = "#adbac7",
	red = "#A05350",
	violet = "#DCBDFB",
	grey = "#303030",
	green = "#8DDB8C",
}

local bubbles_theme = {
	normal = {
		a = { fg = C.black, bg = C.blue },
		b = { fg = C.white, bg = C.grey },
		c = { fg = C.white, bg = C.black },
	},
	insert = { a = { fg = C.black, bg = C.green } },
	visual = { a = { fg = C.black, bg = C.cyan } },
	replace = { a = { fg = C.black, bg = C.red } },
	command = { a = { fg = C.black, bg = C.violet } },
	inactive = {
		a = { fg = C.white, bg = C.black },
		b = { fg = C.white, bg = C.black },
		c = { fg = C.white, bg = C.black },
	},
}

-- Mode formatting (fixed-length)
local function fmt_mode(s)
	local map = {
		["COMMAND"] = "COMMND",
		["V-BLOCK"] = "V-BLCK",
		["TERMINAL"] = "TERMNL",
		["V-REPLACE"] = "V-RPLC",
		["O-PENDING"] = "0PNDNG",
	}
	return map[s] or s
end

-- Recording icon component
local function recording_component()
	if is_recording() then
		return ""
	end
	return ""
end

-- Small state flags (we keep them local toggles; you can expose setters if needed)
local state = { virtual_diagnostics = false, format_enabled = false, zen = false }

function M.set_virtual_diagnostics(val)
	state.virtual_diagnostics = not not val
end
function M.set_format_enabled(val)
	state.format_enabled = not not val
end
function M.set_zen(val)
	state.zen = not not val
end

-- Setup function (safe)
function M.setup()
	local ok, lualine = pcall(require, "lualine")
	if not ok or not lualine then
		-- lualine not installed; skip setup silently
		return
	end

	-- Keep StatusLine background matching Normal when colors change (like Alex did)
	vim.api.nvim_create_autocmd({ "UIEnter", "ColorScheme" }, {
		callback = function()
			local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
			local statusline = vim.api.nvim_get_hl(0, { name = "StatusLine" })
			local updated = vim.tbl_extend("force", statusline or {}, { bg = normal and normal.bg })
			pcall(vim.api.nvim_set_hl, 0, "StatusLine", updated)
		end,
	})

	local default_x = {
		{
			"diagnostics",
			sources = { "nvim_diagnostic" },
			symbols = {
				error = diagnostic_signs.error,
				warn = diagnostic_signs.warn,
				info = diagnostic_signs.info,
				hint = diagnostic_signs.hint,
				other = diagnostic_signs.other,
			},
			colored = true,
			padding = 2,
		},
		{
			current_buffer_lsp,
			padding = 1,
			icon = { " ", color = { fg = C.grey } },
			color = { fg = C.white },
		},
		{
			function()
				return ""
			end,
			color = function()
				return state.virtual_diagnostics and { fg = C.green } or { fg = C.grey }
			end,
			separator = { " ", "" },
		},
		{
			function()
				return " "
			end,
			color = function()
				return state.zen and { fg = C.green } or { fg = C.grey }
			end,
			padding = 0,
		},
		{
			function()
				return "󰉼  "
			end,
			color = function()
				return state.format_enabled and { fg = C.green } or { fg = C.grey }
			end,
			padding = 0,
		},
	}

	local default_z = {
		{
			"location",
			icon = { "", align = "left" },
			fmt = function(str)
				local fixed_width = 7
				return string.format("%" .. fixed_width .. "s", str)
			end,
		},
		{
			"progress",
			icon = { "", align = "left" },
			separator = { right = "", left = "" },
		},
	}

	local oil_ext = {
		sections = {
			lualine_a = {
				{
					"mode",
					fmt = fmt_mode,
					icon = { "" },
					separator = { right = " ", left = "" },
				},
			},
			lualine_b = {},
			lualine_c = {
				{
					short_cwd,
					padding = 0,
					icon = { "   ", color = { fg = C.grey } },
					color = { fg = C.white },
				},
			},
			lualine_x = default_x,
			lualine_y = {},
			lualine_z = default_z,
		},
		filetypes = { "oil" },
	}

	local telescope_ext = {
		sections = {
			lualine_a = {
				{
					"mode",
					fmt = fmt_mode,
					icon = { "" },
					separator = { right = " ", left = "" },
				},
			},
			lualine_b = {},
			lualine_c = {
				{
					function()
						return "Telescope"
					end,
					color = { fg = C.white },
					icon = { "  ", color = { fg = C.grey } },
				},
			},
			lualine_x = default_x,
			lualine_y = {},
			lualine_z = default_z,
		},
		filetypes = { "TelescopePrompt" },
	}

	-- Main setup (wrapped safely)
	pcall(function()
		lualine.setup({
			options = {
				theme = bubbles_theme,
				disabled_filetypes = { "dashboard" },
				globalstatus = true,
				section_separators = { left = " ", right = " " },
				component_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = {
					{ "mode", fmt = fmt_mode, icon = { "" }, separator = { right = " ", left = "" } },
				},
				lualine_b = {},
				lualine_c = {
					{
						"branch",
						color = { fg = C.white },
						icon = { " ", color = { fg = C.grey } },
						padding = 2,
					},
					{
						"diff",
						color = { fg = C.white },
						source = diff_source,
						symbols = { added = " ", modified = " ", removed = " " },
						diff_color = { added = { fg = C.grey }, modified = { fg = C.grey }, removed = { fg = C.grey } },
						padding = 1,
					},
					{
						recording_component,
						color = function()
							if is_recording() then
								return { fg = C.red }
							end
							return { fg = C.white }
						end,
						padding = 1,
					},
				},
				lualine_x = default_x,
				lualine_y = {},
				lualine_z = default_z,
			},
			extensions = { telescope_ext, oil_ext },
		})
	end)
end

function M.refresh_statusline()
	local ok, lualine = pcall(require, "lualine")
	if ok and lualine and type(lualine.refresh) == "function" then
		pcall(lualine.refresh, { statusline = true })
	end
end

return M
