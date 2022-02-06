
local function get_var(name)
    if vim.api.nvim_eval(string.format("exists('%s')", name)) == 1 then
        return vim.api.nvim_eval(name)
    else
        return nil
    end
end

local C = {}


C.g = setmetatable({}, {
    __index = function(_, name)
        return get_var('g:' .. name)
    end,
    __newindex = function(_, name, v)
        vim.api.nvim_set_var(name, v)
    end
})

C.v = setmetatable({},{
    __index = function(_, name)
        return get_var('v:' .. name)
    end,
    __newindex = function(_, name, v)
        vim.api.nvim_set_vvar(name, v)
    end
})

return C


