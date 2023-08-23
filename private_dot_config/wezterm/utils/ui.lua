local wezterm = require("wezterm")
local platform = require("utils").platform

local app_icons = {
    nvim = wezterm.nerdfonts.dev_vim,
    ssh = wezterm.nerdfonts.md_ssh,
}

local function gen_app_icon(pane)
    local icon = nil
    return icon
end

local function gen_tab_icon(pane)
    local domain_name = pane.domain_name

    -- print(pane.foreground_process_name)

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

    return icon
end

return {
    gen_tab_icon = gen_tab_icon,
}
