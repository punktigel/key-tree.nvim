require('plenary.test_harness')

describe("key-tree", function()
    before_each(function()
        require"key-tree"
    end)

    it("create root", function()
        local s = "Root"
        local res = require("key-tree")._create_node(s)
        assert.are.same(res, {children={}, value=s})
    end)

    it("add node", function()
        local s = "Root"
        local root = require("key-tree")._create_node(s)

        local node_s = "ab"
        local res = require("key-tree")._add_node(root, node_s)
        assert.are.same(res, {children={{children={{children={}, value="b"}}, value="a"}}, value=s})
    end)
end)


