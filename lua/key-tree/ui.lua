local ui = {}

--- Return floating window configuration
---@return table
local win_config = function()
    local row = 3
    local col = 5
    local height = vim.api.nvim_win_get_height(0) - 2 * row - 1
    local width = vim.api.nvim_win_get_width(0) - 2 * col - 1

    return {
        relative = "win",
        row = row,
        col = col,
        width = width,
        height = height,
        border = "single",
        style = "minimal",
        title = "Key Tree",
    }
end


--- Create a new buffer with text
---@param table table
---@return unknown
function ui.create_buf(table)
    -- create new buf
    local buf_nr = vim.api.nvim_create_buf(false, true)
    print("BUFNR: " .. buf_nr)

    -- add table from table
    vim.api.nvim_buf_set_lines(buf_nr, 0, 1, false, table)
    return buf_nr
end


--- Open floating window with specified buffer
---@param buf_nr any
---@return unknown
function ui.open_win(buf_nr)
    local win_id = vim.api.nvim_open_win(buf_nr, true, win_config())
    print("WIN: " .. win_id)
    return win_id
end


--- Close floating window and delete buffer
---@param win_id any
---@param buf_nr any
function ui.close_win(win_id, buf_nr)
    if vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)
        vim.api.nvim_buf_delete(buf_nr, {force = true})
    end
end

return ui
