local wezterm = require("wezterm")
local platform = require("utils").platform

local app_icons = {
    nvim = wezterm.nerdfonts.dev_vim,
    vim = wezterm.nerdfonts.dev_vim,

    ssh = wezterm.nerdfonts.md_ssh,
    lazygit = wezterm.nerdfonts.dev_git,

    btop = wezterm.nerdfonts.md_monitor_dashboard,
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
        icon = app_icons[app]
    end

    return icon
end

local function gen_tab_icon(pane)
    local domain_name = pane.domain_name

    -- set icon indicator
    local icon
    if domain_name == "local" then
        icon = gen_app_icon(pane)
        if icon then
            return icon
        end

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

    return icon
end

return {
    gen_tab_icon = gen_tab_icon,
}
