local folding = {}

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


function folding.set_folding()
    vim.o.foldmethod = "expr"
    vim.o.foldexpr = "v:lua.Folding(v:lnum)"
    vim.o.foldtext = "v:lua.FoldText()"

    -- remove trailing dots
    vim.cmd("set fillchars+=fold:\\ ")
end


return folding
