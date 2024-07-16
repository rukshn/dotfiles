--------------------------------------------------------------------------------
---@diagnostic enable: unused-local
--------------------------------------------------------------------------------
-- UTILS

local wt = require("wezterm")
local tabs = require("tabs")
local act = wt.action
local actFun = wt.action_callback

local host = wt.hostname()
local isAtOffice = (host:find("mini") or host:find("eduroam") or host:find("fak1")) ~= nil

local fontSize = 12
if isAtOffice then
	fontSize = 12
end

--------------------------------------------------------------------------------
-- SET WINDOW POSITION ON STARTUP

-- on start, move window to the side ("pseudomaximized")
wt.on("gui-startup", function(cmd)
	local pos = { x = 500, y = 100, w = 800 }
	if isAtOffice then
		pos = { x = 500, y = -100, w = 1000 }
	end
	local height = 500 -- automatically truncated to maximum
	local _, _, window = wt.mux.spawn_window(cmd or {})
	window:gui_window():set_position(pos.x, pos.y)
	window:gui_window():set_inner_size(pos.w, height)
end)

--------------------------------------------------------------------------------
-- KEYBINDINGS
local keybindings = {
	-- Actions: https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html#available-key-assignments
	-- Key-Names: https://wezfurlong.org/wezterm/config/keys.html#configuring-key-assignments
	{ key = "t", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "q", mods = "CTRL", action = act.QuitApplication },
	{ key = "c", mods = "CTRL", action = act.CopyTo("ClipboardAndPrimarySelection") },
	{ key = "w", mods = "CTRL", action = act.CloseCurrentTab({ confirm = false }) },
	{ key = "+", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },
	{ key = "p", mods = "CTRL", action = act.ActivateCommandPalette },
	{ key = "k", mods = "SHIFT", action = act.ClearScrollback("ScrollbackAndViewport") },
	{ key = "Enter", mods = "CTRL", action = act.ActivateTabRelative(1) },
	{ key = "v", mods = "CTRL", action = act.PasteFrom("Clipboard") },
	{ key = "PageDown", mods = "", action = act.ScrollByPage(0.8) },
	{ key = "PageUp", mods = "", action = act.ScrollByPage(-0.8) },
	{ key = "N", mods = "CTRL|SHIFT", action = wt.action.ToggleFullScreen },
	{ key = "1", mods = "ALT", action = wt.action({ ActivateTab = 0 }) },
	{ key = "2", mods = "ALT", action = wt.action({ ActivateTab = 1 }) },
	{ key = "3", mods = "ALT", action = wt.action({ ActivateTab = 2 }) },
	{ key = "4", mods = "ALT", action = wt.action({ ActivateTab = 3 }) },
	{ key = "5", mods = "ALT", action = wt.action({ ActivateTab = 4 }) },
	{ key = "6", mods = "ALT", action = wt.action({ ActivateTab = 5 }) },
	{ key = "7", mods = "ALT", action = wt.action({ ActivateTab = 6 }) },
	{ key = "8", mods = "ALT", action = wt.action({ ActivateTab = 7 }) },
	{ key = "9", mods = "ALT", action = wt.action({ ActivateTab = 8 }) },
	-- INFO using the mapping from the terminal_keybindings.zsh
	-- undo
	{ key = "z", mods = "CTRL", action = act.SendKey({ key = "z", mods = "CTRL" }) },
	-- Grappling-hook
	{ key = "Enter", mods = "CTRL", action = act.SendKey({ key = "o", mods = "CTRL" }) },
	-- accept zsh-autosuggestion
	{ key = "s", mods = "CTRL", action = act.SendKey({ key = "RightArrow" }) },

	-- scroll-to-prompt, requires shell integration: https://wezfurlong.org/wezterm/config/lua/keyassignment/ScrollToPrompt.html
	{ key = "k", mods = "CTRL", action = act.ScrollToPrompt(-1) },
	{ key = "j", mods = "CTRL", action = act.ScrollToPrompt(1) },

	-- FIX works with `send_composed_key_when_right_alt_is_pressed = true`
	-- but expects another character, so this mapping fixes it
	{ key = "n", mods = "META", action = act.SendString("~") },

	-- Emulates macOS' cmd-right & cmd-left
	{ key = "LeftArrow", mods = "CMD", action = act.SendKey({ key = "A", mods = "CTRL" }) },
	{ key = "RightArrow", mods = "CMD", action = act.SendKey({ key = "E", mods = "CTRL" }) },

	{ -- for adding inline code to a commit, hotkey consistent with GitHub's
		key = "e",
		mods = "CTRL",
		action = act.Multiple({
			act.SendString("``"),
			act.SendKey({ key = "LeftArrow" }),
			act.SendKey({ key = "LeftArrow" }), -- 2nd to move into auto-added backslash
		}),
	},

	{ -- cmd+l -> open current location in Finder
		key = "l",
		mods = "CTRL",
		action = actFun(function(_, pane)
			local cwd = pane:get_current_working_dir()
			wt.open_with(cwd, "Finder")
		end),
	},
	-----------------------------------------------------------------------------

	-- MODES
	-- Search
	{ key = "f", mods = "CTRL", action = act.Search("CurrentSelectionOrEmptyString") },

	-- Console / REPL
	{ key = "Escape", mods = "CTRL", action = wt.action.ShowDebugOverlay },

	-- Copy Mode (~= Caret Mode) -- https://wezfurlong.org/wezterm/copymode.html
	{ key = "c", mods = "CMD|ALT", action = act.ActivateCopyMode },

	-- Quick Select (~= Hint Mode) -- https://wezfurlong.org/wezterm/quickselect.html
	{ key = "c", mods = "CMD|SHIFT", action = act.QuickSelect },

	-- Quick Select Presets
	{ -- cmd+u -> open URL (like f in vimium)
		key = "u",
		mods = "CMD",
		action = act.QuickSelectArgs({
			patterns = { [[https?://[^\]",' ]+\w]] },
			label = "Open URL",
			action = actFun(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				wt.open_with(url)
			end),
		}),
	},
	{ -- cmd+y -> copy full line, useful for pages like `fx`
		key = "y",
		mods = "CTRL",
		action = act.QuickSelectArgs({ patterns = { "^.*$" }, label = "Copy Full Line" }),
	},
	{ -- cmd+o -> copy shell option, e.g. to copy them from a man page
		key = "o",
		mods = "CTRL",
		action = act.QuickSelectArgs({
			patterns = { "--[\\w=-]+", "-\\w" }, -- long option, short option
			label = "Copy Shell Option",
		}),
	},
	-- cmd+, -> open this config file
	{
		key = ",",
		mods = "CTRL",
		action = actFun(function()
			wt.open_with(wt.config_file)
		end),
	},
}

--------------------------------------------------------------------------------
-- TAB TITLE

-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html

local icon_colors = {
	rosewater = "#F5E0DC",
	flamingo = "#F2CDCD",
	pink = "#F5C2E7",
	mauve = "#CBA6F7",
	red = "#F38BA8",
	maroon = "#EBA0AC",
	peach = "#DFA44B",
	yellow = "#F9E2AF",
	green = "#669149",
	teal = "#94E2D5",
	sky = "#89DCEB",
	sapphire = "#74C7EC",
	blue = "#89B4FA",
	lavender = "#B4BEFE",

	text = "#CDD6F4",
	subtext1 = "#BAC2DE",
	subtext0 = "#A6ADC8",
	overlay2 = "#9399B2",
	overlay1 = "#7F849C",
	overlay0 = "#6C7086",
	surface2 = "#585B70",
	surface1 = "#45475A",
	surface0 = "#313244",

	base = "#1E1E2E",
	mantle = "#181825",
	crust = "#11111B",
}

local function get_process(tab)
	local process_icons = {
		["docker"] = {
			{ Foreground = { Color = icon_colors.blue } },
			{ Text = wt.nerdfonts.linux_docker },
		},
		["docker-compose"] = {
			{ Foreground = { Color = icon_colors.blue } },
			{ Text = wt.nerdfonts.linux_docker },
		},
		["nvim"] = {
			{ Foreground = { Color = icon_colors.maroon } },
			{ Text = wt.nerdfonts.custom_vim },
		},
		["vim"] = {
			{ Foreground = { Color = icon_colors.green } },
			{ Text = wt.nerdfonts.dev_vim },
		},
		["node"] = {
			{ Foreground = { Color = icon_colors.green } },
			{ Text = wt.nerdfonts.mdi_hexagon },
		},
		["zsh"] = {
			{ Foreground = { Color = icon_colors.peach } },
			{ Text = wt.nerdfonts.dev_terminal },
		},
		["bash"] = {
			{ Foreground = { Color = icon_colors.subtext0 } },
			{ Text = wt.nerdfonts.cod_terminal_bash },
		},
		["paru"] = {
			{ Foreground = { Color = icon_colors.lavender } },
			{ Text = wt.nerdfonts.linux_archlinux },
		},
		["htop"] = {
			{ Foreground = { Color = icon_colors.yellow } },
			{ Text = wt.nerdfonts.mdi_chart_donut_variant },
		},
		["cargo"] = {
			{ Foreground = { Color = icon_colors.peach } },
			{ Text = wt.nerdfonts.dev_rust },
		},
		["go"] = {
			{ Foreground = { Color = icon_colors.sapphire } },
			{ Text = wt.nerdfonts.mdi_language_go },
		},
		["lazydocker"] = {
			{ Foreground = { Color = icon_colors.blue } },
			{ Text = wt.nerdfonts.linux_docker },
		},
		["git"] = {
			{ Foreground = { Color = icon_colors.peach } },
			{ Text = wt.nerdfonts.dev_git },
		},
		["lazygit"] = {
			{ Foreground = { Color = icon_colors.peach } },
			{ Text = wt.nerdfonts.dev_git },
		},
		["lua"] = {
			{ Foreground = { Color = icon_colors.blue } },
			{ Text = wt.nerdfonts.seti_lua },
		},
		["wget"] = {
			{ Foreground = { Color = icon_colors.yellow } },
			{ Text = wt.nerdfonts.mdi_arrow_down_box },
		},
		["curl"] = {
			{ Foreground = { Color = icon_colors.yellow } },
			{ Text = wt.nerdfonts.mdi_flattr },
		},
		["gh"] = {
			{ Foreground = { Color = icon_colors.mauve } },
			{ Text = wt.nerdfonts.dev_github_badge },
		},
	}

	local process_name = string.gsub(tab.active_pane.foreground_process_name, "(.*[/\\])(.*)", "%2")

	return wt.format(
		process_icons[process_name]
			or { { Foreground = { Color = icon_colors.sky } }, { Text = string.format("[%s]", process_name) } }
	)
end

local function get_current_working_dir()
	-- local current_dir = tab.active_pane.current_working_dir
	local HOME_DIR = string.format("file://%s", os.getenv("HOME"))

	return current_dir == HOME_DIR
end
-- WINDOW TITLE
-- set to pwd basename
-- https://wezfurlong.org/wezterm/config/lua/window-events/format-window-title
wt.on("format-window-title", function(tab, pane, tabs, panes, config)
	--- local pwd = get_current_working_dir()
	--- local pwd = pane.current_working_dir:gsub("^file://[^/]+", ""):gsub("%%20", " ")
	return "Rukshan"
end)

--------------------------------------------------------------------------------
-- HYPERLINK RULES
local myHyperlinkRules = wt.default_hyperlink_rules()

-- make github links of the form `owner/repo` clickable
table.insert(myHyperlinkRules, {
	regex = [["?(\b[-\w]+)/([-\w.]+)"?]],
	highlight = 0,
	format = "https://github.com/$1/$2",
})

-- links that are probably file paths
table.insert(myHyperlinkRules, {
	regex = [[/\b\S*\b]],
	highlight = 0,
	format = "file://$0",
})

--------------------------------------------------------------------------------
-- SETTINGS

local config = {
	-- Meta
	check_for_updates = true, -- done via homebrew already
	automatically_reload_config = true,
	-- Passwords
	-- INFO `sudo visudo`, and change line `Defaults env_reset` to `Defaults env_reset,pwfeedback`
	-- to see asterisks in general
	detect_password_input = false,

	-- Start/Close
	default_cwd = wt.home_dir,
	quit_when_all_windows_are_closed = true,
	window_close_confirmation = "NeverPrompt",

	-- Mouse & Cursor
	hide_mouse_cursor_when_typing = true,
	default_cursor_style = "SteadyBlock", -- mostly overwritten by vi-mode.zsh
	cursor_thickness = "0.07cell",
	cursor_blink_rate = 700,
	cursor_blink_ease_in = "Constant", -- Constant = no fading
	cursor_blink_ease_out = "Constant",
	force_reverse_video_cursor = true, -- true = color is reverse, false = color by color scheme

	-- font
	-- INFO some nerd font requires a space after them to be properly sized
	font = wt.font("FiraMono Nerd Font"),
	font_size = fontSize,
	line_height = 1.2,
	command_palette_font_size = 12,
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" }, -- disable ligatures
	adjust_window_size_when_changing_font_size = false,

	-- Appearance
	audible_bell = "Disabled", -- SystemBeep|Disabled
	visual_bell = { -- briefly flash cursor on visual bell
		fade_in_duration_ms = 150,
		fade_out_duration_ms = 150,
		target = "CursorColor",
	},
	bold_brightens_ansi_colors = "BrightAndBold",
	max_fps = 40 or 60,

	-- remove titlebar, but keep macOS traffic lights, enabling menu bar stuff,
	-- especially the "Window" Menu containing window split commands
	-- (used by Hammerspoon)
	window_decorations = "INTEGRATED_BUTTONS|RESIZE",
	native_macos_fullscreen_mode = false,

	-- Scroll & Scrollbar
	enable_scroll_bar = true,
	window_padding = {
		left = "0.5cell",
		right = "1.1cell", -- if scrollbar enabled, "rights" controls scrollbar width
		top = "0.3cell", -- extra height to account for macOS traffic lights
		bottom = "0.3cell",
	},
	min_scroll_bar_height = "3cell",
	scrollback_lines = 5000,

	-- Hyperlinks
	hyperlink_rules = myHyperlinkRules,

	-- Tabs

	-- Mouse Bindings
	disable_default_mouse_bindings = false,
	mouse_bindings = {
		{ -- open link at normal leftclick & auto-copy selection if not a link
			event = { Up = { streak = 1, button = "Left" } },
			mods = "",
			action = act.CompleteSelectionOrOpenLinkAtMouseCursor("Clipboard"),
		},
	},

	-- Keybindings
	keys = keybindings,
	disable_default_key_bindings = true,
	send_composed_key_when_left_alt_is_pressed = true, -- fix @{}~ etc. on German keyboard
	send_composed_key_when_right_alt_is_pressed = true,

	-- theme
	color_scheme = "Kanagawa (Gogh)",
}

--------------------------------------------------------------------------------
tabs.setup(config)
return config
