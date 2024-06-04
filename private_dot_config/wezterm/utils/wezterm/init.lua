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
    if wezterm.target_triple:find("apple") then
        return "macOS"
    end

    if wezterm.target_triple:find("linux") then
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

return M
