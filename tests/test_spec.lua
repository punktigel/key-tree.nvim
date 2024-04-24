require('plenary.test_harness')

describe("key-tree", function()
    before_each(function()
        require"key-tree"
    end)

    it("create root", function()
        local s = "Root"
        local res = require("key-tree.tree")._create_node(s)
        assert.are.same(res, {children={}, value=s})
    end)

    it("add node", function()
        local s = "Root"
        local root = require("key-tree.tree")._create_node(s)

        local lhs_mapping = "ab"
        local res = require("key-tree.tree")._add_mapping(root, lhs_mapping)
        assert.are.same(res, {children={{children={{children={}, value="b", info = "ab"}}, value="a", info = ""}}, value=s})
    end)
end)


