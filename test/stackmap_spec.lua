local find_map = function(lhs)
    local maps = vim.api.nvim_get_keymap('n')
    for _, value in ipairs(maps) do
        if value.lhs == lhs then
            return value
        end
    end
end

describe("stackmap", function()
    before_each(function()
        require "stackmap"._clear()
        pcall(vim.keymap.del, "n", "testasdf")
    end)

    it("can be required", function()
        require("stackmap")
    end)

    it("can push a single mapping", function()
        local rhs = "echo 'This is a test'"
        require("stackmap").push("test1", "n", {
            ["testasdf"] = rhs,
        })

        local found = find_map("testasdf")
        assert.are.same(found.rhs, rhs)
    end)

    it("can delete mappings after pop: no existing", function()
        local rhs = "echo 'This is a test'"
        require("stackmap").push("test1", "n", {
            ["testasdf"] = rhs,
        })
        local found = find_map("testasdf")
        assert.are.same(rhs, found.rhs)

        require("stackmap").pop("test1")
        local after_pop = find_map("testasdf")
        assert.are.same(nil, after_pop)
    end)

    it("can delete mappings after pop: yes existing", function()
        local prev_rhs = "echo 'OG MAPPING'"
        vim.keymap.set('n', 'testasdf', prev_rhs)

        local rhs = "echo 'This is a test'"
        require("stackmap").push("test1", "n", {
            ["testasdf"] = rhs,
        })
        local found = find_map("testasdf")
        assert.are.same(rhs, found.rhs)

        require("stackmap").pop("test1")
        local after_pop = find_map("testasdf")
        assert.are.same(prev_rhs, after_pop.rhs)
    end)
end)
