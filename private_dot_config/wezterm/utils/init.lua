local wezterm = require("wezterm")

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
                table.insert(result, v)
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

local function gen_font_config(t)
    local fonts = {}
    local bold_fonts = {}
    for _, v in ipairs(t) do
        table.insert(fonts, {
            family = v,
        })
        table.insert(bold_fonts, {
            family = v,
            weight = "Bold",
        })
    end
    return wezterm.font_with_fallback(fonts), { { intensity = "Bold", font = wezterm.font_with_fallback(bold_fonts) } }
end

return {
    table_merge = table_merge,
    gen_font_config = gen_font_config,
}
