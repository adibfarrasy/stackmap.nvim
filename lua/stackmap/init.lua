local M = {}

-- M.setup = function(opts)
--     print("Options:", opts)
-- end

-- functions we need:
-- - v.keymap.set(...) -> create new keymaps
-- - v.api.nvim_get_keymap

local find_mapping = function(maps, lhs)
    -- pairs
    --      iterates over every key
    --      order not guaranteed
    -- ipairs
    --      iterates over only numeric keys in a table
    --      order is guaranteed
    for _, value in ipairs(maps) do
        if value.lhs == lhs then
            return value
        end
    end
end

M._stack = {}

M.push = function(name, mode, mappings)
    local maps = vim.api.nvim_get_keymap(mode)

    local existing_maps = {}
    for lhs, _ in pairs(mappings) do
        local existing = find_mapping(maps, lhs)
        if existing then
            existing_maps[lhs] = existing
        end
    end

    -- P(maps)
    M._stack[name] = {
        mode = mode,
        existing = existing_maps,
        mappings = mappings,
    }

    for lhs, rhs in pairs(mappings) do
        vim.keymap.set(mode, lhs, rhs)
    end
end

--[[
lua require("mapstack").pop("debug_mode")
--]]
M.pop = function(name)
    local state = M._stack[name]
    for lhs, _ in pairs(state.mappings) do
        if state.existing[lhs] then
            -- handle mappings that existed
            local og_mapping = state.existing[lhs]

            vim.keymap.set(state.mode, lhs, og_mapping.rhs)
        else
            -- handle mappings that didn't exist
            vim.keymap.del(state.mode, lhs)
        end
    end

    M._stack[name] = nil
end

M._clear = function()
    M._stack = {}
end

-- M.push("debug_mode", "n", {
--     [" ff"] = "echo 'Overwrite keymap'",
--     [" sz"] = "echo 'New keymap'",
-- })

return M
