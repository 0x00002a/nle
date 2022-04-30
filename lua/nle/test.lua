local fstore = require('nle.func-store')
local Tests = {
    failed = false,
    cases = {},
}

local function test_unit(name, cases)
    Tests.cases[name] = cases
end

local function check_eq(lhs, rhs)
    if lhs ~= rhs then
        print("check failure: " .. tostring(lhs) .. " != " .. tostring(rhs))
        Tests.failed = true
    end
end

local function build_cmd_test_args(nargs, bang, cmd, repl)
    return string.format("command%s -nargs=%s %s %s", (bang and '!') or '', nargs, cmd, repl)
end

local cmd = require('nle.command')
test_unit("command", {
    ["cmd.build produces command!"] = function()
        local func = function() end
        local expected1 = build_cmd_test_args(0, false, 'TestCmd', fstore.fmt_for_vim_cmd(string.format("%p", func)))
        local vcmd = cmd.build('TestCmd', func)
        check_eq(vcmd, expected1)
        check_eq(cmd.build('TestCmd', { fn = func }), expected1)
    end,
    ["cmd.build with completion produces comp command"] = function()
        local f = function() end
        local expected1 = string.format("command -nargs=?")
    end
})
local vars = require('nle.variables')
test_unit('variables', {
    ['assigning var.g sets a global value'] = function()
        vars.g.testvar = 1
        check_eq(vim.api.nvim_eval('g:testvar'), 1)
    end,
    ['reading from an unset var returns nil'] = function()
        check_eq(vars.g.doesnotexist, nil)
    end,
    ['assigning to a value allows reading from it'] = function()
        vars.g.testvar2 = true
        check_eq(vars.g.testvar2, true)
    end,
    ['reading from a non-existent v:var results in nil'] = function()
        check_eq(vars.v.noneexist, nil)
    end,
})
local map = require('nle.map')
test_unit('map', {
    ['map can use string with function for mappings'] = function()
        local fired = false
        local mappings = {
            all = {
                ['j'] = function() fired = true end,
                ['k'] = {act = function() fired = true end, opts = {silent = true}},
            }
        }
        map.add(mappings)
        --vim.fn.feedkeys('j')
        vim.cmd[[normal j]]
        check_eq(fired, true)
        fired = false
        vim.cmd[[normal k]]
        check_eq(fired, true)
        map.rm(mappings)
    end,
    ['map can use string with function for mappings buflocal'] = function()
        local fired = false
        local mappings = {
            all = {
                ['j'] = function() fired = true end,
                ['k'] = {act = function() fired = true end, opts = {silent = true}},
            }
        }
        local bufnr = vim.fn.bufnr()
        map.buf.add(bufnr, mappings)
        --vim.fn.feedkeys('j')
        vim.cmd[[normal j]]
        check_eq(fired, true)
        fired = false
        vim.cmd[[normal k]]
        check_eq(fired, true)
        map.buf.rm(bufnr, mappings)
    end,
    ['map can use string with function for mappings buflocal with nil'] = function()
        local fired = false
        local mappings = {
            all = {
                ['j'] = function() fired = true end,
                ['k'] = {act = function() fired = true end, opts = {silent = true}},
            }
        }
        local bufnr = nil
        map.buf.add(bufnr, mappings)
        --vim.fn.feedkeys('j')
        vim.cmd[[normal j]]
        check_eq(fired, true)
        fired = false
        vim.cmd[[normal k]]
        check_eq(fired, true)
        map.buf.rm(bufnr, mappings)
    end,

    ['map can use string with function for mappings buflocal with nil fn'] = function()
        local function withkey(k)
            local bufnr = vim.fn.bufnr()
            local ok, _ = pcall(map.buf.add, bufnr, k)
            check_eq(ok, false)
        end
        withkey({ all = { ['m'] = nil } })
        withkey({ all = { {seq = 'm', act = nil} } })
    end,
}
)

function Tests.run_all()
    for k, v in pairs(Tests.cases) do
        for name, case in pairs(v) do
            case()
            if Tests.failed then
                print(k .. "/" .. name .. " failed")
                return
            end
        end
    end
    print("all tests passed")
end

return Tests

