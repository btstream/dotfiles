local wezterm = require("wezterm")
local platform = require("utils.wezterm").platform
local pane_domain = require("utils.wezterm").get_pane_domain_info
local pane_app = require("utils.wezterm").get_pane_app

local APP_ICONS = {
    nvim = wezterm.nerdfonts.dev_vim,
    vim = wezterm.nerdfonts.dev_vim,

    ssh = wezterm.nerdfonts.md_ssh,
    lazygit = wezterm.nerdfonts.dev_git,

    btop = wezterm.nerdfonts.md_monitor_dashboard,
}

local PLATFORM_ICONS = {
    Windows = wezterm.nerdfonts.md_microsoft_windows,
    Linux = wezterm.nerdfonts.linux_tux,
    macOS = wezterm.nerdfonts.linux_apple,
}

local function gen_app_icon(pane)
    local icon = nil

    if pane.foreground_process_name == nil then
        return nil
    end

    local sep = platform() == "Windows" and "\\" or "/"
    local app = pane.foreground_process_name:split(sep)

    app = app[#app]
    if app then
        if platform() == "Windows" then
            app = app:split(".")[1]
        end
        print(app)
        icon = APP_ICONS[app]
    end

    return icon
end

local function gen_tab_icon(pane)
    local domain = pane_domain(pane)
    local app = pane_app(pane)

    if domain == nil then
        return PLATFORM_ICONS[platform()]
    end

    if domain.domain == "local" then
        if APP_ICONS[app] == nil then
            return PLATFORM_ICONS[platform()]
        else
            return APP_ICONS[app]
        end
    end

    if domain.domain == "wsl" then
        local icon = domain.dist == "arch" and wezterm.nerdfonts.linux_archlinux
            or wezterm.nerdfonts["linux_" .. domain.dist]

        if icon ~= nil then
            return icon
        end

        return wezterm.nerdfonts.linux_tux
    end

    if domain.domain == "ssh" then
        return wezterm.nerdfonts.md_ssh
    end
end

return {
    gen_tab_icon = gen_tab_icon,
}
