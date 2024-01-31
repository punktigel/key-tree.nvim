local M = {}
-- TODO: restructure code

M._mappings = {}
M._chars = {}
M._tree = {}
M._buf_keys = {}


---Create a new node
---@param value any
---@return table
M._create_node = function(value)
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


M._add_node = function(root, value)
    local chars = get_char(value)
    local tmp = root
    for i, c in ipairs(chars) do
        local child = search_child(tmp.children, c)

        if tmp.children == {} or not(child) then
            local new_node = M._create_node(c)
            table.insert(tmp.children, new_node)
            tmp = new_node
        else
            tmp = child
        end
    end
    return root
end



local create_tree = function(mode)
    local root = M._create_node("root")
    local maps = vim.api.nvim_get_keymap(mode)
    -- print(vim.inspect(maps))

    for i, map in pairs(maps) do
        -- TODO: add special keymaps (<C>, <F1> etc)
        if not(string.find(map.lhs, "<")) then
            M._add_node(root, map.lhs)
        end
    end
    return root
end



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


local function create_buf(text)
    -- create new buf
    local buf_nr = vim.api.nvim_create_buf(false, true)
    print("BUFNR: " .. buf_nr)

    -- add text from table
    vim.api.nvim_buf_set_lines(buf_nr, 0, 1, false, text)
    return buf_nr
end


local function open_win(buf_nr)
    local win_id = vim.api.nvim_open_win(buf_nr, true, win_config())
    print("WIN: " .. win_id)
    return win_id
end


local function close_win(win_id, buf_nr)
    if vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)
        vim.api.nvim_buf_delete(buf_nr, {force = true})
    end
end


local win_open = false
local win_id = ""
local buf_nr = ""
function toggle_win()
    if win_open then
        -- close win
        print("close win")
        close_win(win_id, buf_nr)
        win_open = false
    else
        get_tree()
        -- create buf and open win
        print("create buf and open win")
        buf_nr = create_buf(M._buf_keys)
        win_id = open_win(buf_nr)
        win_open = true
        set_folding()
    end

end


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

function get_tree()
    table.insert(M._buf_keys, "Key-Tree")
    local tree = create_tree('n')
    -- print(vim.inspect(tree))

    display_tree(tree, 1)
end


function Folding(lnum)
    local current_indent = vim.fn.indent(lnum)
    local next_indent = vim.fn.indent(lnum + 1)

    -- increase indent to cover the next line
    if current_indent < next_indent then
        return "a1"
    end

    -- decrease indent to return to previous indenting
    if current_indent > next_indent then
        -- TODO: calculate space indenting
        local diff = (current_indent - next_indent) / 4
        return "s" .. diff
    end

    return "="
end


function FoldText()
    local fold_level = vim.v.foldlevel - 1
    -- TODO: calculate space indenting
    local space = string.rep(" ", fold_level * 4)
    return space .. '>' .. vim.fn.getline(vim.v.foldstart)
end


function set_folding()
    vim.o.foldmethod = "expr"
    vim.o.foldexpr = "v:lua.Folding(v:lnum)"
    vim.o.foldtext = "v:lua.FoldText()"

    -- remove trailing dots
    vim.cmd("set fillchars+=fold:\\ ")
end


return M
