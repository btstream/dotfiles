local wezterm = require("wezterm")
local fonts = {}
local bold_fonts = {}

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
        extra = domain[2]:lower(),
    }
end

function M.get_pane_app(pane)
    -- local domain = M.get_pane_domain_info(pane)

    -- if domain == "local" then
    local app = pcall(function()
        return pane:foreground_process_name()
    end) and pane:get_foreground_process_name() or pane.foreground_process_name

    local sep = M.platform() == "Windows" and "\\" or "/"

    -- current app is none, try to extract app from title
    if app == nil then
        -- return nil
        local title = pcall(function()
            return pane:get_title()
        end) and pane:get_title() or pane.title

        for _, value in pairs(require("utils.wezterm.ui").get_supported_apps()) do
            if title:lower():find(value) then
                return value
            end
        end
    end

    app = app:split(sep)
    app = app[#app]

    if app == nil then
        return nil
    end

    if M.platform() == "Windows" then
        return app:split(".")[1]:lower()
    end

    return app:lower()
end

return M