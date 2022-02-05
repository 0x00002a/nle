local fstore = require('nle.func-store')
--[[
-- Example spec:
-- {
--  fn = ...,
--  args = ...
-- }
--
--
--]]

local function args_to_vim(fargs)
    local out = ""
    for ak, av in pairs(fargs) do
        out = out .. "-" .. ak .. "=" .. av .. " "
    end
    return out
end

local function process_spec(spec)
    if type(spec) == 'table' then
        if spec.fn then
            local args, repl = process_spec(spec.fn)
            return args_to_vim(spec.args or {}) .. args, repl
        end
    elseif type(spec) == 'function' then
        local info = debug.getinfo(spec)
        local nb_args = (function()
            if info.isvararg then
                return '*'
            else
                return tostring(info.nparams)
            end
        end)()
        local fid = fstore.set(spec)

        return args_to_vim({ nargs = nb_args }), fstore.fmt_for_vim_cmd(fid, info.isvararg or (info.nparams > 0))
    end
end

local function add_cmd(name, spec)
    local args, repl = process_spec(spec)
    local bang = type(spec) == 'table' and spec.bang
    return string.format("command%s %s%s %s", (bang and '!') or '', args, name, repl)
end


local M = {}

function M.build(name, spec)
    return add_cmd(name, spec)
end
function M.add(name, spec)
    vim.cmd(M.build(name, spec))
end
function M.rm(name)
    vim.cmd("delcommand " .. name)
end



return M
