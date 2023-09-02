local wezterm = require("wezterm")

local table_merge = require("utils").table_merge
local darken = require("utils.colors").darken
local gen_font_config = require("utils.wezterm").gen_font_config
local get_pane_app = require("utils.wezterm").get_pane_app
local platform = require("utils.wezterm").platform

----------------------------------------------------------------------
--                     Loading Custom Configs                      --
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

local dbg = darken(colors.base00, 0.45)

-- init window size
config.initial_cols = 155
config.initial_rows = 30

----------------------------------------------------------------------
--                              Tabbar                              --
----------------------------------------------------------------------
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_frame = {
    font = wezterm.font_with_fallback({
        { family = "ShureTechMono Nerd Font" },
        { family = "Iosevka Nerd Font Propo" },
        { family = "Agave Nerd Font Propo" },
        { family = "JetBrainsMono Nerd Font Propo" },
        { family = "Libertinus Sans" },
        { family = "LXGW WenKai Mono" },
    }),
    font_size = platform() == "macOS" and 12 or 10,
    inactive_titlebar_bg = colors.base00,
    active_titlebar_bg = dbg,
    inactive_titlebar_fg = colors.base00,
    active_titlebar_fg = colors.base05,
    inactive_titlebar_border_bottom = colors.base07,
    active_titlebar_border_bottom = colors.base07,
    button_fg = colors.base05,
    button_bg = colors.base02,
    button_hover_fg = colors.base07,
    button_hover_bg = colors.base02,
}

-- disable fancy tab_bar and setting button for windows and linux
-- custom window button for windows and linux
if not config.use_fancy_tab_bar and platform ~= "macOS" then
    config.use_fancy_tab_bar = false
    local btn_padding_left = "  "
    local btn_padding_right = "  "
    if platform() == "Linux" then
        btn_padding_left = " "
        btn_padding_right = " "
    end
    config.tab_bar_style = {
        window_hide = wezterm.format({
            { Foreground = { Color = darken(colors.base0F, 0.45) } },
            { Background = { Color = dbg } },
            { Text = btn_padding_left .. wezterm.nerdfonts.fa_circle .. " " },
        }),
        window_hide_hover = wezterm.format({
            { Foreground = { Color = colors.base0F } },
            { Background = { Color = dbg } },
            { Text = btn_padding_left .. wezterm.nerdfonts.fa_minus_circle .. " " },
        }),
        window_maximize = wezterm.format({
            { Foreground = { Color = darken(colors.base0A, 0.45) } },
            { Background = { Color = dbg } },
            { Text = " " .. wezterm.nerdfonts.fa_circle .. " " },
        }),
        window_maximize_hover = wezterm.format({
            { Foreground = { Color = colors.base0A } },
            { Background = { Color = dbg } },
            { Text = " " .. wezterm.nerdfonts.fa_plus_circle .. " " },
        }),
        window_close = wezterm.format({
            { Foreground = { Color = darken(colors.base0B, 0.45) } },
            { Background = { Color = dbg } },
            { Text = " " .. wezterm.nerdfonts.fa_circle .. btn_padding_right },
        }),
        window_close_hover = wezterm.format({
            { Foreground = { Color = colors.base0B } },
            { Background = { Color = dbg } },
            { Text = " " .. wezterm.nerdfonts.fa_times_circle .. btn_padding_right },
        }),
    }
end

config.colors.tab_bar = {

    -- for use case if use_fancy_tab_bar = false
    background = dbg,

    -- active tab
    active_tab = {
        bg_color = colors.base00,
        fg_color = colors.base0D,
    },

    -- inactive tab
    inactive_tab = {
        bg_color = dbg,
        fg_color = colors.base03,
    },
    inactive_tab_hover = {
        bg_color = colors.base02,
        fg_color = colors.base07,
    },
    inactive_tab_edge = dbg,

    -- new tab button
    new_tab = {
        bg_color = dbg,
        fg_color = colors.base03,
    },
    new_tab_hover = {
        bg_color = colors.base02,
        fg_color = colors.base07,
    },
}

