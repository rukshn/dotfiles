--------------------------------------------------------------------------------
---@diagnostic enable: unused-local
--------------------------------------------------------------------------------
-- UTILS

local wt = require("wezterm")
local act = wt.action
local actFun = wt.action_callback

local host = wt.hostname()
local isAtOffice = (host:find("mini") or host:find("eduroam") or host:find("fak1")) ~= nil

local fontSize = 16
if isAtOffice then
	fontSize = 16
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
wt.on("format-tab-title", function(tab)
	-- prefers the title that was set via `tab:set_title()` or `wezterm cli
	-- set-tab-title`
	local title = tab.tab_title
	if not title or title == "" then
		title = tab.active_pane.title
	end

	local icon
	if title == "zsh" or title == "wezterm" then
		local pwdBasefolder = tab.active_pane.current_working_dir:gsub(".*/(.*)/$", "%1"):gsub("%%20", " ")
		title = pwdBasefolder
		icon = "  "
	elseif title:find("^docs") then
		icon = "  "
	else
		icon = "  "
	end

	return " " .. icon .. title .. " "
end)

-- WINDOW TITLE
-- set to pwd basename
-- https://wezfurlong.org/wezterm/config/lua/window-events/format-window-title
wt.on("format-window-title", function(_, pane)
	local pwd = pane.current_working_dir:gsub("^file://[^/]+", ""):gsub("%%20", " ")
	return pwd
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
	color_scheme = "Catppuccin Mocha",
	-- Passwords
	-- INFO `sudo visudo`, and change line `Defaults env_reset` to `Defaults env_reset,pwfeedback`
	-- to see asterisks in general
	detect_password_input = false,

	-- Start/Close
	default_cwd = wt.home_dir .. "~/Documents",
	quit_when_all_windows_are_closed = true,
	window_close_confirmation = "NeverPrompt",

	-- Mouse & Cursor
	hide_mouse_cursor_when_typing = true,
	default_cursor_style = "BlinkingBar", -- mostly overwritten by vi-mode.zsh
	cursor_thickness = "0.07cell",
	cursor_blink_rate = 700,
	cursor_blink_ease_in = "Constant", -- Constant = no fading
	cursor_blink_ease_out = "Constant",
	force_reverse_video_cursor = true, -- true = color is reverse, false = color by color scheme

	-- font
	-- INFO some nerd font requires a space after them to be properly sized
	font = wt.font("Monaspace Neon"),
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
		top = "0.8cell", -- extra height to account for macOS traffic lights
		bottom = "0.3cell",
	},
	min_scroll_bar_height = "3cell",
	scrollback_lines = 5000,

	-- Hyperlinks
	hyperlink_rules = myHyperlinkRules,

	-- Tabs
	enable_tab_bar = true,
	tab_max_width = 40, -- I have few tabs, therefore enough space for more width
	use_fancy_tab_bar = false, -- `false` makes the tabs bigger and more in terminal style
	show_tabs_in_tab_bar = true, -- can show a status line in the tab bar, too
	show_new_tab_button_in_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,

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

	colors = require("lua/rose-pine").colors(),
	window_frame = require("lua/rose-pine").window_frame(),
}

--------------------------------------------------------------------------------

local colors = require("lua/rose-pine").colors()
local window_frame = require("lua/rose-pine").window_frame()
return config
