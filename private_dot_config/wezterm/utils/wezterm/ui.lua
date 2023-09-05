local wezterm = require("wezterm")
local platform = require("utils.wezterm").platform
local pane_domain = require("utils.wezterm.pane").get_domain_info
local pane_app = require("utils.wezterm.pane").get_current_app

local APP_ICONS = {
    -- eidtors
    nvim = wezterm.nerdfonts.dev_vim,
    vim = wezterm.nerdfonts.dev_vim,

    -- package manager
    brew = wezterm.nerdfonts.md_package_variant_closed_plus,
    pacman = wezterm.nerdfonts.md_package_variant_closed_plus,
    yay = wezterm.nerdfonts.md_package_variant_closed_plus,
    scoop = wezterm.nerdfonts.md_package_variant_closed_plus,

    -- python and so on
    python = wezterm.nerdfonts.dev_python,
    python3 = wezterm.nerdfonts.dev_python,

    -- ssh and other remote control tools
    ssh = wezterm.nerdfonts.md_remote_desktop,

    -- git
    lazygit = wezterm.nerdfonts.dev_git,
    git = wezterm.nerdfonts.dev_git,

    -- statistics
    btop = wezterm.nerdfonts.md_monitor_dashboard,
    top = wezterm.nerdfonts.md_monitor_dashboard,
}

local PLATFORM_ICONS = {
    Windows = wezterm.nerdfonts.md_microsoft_windows,
    Linux = wezterm.nerdfonts.linux_tux,
    macOS = wezterm.nerdfonts.linux_apple,
}

local function gen_tab_icon(pane)
    local domain = pane_domain(pane)
    local app = pane_app(pane)

    -- print(app)

    if APP_ICONS[app] ~= nil then
        return APP_ICONS[app]
    end

    if domain.domain == "wsl" then
        local icon = domain.dist == "arch" and wezterm.nerdfonts.linux_archlinux
            or (wezterm.nerdfonts["linux_" .. domain.dist] or wezterm.nerdfonts.linux_tux)

        if icon ~= nil then
            return icon
        end

        return wezterm.nerdfonts.linux_tux
    end

    if domain.domain == "ssh" then
        return APP_ICONS["ssh"]
    end

    if platform() == "Linux" then
        local linux_dist = require("utils.wezterm").os_release()
        if linux_dist == "arch" then
            return wezterm.nerdfonts.linux_archlinux
        else
            return wezterm.nerdfonts["linux_" .. linux_dist] or wezterm.nerdfonts.linux_tux
        end
    end

    return PLATFORM_ICONS[platform()]
end

local function get_supported_apps()
    local ret = {}
    for key, _ in pairs(APP_ICONS) do
        table.insert(ret, key)
    end
    return ret
end

return {
    gen_tab_icon = gen_tab_icon,
    get_supported_apps = get_supported_apps,
}
