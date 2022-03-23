local fstore = require('nle.func-store')
-- modified version of: https://gist.github.com/numToStr/1ab83dd2e919de9235f9f774ef8076da

local function autocmd(this, event, spec, buflocal)
    local is_tbl = type(spec) == 'table'
    local pattern = is_tbl and spec[1] or '*'
    local action = is_tbl and spec[2] or spec
    if type(action) == 'function' then
        action = this.fmt_for_vim(this.set(action))
    elseif type(action) == 'table' then
        for _, c in pairs(action) do
            autocmd(this, event, c)
        end
        return
    end
    local e = type(event) == 'table' and table.concat(event, ',') or event
    pattern = type(pattern) == 'table' and table.concat(pattern, ',') or pattern
    vim.cmd('autocmd ' .. e .. ' ' .. pattern .. ' ' .. action)
end

local M = {}

function M.group(grp, cmds)
    vim.cmd('augroup ' .. grp)
    vim.cmd('autocmd!')
    for name, au in pairs(cmds) do
        if type(name) ~= 'table' then
            name = {name}
        end
        for _, n in pairs(name) do
            autocmd(M, n, au, false)
        end
    end
    vim.cmd('augroup END')
end
M.buf = setmetatable({}, {
    __index = fstore,
    __newindex = function(this, event, spec) autocmd(this, event, spec, true) end,
    __call = function(this, event, spec) autocmd(this, event, spec, true) end,
})

return setmetatable(M, {
    __index = fstore,
    __newindex = function(this, event, spec) autocmd(this, event, spec, false) end,
    __call = function(this, event, spec) autocmd(this, event, spec, false) end,
})

