local tree = {}

---Create a new node
---@param value any
---@return table
tree._create_node = function(value)
    return {
        value = value,
        children = {}
    }
end


---Get chars from string
---@param s any
---@return table
local get_char = function(s)
    local res = {}
    for i=1, string.len(s) do
        table.insert(res, string.sub(s, i, i))
    end
    return res
end


---Find child in table
---@param child_table any
---@param char any
---@return unknown
local search_child = function(child_table, char)
    for _, child in pairs(child_table) do
        if char == child.value then
            return child
        end
    end
    return nil
end


function tree._add_node(root, value)
    local chars = get_char(value)
    local tmp = root
    for i, c in ipairs(chars) do
        local child = search_child(tmp.children, c)

        if tmp.children == {} or not(child) then
            local new_node = tree._create_node(c)
            table.insert(tmp.children, new_node)
            tmp = new_node
        else
            tmp = child
        end
    end
    return root
end


function tree.create_tree(mode)
    local root = tree._create_node("root")
    local maps = vim.api.nvim_get_keymap(mode)
    -- print(vim.inspect(maps))

    for i, map in pairs(maps) do
        -- TODO: add special keymaps (<C>, <F1> etc)
        if not(string.find(map.lhs, "<")) then
            tree._add_node(root, map.lhs)
        end
    end
    return root
end


-- print(vim.inspect(tree.create_tree('n')))
return tree
