local C = {}
function C.bind(f, ...)
    local bound = {...}
    return function(...)
        local args = {}
        for i = 1, #bound do
            args[i] = bound[i]
        end
        for i = 1, select('#', ...) do
            args[#args+1] = select(i, ...)
        end
        return f(unpack(args))
    end
end

return C
