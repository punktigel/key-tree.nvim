local folding = {}

--- Calculate folding level based on indenting
---@param lnum any
---@return string
function Folding_level(lnum)
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


--- Format folds
---@return unknown
function Fold_text()
    local fold_level = vim.v.foldlevel - 1
    -- TODO: calculate space indenting
    local space = string.rep(" ", fold_level * 4)
    local fold_childs = vim.v.foldend - vim.v.foldstart
    return space .. '>' .. vim.fn.getline(vim.v.foldstart) .. "\t[" .. fold_childs .. "]"
end


--- Set folding on the current buffer
function folding.set_folding()
    vim.o.foldmethod = "expr"
    vim.o.foldexpr = "v:lua.Folding_level(v:lnum)"
    vim.o.foldtext = "v:lua.Fold_text()"

    -- remove trailing dots
    vim.cmd("set fillchars+=fold:\\ ")
    -- remove end-of-buffer symbols (~)
    vim.opt.fillchars:append { eob = " " }
end


return folding
