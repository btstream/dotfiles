local wezterm = require("wezterm")

function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c)
        fields[#fields + 1] = c
    end)
    return fields
end

--- merge tables
---@vararg table tables to be merged
---@return table
local function table_merge(...)
    local tables_to_merge = { ... }
    assert(#tables_to_merge > 1, "There should be at least two tables to merge them")

    for k, t in ipairs(tables_to_merge) do
        assert(type(t) == "table", string.format("Expected a table as function parameter %d", k))
    end

    local result = tables_to_merge[1]

    for i = 2, #tables_to_merge do
        local from = tables_to_merge[i]
        for k, v in pairs(from) do
            if type(k) == "number" then
                local j = k == 1 and 1 or 2
                table.insert(result, j, v)
            elseif type(k) == "string" then
                if type(v) == "table" then
                    result[k] = result[k] or {}
                    result[k] = table_merge(result[k], v)
                else
                    result[k] = v
                end
            end
        end
    end

    return result
end

local fonts = {}
local bold_fonts = {}

--- generate font config
---@param t table
---@return table, table
local function gen_font_config(t)
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

local function platform()
    if wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple == "aarch64-apple-darwin" then
        return "macOS"
    end

    if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
        return "Linux"
    end

    return "Windows"
end

return {
    table_merge = table_merge,
    gen_font_config = gen_font_config,
    platform = platform,
}
