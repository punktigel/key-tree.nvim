# key-tree.nvim

This plugin creates a tree of nvim keymaps. This tree can be displayed in a floating window.


## Usage

Recommended setup:

```lua
local keytree = require("key-tree")

vim.keymap.set('n', '<leader>tkt', function() keytree.toggle_win() end, { desc = "[T]oggle [K]ey-[T]ree"})
```


## Documentation

See `:help key-tree.nvim`
