local wezterm = require("wezterm")
local fonts = {}
local bold_fonts = {}
local linux_dist_id = nil

local M = {}

--- generate font config
---@param t table
---@return table, table
function M.gen_font_config(t)
    for i, v in ipairs(t) do
        local j = i == 1 and 1 or 2
        table.insert(fonts, j, {
            family = v,
        })
        table.insert(bold_fonts, j, {
            family = v,
            weight = "Bold",
        })
    end
    return wezterm.font_with_fallback(fonts), { { intensity = "Bold", font = wezterm.font_with_fallback(bold_fonts) } }
end

--- return platform information
---@return string "macOS" if on mac
function M.platform()
    if wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple == "aarch64-apple-darwin" then
        return "macOS"
    end

    if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
        return "Linux"
    end

    return "Windows"
end

function M.os_release()
    if M.platform() ~= "Linux" then
        return M.platform()
    end

    if linux_dist_id then
        return linux_dist_id
    end

    local os_release = io.open("/etc/os-release")
    if os_release then
        for l in os_release:lines("l") do
            local ll = l:split("=")
            if ll[1] == "ID" then
                linux_dist_id = ll[2]:lower()
                break
            end
        end
    end

    return linux_dist_id
end

function M.get_pane_domain_info(pane)
    local domain_name = pcall(function()
        return pane:get_domain_name()
    end) and pane:get_domain_name() or pane.domain_name

    if domain_name == nil then
        return nil
    end

    if domain_name == "local" then
        return {
            domain = "local",
        }
    end

    local domain = domain_name:split(":")
    if domain[1]:lower() == "wsl" then
        return {
            domain = "wsl",
            dist = domain[2]:lower(),
        }
    end

    return {
        domain = domain[1]:lower(),
        extra = domain[2] ~= nil and domain[2]:lower() or nil,
    }
end

local function guess_app_name_from_title(pane)
    local title = pcall(function()
        return pane:get_title()
    end) and pane:get_title() or pane.title

    local sep = M.platform() == "Windows" and "\\" or "/"
    sep = M.get_pane_domain_info(pane).domain == "wsl" and "/" or sep

    -- current title is a path, suitable for oh-my-zsh's termsupport
    if #title:split(sep) > 1 then
        return nil
    end

    for _, value in pairs(require("utils.wezterm.ui").get_supported_apps()) do
        if title:lower():find(value) then
            return value
        end
    end
end

function M.get_pane_app(pane)
    local domain = M.get_pane_domain_info(pane)

    if domain == nil or domain.domain == "local" then
        local app = pcall(function()
            return pane:foreground_process_name()
        end) and pane:get_foreground_process_name() or pane.foreground_process_name

        local sep = M.platform() == "Windows" and "\\" or "/"

        app = app:split(sep)
        app = app[#app]

        -- wezterm.log_info(string.format("detected app at running is %s", app))

        -- some of the program is writing with shell script,
        -- which may indicator foreground_process_name with a
        -- script interpreter
        if
            app == nil
            or app == "zsh"
            or app == "bash"
            or app == "cmd.exe"
            or app == "pwsh.exe"
            or app:find("^python")
            or app:find("^ruby")
        then
            return guess_app_name_from_title(pane)
        end

        if M.platform() == "Windows" then
            return app:split(".")[1]:lower()
        end

        return app:lower()
    else
        local title = pcall(function()
            return pane:get_title()
        end) and pane:get_title() or pane.title

        if (domain.domain == "wsl" or domain.domain == "ssh") and (title == "v" or title == "e") then
            return "nvim"
        end

        return guess_app_name_from_title(pane)
    end
end

return M
