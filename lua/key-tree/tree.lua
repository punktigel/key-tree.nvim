local tree = {}
local utils = require("key-tree.utils")
tree.Warnings = {}

---Create a new node
---@param value any
---@param info string
---@return table
tree._create_node = function(value, info)
    return {
        value = value,
        info = info,
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


--- Add a new keymap based on lhs mapping
---@param root any
---@param value string
---@param desc string
---@return any
function tree._add_mapping(root, value, desc)
    local chars = get_char(value)
    local tmp = root
    local info = ""

    for i, c in ipairs(chars) do
        local child = search_child(tmp.children, c)
        -- add the description of the keymap with the last key
        if (chars[i + 1] == nil) then
            if (desc == nil) then
                info = value
            else
                info = " " .. desc
            end
        end

        if tmp.children == {} or not(child) then
            local new_node = tree._create_node(c, info)
            table.insert(tmp.children, new_node)

            -- update if keymap is a prefix
            if tmp.info ~= "" and tmp.info ~= nil and not string.find(tmp.info, "WARNING") then
                tmp.info = " WARNING " .. info
                table.insert(tree.Warnings, {info = tmp.info, lhs = string.sub(value, 0, i - 1), location = "", lnum = ""})
            end

            tmp = new_node
        else
            -- update if keymap is a prefix
            if (chars[i + 1] == nil) then
                child.info = " WARNING " .. info
                table.insert(tree.Warnings, {info = child.info, lhs = value, location = "", lnum = ""})
            end
            tmp = child
        end
    end
    return root
end


--- Create a key tree with keymappings based on a mode
---@param mode string
---@return table
function tree.create_tree(mode)
    local root = tree._create_node("root", "root")
    local maps = vim.api.nvim_get_keymap(mode)
    tree.Warnings = {}

    for _, map in pairs(maps) do
        -- TODO: add special keymaps (<C>, <F1> etc)
        if not(string.find(map.lhs, "<")) then
            tree._add_mapping(root, map.lhs, map.desc)
        else
            -- Print other lhs (<C>, <F1> etc)
            -- print(map.lhs)
            -- local pref = map.lhs
            -- print(string.sub(pref, string.find(pref, ">") + 1))
        end
    end
    return root
end


---Create a table with all prefix warnings from keymappings
---@param mode string
tree.setWarningTable = function(mode)
    tree.create_tree(mode)
    local locations = tree.getLocationTable()

    for _, warning in pairs(tree.Warnings) do
        for _, mapping in pairs(locations) do
            local map_lhs = string.gsub(mapping.lhs, "<Space>", " ")

            if map_lhs == warning.lhs then
                if not mapping.file then
                    warning.location = "NO FILE FOUND"
                else
                    print(mapping.file)
                    warning.location = mapping.file
                    warning.lnum = mapping.lnum
                end
            end
        end
    end
    -- print(vim.inspect(tree.Warnings))
end


---Return a table with the location where the keymappings are set
---@return table
tree.getLocationTable = function()
    local str_mappings = vim.api.nvim_call_function('execute', {'map'})
    local mapping_table  = utils.split_str(str_mappings, "\n")
    local locations = {}

    for _, mapping in pairs(mapping_table) do
        if nil ~= string.find(mapping, "<")  then
            local parts = utils.split_str(mapping, " ")
            local lhs = string.gsub(parts[3], " ", "")
            local file = nil
            local lnum = nil

            for _, p in pairs(parts) do
                if nil ~= string.find(p, "~") then
                    local f_data = utils.split_str(p, ":")
                    file = f_data[1]
                    lnum = utils.split_str(f_data[2], ">")[1]
                end
            end

            table.insert(locations, {lhs = lhs, file = file, lnum = lnum})
        end
    end
    return locations
end

return tree