config.tab_max_width = 28
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local icon = require("utils.wezterm.ui").gen_tab_icon(tab.active_pane)

    local has_unseen_output = false
    if not tab.is_active then
        for _, p in pairs(tab.panes) do
            if p.has_unseen_output then
                has_unseen_output = true
                break
            end
        end
    end

    ----------------------------------------------------------------------
    --                      Make tile align center                      --
    ----------------------------------------------------------------------

    -- calculating tab width dynamically
    local current_dimension = wezterm.GLOBAL.current_dimension
    if current_dimension then
        -- best scale_size for current screen
        local scale_size = current_dimension.dpi / 96
        -- physical width of one column character
        local phy_colomn_width = wezterm.column_width(" ") * config.window_frame.font_size * scale_size
        -- how many column a tab title should have
        local width = math.ceil(current_dimension.pixel_width / phy_colomn_width / #tabs)
        max_width = max_width < width and max_width or width
    end

    local title = tab.active_pane.title

    local extra_space = wezterm.column_width(icon) + wezterm.column_width(" ")
    -- check if need to truncate title
    if wezterm.column_width(title) >= max_width or (max_width - wezterm.column_width(title) <= extra_space + 1) then
        title = string.format(" %s ", wezterm.truncate_left(title, max_width - extra_space - 4))
    end
    local len = wezterm.column_width(title)
    -- print(
    --     tab.active_pane.title,
    --     "<><><>",
    --     wezterm.column_width(tab.active_pane.title),
    --     max_width,
    --     extra_space,
    --     "<><><>",
    --     title,
    --     "<><><>",
    --     wezterm.column_width(title)
    -- )

    local lpadding_length = math.ceil((max_width - len) / 2)
    if not config.use_fancy_tab_bar then
        lpadding_length = lpadding_length - wezterm.column_width(icon) - wezterm.column_width(" ")
    end
    lpadding_length = lpadding_length > 0 and lpadding_length or 0
    local lpadding = wezterm.pad_left(" ", lpadding_length)

    local rpadding_length = max_width - len - lpadding_length
    rpadding_length = rpadding_length > 0 and rpadding_length or 0
    local rpadding = wezterm.pad_right(" ", rpadding_length)

    title = string.format("%s%s%s", lpadding, title, rpadding)

    ----------------------------------------------------------------------
    --           generate different colors for different mode           --
    ----------------------------------------------------------------------
    local format = {}

    local domain = require("utils.wezterm").get_pane_domain_info(tab.active_pane)
    local app = require("utils.wezterm").get_pane_app(tab.active_pane)

    local function add_domain_color()
        if domain.domain == "wsl" then
            table.insert(format, {
                Foreground = {
                    Color = tab.is_active and colors.base0B or darken(colors.base0B, 0.45),
                },
            })
        end

        if domain.domain == "ssh" or app == "ssh" then
            table.insert(format, {
                Foreground = {
                    Color = tab.is_active and colors.base09 or darken(colors.base09, 0.45),
                },
            })
        end
    end
    add_domain_color()

    ----------------------------------------------------------------------
    --                      generate return result                      --
    ----------------------------------------------------------------------
    table.insert(format, { Text = " " })
    if has_unseen_output then
        table.insert(format, { Foreground = { Color = colors.base0E } })
    end
    table.insert(format, { Text = icon })
    table.insert(format, "ResetAttributes")

    if not config.use_fancy_tab_bar then
        add_domain_color()
    end

    table.insert(format, { Text = title })

    return wezterm.format(format)
end)

config.window_padding = {
    left = "1cell",
    right = ".5cell",
    top = ".5cell",
    bottom = "0cell",
}

---- update padding for neovim, disable now for a better consistent tab change effect
wezterm.on("update-status", function(window, pane)
    wezterm.GLOBAL.current_dimension = window:get_dimensions()
    if platform() ~= "Windows" then
        local config_overrides = window:get_config_overrides() or {}
        local app = get_pane_app(pane)
        if app == "nvim" or app == "vim" then
            config_overrides.window_padding = {
                left = "1cell",
                right = ".5cell",
                top = 0,
                bottom = 0,
            }
        else
            config_overrides.window_padding = config.window_padding
        end
        window:set_config_overrides(config_overrides)
    end
end)

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
