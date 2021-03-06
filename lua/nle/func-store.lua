-- Stores lua functions for use in vimscript callbacks

local S = {
    __fn = {}
}

function S.exec(id, ...)
    S.__fn[id](...)
end
function S.set(fn)
    local id = string.format("%p", fn)
    S.__fn[id] = fn
    return id
end

function S.fmt_for_vim(id)
    return string.format("lua require('nle.func-store').exec('%s')", id)
end

function S.fmt_for_vim_cmd(id, has_args)
    return string.format("lua require('nle.func-store').exec('%s'%s)", id, (has_args and ',<f-args>') or '')
end

return S

