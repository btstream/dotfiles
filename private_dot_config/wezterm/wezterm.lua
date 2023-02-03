local wezterm = require("wezterm")
local gen_font_config = require("utils").gen_font_config
local table_merge = require("utils").table_merge
local darken = require("utils.colors").darken

----------------------------------------------------------------------
--                     Loadding Custom Configs                      --
----------------------------------------------------------------------

-- colors
local has_custom, custom_conf = pcall(require, "custom")

local color_scheme = "onedark"
local fonts = {}
if has_custom then
    color_scheme = custom_conf.color_scheme and custom_conf.color_scheme or color_scheme
    fonts = custom_conf.fonts and custom_conf.fonts or {}
    custom_conf.color_scheme = nil -- to avoid use wezterm's inner color sheme
    custom_conf.fonts = nil -- wezterm does not have a fonts config key, delete it to avoid warnnings
end
local colors = require("colors." .. color_scheme)

local default_fonts = {
    "NotoSansMono Nerd Font Mono",
    "NotoSansMono NF",
    "Noto Sans Mono",
    "mononoki Nerd Font Mono",
    "LXGW WenKai Mono",
}
for _, f in pairs(default_fonts) do
    table.insert(fonts, f)
end

local config = {}
----------------------------------------------------------------------
--                              Theme                               --
----------------------------------------------------------------------
--color scheme
-- config.color_scheme = "OneHalfDark"
-- modify OneHalfDark to make zsh more uesable
config.colors = {
    foreground = colors.base07,
    background = colors.base00,
    cursor_bg = colors.base06,
    cursor_border = colors.base06,
    cursor_fg = colors.base07,
    selection_bg = colors.base01,
    selection_fg = colors.base07,
    ansi = {
        colors.base01,
        colors.base08,
        colors.base0B,
        colors.base0A,
        colors.base0D,
        colors.base0E,
        colors.base0C,
        colors.base07,
    },
    brights = {
        colors.base01,
        colors.base0F,
        colors.base0B,
        colors.base0A,
        colors.base0D,
        colors.base0E,
        colors.base0C,
        colors.base07,
    },
}

-- init windo size
config.initial_cols = 155
config.initial_rows = 30

----------------------------------------------------------------------
--                              Tabbar                              --
----------------------------------------------------------------------
config.window_frame = {
    font = wezterm.font_with_fallback({
        { family = "Libertinus Sans", weight = "Bold" },
        { family = "Noto Serif", weight = "Bold" },
        { family = "Times", weight = "Bold" },
        { family = "Times New Roman", weight = "Bold" },
    }),
    font_size = wezterm.target_triple == "x86_64-apple-darwin" and 12 or 10,
    inactive_titlebar_bg = colors.base00,
    active_titlebar_bg = darken(colors.base00, 0.15),
    inactive_titlebar_fg = colors.base00,
    active_titlebar_fg = colors.base05,
    inactive_titlebar_border_bottom = colors.base07,
    active_titlebar_border_bottom = colors.base07,
    button_fg = colors.base05,
    button_bg = colors.base02,
    button_hover_fg = colors.base07,
    button_hover_bg = colors.base02,
}
config.colors.tab_bar = {
    -- active tab
    active_tab = {
        bg_color = colors.base00,
        fg_color = colors.base0D,
    },

    -- inactive tab
    inactive_tab = {
        bg_color = darken(colors.base00, 0.15),
        fg_color = colors.base03,
    },
    inactive_tab_hover = {
        bg_color = colors.base02,
        fg_color = colors.base07,
    },
    inactive_tab_edge = darken(colors.base00, 0.15),

    -- new tab button
    new_tab = {
        bg_color = darken(colors.base00, 0.15),
        fg_color = colors.base03,
    },
    new_tab_hover = {
        bg_color = colors.base02,
        fg_color = colors.base07,
    },
}
config.tab_max_width = 30
config.hide_tab_bar_if_only_one_tab = true
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local title = string.format("%s. %s", tab.tab_index + 1, tab.active_pane.title)
    local len = string.len(title)
    if len < max_width then
        local lpadding = string.rep(" ", math.ceil((max_width - len) / 2))
        local rpadding = string.rep(" ", math.floor((max_width - len) / 2))
        title = string.format("%s%s%s", lpadding, title, rpadding)
    else
        title = wezterm.truncate_right(title, max_width)
    end
    return wezterm.format({
        { Text = title },
    })
end)

config.window_padding = {
    bottom = 0,
}

----------------------------------------------------------------------
--                              Fonts                               --
----------------------------------------------------------------------
local f, r = gen_font_config(fonts)

-- config fallback
config.font = f
config.font_rules = r
config.line_height = 1.25
config.font_size = wezterm.target_triple == "x86_64-apple-darwin" and 12 or 9
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"
config.bold_brightens_ansi_colors = true

----------------------------------------------------------------------
--                             For Keys                             --
----------------------------------------------------------------------
if wezterm.target_triple ~= "x86_64-apple-darwin" then
    local keys = {}
    for i = 1, 8 do
        table.insert(keys, {
            key = tostring(i),
            mods = "CTRL",
            action = wezterm.action({ ActivateTab = i - 1 }),
        })
    end
    config.keys = keys
else
    config.send_composed_key_when_left_alt_is_pressed = true
    config.send_composed_key_when_right_alt_is_pressed = false
    config.keys = {
        { key = "s", mods = "CMD", action = {
            SendKey = { key = "s", mods = "CTRL" },
        } },
    }
end

----------------------------------------------------------------------
--                            all extra                             --
----------------------------------------------------------------------
config.audible_bell = "Disabled"
config.exit_behavior = "Close"
config.window_close_confirmation = "NeverPrompt"

----------------------------------------------------------------------
--                             wayland                              --
----------------------------------------------------------------------
-- if os.getenv("XDG_SESSION_TYPE") == "wayland" then
config.enable_wayland = false
-- end

----------------------------------------------------------------------
--                      End of Config, return                       --
----------------------------------------------------------------------

if has_custom and type(custom_conf) == "table" then
    table_merge(config, custom_conf)
end

return config
