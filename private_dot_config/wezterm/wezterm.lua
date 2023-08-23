local wezterm = require("wezterm")
local gen_font_config = require("utils").gen_font_config
local table_merge = require("utils").table_merge
local darken = require("utils.colors").darken

function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c)
        fields[#fields + 1] = c
    end)
    return fields
end

local function platform()
    if wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple == "aarch64-apple-darwin" then
        return "macOS"
    end

    if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
        return "Linux"
    end

    return "Windows"
end

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
    "JetBrainsMono Nerd Font Propo",
    "NotoSansM Nerd Font Propo",
    "NotoSansMono Nerd Font Propo",
    "mononoki Nerd Font Propo",
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
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_frame = {
    font = wezterm.font_with_fallback({
        -- { family = "JetBrainsMono Nerd Font Propo", weight = "Bold" },
        { family = "Libertinus Sans", weight = "Bold" },
        { family = "Noto Serif", weight = "Bold" },
        { family = "Times", weight = "Bold" },
        { family = "Times New Roman", weight = "Bold" },
    }),
    font_size = platform() == "macOS" and 12 or 10,
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
-- config.use_fancy_tab_bar = false
config.colors.tab_bar = {

    -- for use case if use_fancy_tab_bar = false
    background = darken(colors.base00, 0.15),

    -- active tab
    active_tab = {
        bg_color = colors.base00,
        fg_color = colors.base07,
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
config.tab_max_width = 26
-- config.hide_tab_bar_if_only_one_tab = wezterm.target_triple == "x86_64-pc-windows-msvc" and false or true
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local domain_name = tab.active_pane.domain_name

    -- set icon indicator
    local icon
    if domain_name == "local" then
        local p = platform()
        if p == "Windows" then
            icon = wezterm.nerdfonts.md_microsoft_windows
        end

        if p == "macOS" then
            icon = wezterm.nerdfonts.linux_apple
        end

        if p == "Linux" then
            icon = wezterm.nerdfonts.linux_archlinux
        end
    else
        local domain = domain_name:split(":")
        if domain[1] == "WSL" then
            if domain[2] == "Arch" then
                icon = wezterm.nerdfonts.linux_archlinux
            end
        end

        if domain[1]:lower() == "ssh" then
            icon = wezterm.nerdfonts.md_ssh
        end
    end

    -- local title = string.format("%s. %s %s", tab.tab_index + 1, tab.active_pane.title, icon)
    local title = string.format(" %s ", tab.active_pane.title)
    local len = string.len(title)
    if len < max_width then
        local lpadding = string.rep(" ", math.ceil((max_width - len) / 2))
        local rpadding = string.rep(" ", math.floor((max_width - len) / 2))
        title = string.format("%s%s%s", lpadding, title, rpadding)
    else
        title = wezterm.truncate_right(title, max_width)
    end
    return wezterm.format({
        { Text = " " },
        { Foreground = { Color = tab.is_active and colors.base0D or colors.base03 } },
        { Text = icon },
        -- { Foreground = { Color = tab.is_active and colors.base0D or colors.base03 } },
        { Text = title },
        "ResetAttributes",
    })
end)

config.window_padding = {
    bottom = 0,
}

----------------------------------------------------------------------
--                         Command Palette                          --
----------------------------------------------------------------------
config.command_palette_bg_color = darken(colors.base02, 0.1)
config.command_palette_fg_color = colors.base04
config.command_palette_font_size = 12

----------------------------------------------------------------------
--                              Fonts                               --
----------------------------------------------------------------------
local f, r = gen_font_config(fonts)

-- config fallback
config.font = f
config.font_rules = r
config.line_height = 1.45
config.font_size = platform() == "macOS" and 13 or 9
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"
config.bold_brightens_ansi_colors = true

----------------------------------------------------------------------
--                            Underline                             --
----------------------------------------------------------------------
config.underline_thickness = "200%"
config.underline_position = "-.25cell"

----------------------------------------------------------------------
--                             For Keys                             --
----------------------------------------------------------------------
if platform() ~= "macOS" then
    local keys = {}
    for i = 1, 8 do
        table.insert(keys, {
            key = tostring(i),
            mods = "CTRL",
            action = wezterm.action({ ActivateTab = i - 1 }),
        })
    end
    table.insert(keys, {
        key = "t",
        mods = "CTRL|SHIFT",
        action = wezterm.action.SpawnTab("DefaultDomain"),
    })
    table.insert(keys, {
        key = "!",
        mods = "CTRL|SHIFT",
        action = wezterm.action.SpawnTab("DefaultDomain"),
    })
    local shifted_num = {
        "@",
        "#",
        "$",
        "%",
        "^",
        "&",
        "*",
        "(",
        ")",
    }
    for index, domain in pairs(wezterm.default_wsl_domains()) do
        table.insert(keys, {
            key = shifted_num[index],
            mods = "CTRL|SHIFT",
            action = wezterm.action.SpawnTab({ DomainName = domain.name }),
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
        { key = "p", mods = "CMD", action = wezterm.action.ActivateCommandPalette },
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
--                            front end                             --
----------------------------------------------------------------------
config.front_end = "OpenGL"

----------------------------------------------------------------------
--                      End of Config, return                       --
----------------------------------------------------------------------

if has_custom and type(custom_conf) == "table" then
    table_merge(config, custom_conf)
end

return config
