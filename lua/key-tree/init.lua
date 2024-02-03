local key_tree = require("key-tree.tree")
local ui = require("key-tree.ui")
local folding = require("key-tree.folding")

local M = {}
M._buf_keys = {}


local display_tree
display_tree = function(tree, iteration)
    if next(tree) == nil then
        return
    end

    if tree.children ~= nil then
        tree = tree.children
    end

    for i, value in pairs(tree) do
        -- print("VALUE: " .. string.rep("    ",iteration) .. vim.inspect(tree[i].value))
        table.insert(M._buf_keys, string.rep("\t", iteration) .. vim.inspect(tree[i].value))
        display_tree(tree[i], iteration + 1)
    end
end


-- Tests
-- M._root = M._create_node("Root")
-- print(vim.inspect(M._add_node(M._root, 'ab')))
-- print(vim.inspect(M._add_node(M._root, 'ac')))


local function get_tree()
    table.insert(M._buf_keys, "Key-Tree")
    local tree = key_tree.create_tree('n')
    -- print(vim.inspect(tree))

    display_tree(tree, 1)
end


local win_open = false
local win_id = ""
local buf_nr = ""
function toggle_win()
    if win_open then
        -- close win
        print("close win")
        ui.close_win(win_id, buf_nr)
        win_open = false
    else
        get_tree()
        -- create buf and open win
        print("create buf and open win")
        buf_nr = ui.create_buf(M._buf_keys)
        win_id = ui.open_win(buf_nr)
        win_open = true

        folding.set_folding()
    end
end

return M
