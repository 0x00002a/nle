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
    end
})

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

