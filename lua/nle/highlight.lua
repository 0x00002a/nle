
local function add_hi(_, group, spec)
    local args = ""
    for ak, av in pairs(spec) do
        args = args .. ak .. "=" .. av .. " "
    end
    vim.cmd("hi " .. group .. " " .. args)
end

local H = {}
local M = setmetatable({}, {
    __index = H,
    __newindex = add_hi,
    __call = add_hi,
})

return M

