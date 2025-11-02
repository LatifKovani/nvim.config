-- lua/latif/plugins/lualine.lua
-- Single-file, self-contained lualine config.
-- Updated: switched embedded color palette and theme to a "Nordic" look per request.
-- Only the color variables and bubbles_theme values were changed to use a Nordic-inspired palette.
-- All other behavior and components are preserved exactly.

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
	error = " ",
	warn = " ",
	info = " ",
	hint = " ",
	other = " ",
}

local function current_buffer_lsp()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
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

-- Nordic-inspired palette (replaces previous palette)
-- These colors are typical of Nordic schemes: dark bluish background, soft greys, icy blue/cyan accents.
local C = {
	bg = "#040405", -- nordic background (dark slate)
	surface0 = "#040405",
	surface1 = "#BBC3D4",
	surface2 = "#040405",
	text = "#60728A", -- light foreground
	comment = "#616E88",
	blue = "#81A1C1",
	cyan = "#88C0D0",
	green = "#A3BE8C",
	red = "#BF616A",
	violet = "#B48EAD",
	orange = "#D79784",
}

-- Nordic bubbles_theme using the Nordic palette above.
-- Edit these bg values if you want subtle variations.
local nordic = {
	normal = {
		a = { fg = C.bg, bg = C.orange }, -- mode block: icy blue
		b = { fg = C.text, bg = C.surface1 }, -- middle blocks
		c = { fg = C.text, bg = C.bg }, -- rest of statusline
	},
	insert = { a = { fg = C.bg, bg = C.green } },
	visual = { a = { fg = C.bg, bg = C.cyan } },
	replace = { a = { fg = C.bg, bg = C.red } },
	command = { a = { fg = C.bg, bg = C.violet } },
	inactive = {
		a = { fg = C.text, bg = C.surface2 },
		b = { fg = C.text, bg = C.surface2 },
		c = { fg = C.text, bg = C.surface2 },
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

-- === Requested additions (GitHub prefix and file-location) ===
-- Replacement for the requested additions block (GitHub prefix and file-location).
-- Replaces the original github branch component with repo-detection + fallbacks.
-- Set GITHUB_USERNAME above to control the username fallback; GITHUB_ICON is used if username is empty.

local GITHUB_USERNAME = "LatifKovani" -- change if needed
local GITHUB_ICON = "" -- fallback GitHub icon (Nerd Font)

-- Helper: detect whether cwd is inside a git worktree
local function in_git_repo()
	local ok, out = pcall(vim.fn.systemlist, { "git", "rev-parse", "--is-inside-work-tree" })
	if not ok or type(out) ~= "table" or #out == 0 then
		return false
	end
	return out[1] == "true"
end

local function github_branch_component()
	-- If we're not inside a git repository, show only the username (or the GitHub icon if no username)
	if not in_git_repo() then
		if GITHUB_USERNAME and GITHUB_USERNAME ~= "" then
			return GITHUB_USERNAME
		end
		return GITHUB_ICON
	end

	-- Try gitsigns-provided branch first
	local branch = vim.b.gitsigns_head
	-- Fallback to git cli if gitsigns not available
	if not branch or branch == "" then
		local ok, out = pcall(vim.fn.systemlist, { "git", "rev-parse", "--abbrev-ref", "HEAD" })
		if ok and type(out) == "table" and #out > 0 and out[1] ~= "HEAD" then
			branch = out[1]
		end
	end

	if not branch or branch == "" then
		-- if there is a repo but no branch (detached HEAD), show username or icon as fallback
		if GITHUB_USERNAME and GITHUB_USERNAME ~= "" then
			return GITHUB_USERNAME
		end
		return GITHUB_ICON
	end

	if GITHUB_USERNAME and GITHUB_USERNAME ~= "" then
		return GITHUB_USERNAME .. "/" .. branch
	end
	return branch
end

local function file_location_component()
	if vim.fn.expand("%") == "" then
		return ""
	end
	local icon = " "
	local path = vim.fn.expand("%:~:.")
	return icon .. path
end
-- === end requested additions ===

-- Setup function (safe)
function M.setup()
	local ok, lualine = pcall(require, "lualine")
	if not ok or not lualine then
		return
	end

	-- Keep StatusLine background matching Normal when colors change
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
			icon = { " ", color = { fg = C.surface1 } },
			color = { fg = C.text },
		},
		{
			function()
				return ""
			end,
			color = function()
				return state.virtual_diagnostics and { fg = C.green } or { fg = C.surface1 }
			end,
			separator = { " ", "" },
		},
		{
			function()
				return " "
			end,
			color = function()
				return state.zen and { fg = C.green } or { fg = C.surface1 }
			end,
			padding = 0,
		},
		{
			function()
				return "󰉼  "
			end,
			color = function()
				return state.format_enabled and { fg = C.green } or { fg = C.surface1 }
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
					icon = { "   ", color = { fg = C.surface1 } },
					color = { fg = C.text },
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
					color = { fg = C.text },
					icon = { "  ", color = { fg = C.surface1 } },
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
				theme = nordic,
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
				-- Center: file path first, then branch, diff, recording
				lualine_c = {
					{
						file_location_component,
						color = { fg = C.text },
						padding = 1,
					},
					{
						github_branch_component,
						color = { fg = "#60728A" },
						icon = { " ", color = { fg = "#BBC3D4" } },
						padding = 2,
					},
					{
						"diff",
						color = { fg = C.text },
						source = diff_source,
						symbols = { added = " ", modified = " ", removed = " " },
						diff_color = {
							added = { fg = C.surface1 },
							modified = { fg = C.surface1 },
							removed = { fg = C.surface1 },
						},
						padding = 1,
					},
					{
						recording_component,
						color = function()
							if is_recording() then
								return { fg = C.red }
							end
							return { fg = C.text }
						end,
						padding = 1,
					},
				},
				-- Right side: diagnostics/LSP/icons etc.
				lualine_x = {
					unpack(default_x),
				},
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
