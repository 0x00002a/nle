-- modified version of: https://gist.github.com/numToStr/1ab83dd2e919de9235f9f774ef8076da

local function autocmd(this, event, spec)
    local is_tbl = type(spec) == 'table'
    local pattern = is_tbl and spec[1] or '*'
    local action = is_tbl and spec[2] or spec
    if type(action) == 'function' then
        action = this.set(action)
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

local S = {
    __au = {}
}

local M = setmetatable({}, {
    __index = S,
    __newindex = autocmd,
    __call = autocmd,
})

function S.exec(id)
    S.__au[id]()
end

function S.set(cmd)
    local fn = cmd
    local id = string.format("%p", fn)
    S.__au[id] = fn
    return string.format('lua require("autocmd").exec("%s")', id)
end


function S.group(grp, cmds)
    vim.cmd('augroup' .. grp)
    vim.cmd('autocmd!')
    if type(cmds) == 'function' then
        cmds(M)
    else
        for _, au in ipairs(cmds) do
           autocmd(S, au[1], {au[2], au[3]})
        end
    end
end

return M

