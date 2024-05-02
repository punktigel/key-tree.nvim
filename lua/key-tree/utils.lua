local utils = {}

--- Split a string based on a separating string or character
---@param s string
---@param separator string
---@return table
utils.split_str = function(s, separator)
    local split_table = {}
    local i = 1
    local start = 0
    while true do
        i = string.find(s, separator, i + 1)
        if i == nil then
            table.insert(split_table, string.sub(s, start, -1))
            break
        end

        table.insert(split_table, string.sub(s, start, i - 1))
        start = i + 1
    end
    -- print(vim.inspect(split_table))
    return split_table
end



---Format table with keymap warnings to a quickfix list
---@param Warnings table
---@return table
utils.get_Warning_qf = function(Warnings)
    local qf = {}
    for _, entry in pairs(Warnings) do
        local location = vim.api.nvim_call_function('expand', {entry.location})
        table.insert(qf, {filename = location, lnum = entry.lnum, text = entry.info .. " - <" .. entry.lhs .. ">"})
    end
    return qf
end

return utils
