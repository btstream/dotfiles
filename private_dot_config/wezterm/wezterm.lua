local wezterm = require("wezterm")
local config = {}

----------------------------------------------------------------------
--                              Theme                               --
----------------------------------------------------------------------
--color scheme
-- config.color_scheme = "OneHalfDark"
-- modify OneHalfDark to make zsh more uesable
config.colors = {
    foreground = "#dcdfe4",
    background = "#282c34",
    cursor_bg = "#a3b3cc",
    cursor_border = "#a3b3cc",
    cursor_fg = "#dcdfe4",
    selection_bg = "#474e5d",
    selection_fg = "#dcdfe4",
    ansi = { "#474e5d", "#e06c75", "#98c379", "#e5c07b", "#61afef", "#c678dd", "#56b6c2", "#dcdfe4" },
    brights = { "#474e5d", "#e06c75", "#98c379", "#e5c07b", "#61afef", "#c678dd", "#56b6c2", "#dcdfe4" },
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
    inactive_titlebar_bg = "#181a1f",
    active_titlebar_bg = "#22252c",
    inactive_titlebar_fg = "#181a1f",
    active_titlebar_fg = "#a3b3cc",
    inactive_titlebar_border_bottom = "#dcdfe4",
    active_titlebar_border_bottom = "#dcdfe4",
    button_fg = "#a3b3cc",
    button_bg = "#22252c",
    button_hover_fg = "#dcdfe4",
    button_hover_bg = "#22252c",
}
config.colors.tab_bar = {
    -- active tab
    active_tab = {
        bg_color = "#282c34",
        fg_color = "#61afef",
    },

    -- inactive tab
    inactive_tab = {
        bg_color = "#22252c",
        fg_color = "#474e5d",
    },
    inactive_tab_hover = {
        bg_color = "#22252c",
        fg_color = "#dcdfe4",
    },
    inactive_tab_edge = "#22252c",

    -- new tab button
    new_tab = {
        bg_color = "#22252c",
        fg_color = "#474e5d",
    },
    new_tab_hover = {
        bg_color = "#22252c",
        fg_color = "#dcdfe4",
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

----------------------------------------------------------------------
--                              Fonts                               --
----------------------------------------------------------------------
local fonts = {
    { family = "Noto Sans Mono" }, -- main font use normal version, to provide narrow exp
    { family = "NotoSansMono Nerd Font Mono" }, -- use NerdVersion to support nerd icons
    { family = "NotoSansMono NF" }, -- windows version for fallback
    { family = "mononoki Nerd Font Mono" }, -- for fallback
    { family = "LXGW WenKai Mono" },
}

-- for bold fonts, in case of wezterm does not
-- get bold font for some fonts like `LXGW WenKai Mono`
local bold_fonts = {}
for _, value in pairs(fonts) do
    local v = {}
    v.family = value.family
    v.weight = "Bold"
    table.insert(bold_fonts, v)
end
local font_rules = {}
table.insert(font_rules, { intensity = "Bold", font = wezterm.font_with_fallback(bold_fonts) })

-- config fallback
config.font = wezterm.font_with_fallback(fonts)
config.font_rules = font_rules
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
end

----------------------------------------------------------------------
--                            all extra                             --
----------------------------------------------------------------------
config.audible_bell = "Disabled"
config.exit_behavior = "Close"
config.window_close_confirmation = "NeverPrompt"

----------------------------------------------------------------------
--                      End of Config, return                       --
----------------------------------------------------------------------
return config
