local key_tree = require("key-tree.tree")
local ui = require("key-tree.ui")
local folding = require("key-tree.folding")
local utils = require("key-tree.utils")

local M = {}
M._buf_keys = {}
M._win_open = false
M._win_id = nil
M._buf_nr = nil


local create_display
create_display = function(tree, iteration)
    if next(tree) == nil then
        return
    end

    if tree.children ~= nil then
        tree = tree.children
    end

    for i, _ in pairs(tree) do
        table.insert(M._buf_keys, string.rep("\t", iteration) .. vim.inspect(tree[i].value) .. tree[i].info)
        create_display(tree[i], iteration + 1)
    end
end


--- Calculate key tree
---@param recompute boolean
local function get_tree(recompute)
    -- dont recompute the key tree
    if not(recompute) and next(M._buf_keys) ~= nil then
        return
    end

    -- clear previous key tree
    M._buf_keys = {}
    table.insert(M._buf_keys, "Key-Tree")
    local tree = key_tree.create_tree('n')

    create_display(tree, 1)
end


--- Toggle floating window (key-tree)
function M.toggle_win()
    if M._win_open then
        -- close win
        print("close win")
        ui.close_win(M._win_id, M._buf_nr)
        M._win_open = false
    else
        get_tree(false)
        -- create buf and open win
        print("create buf and open win")
        M._buf_nr = ui.create_buf(M._buf_keys)
        M._win_id = ui.open_win(M._buf_nr)
        M._win_open = true

        folding.set_folding()
    end
end


---Setup a quickfix list with all prefix warnings from keymappings and open it
---@param mode string
function M.Warning_qf(mode)
    key_tree.setWarningTable(mode)
    local qf = utils.get_Warning_qf(key_tree.Warnings)

    vim.api.nvim_call_function("setqflist", {qf})
    vim.api.nvim_command("copen")
end


return M
