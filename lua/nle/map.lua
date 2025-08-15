local util = require('nle.util')
local fstore = require('nle.func-store')

local has_keymap = vim.keymap ~= nil

local function iterate_mappings(mappings, fn, is_del, bufnr)
    local mode_lookup = {
        normal = 'n',
        insert = 'i',
        visual = 'v',
        all = '',
        command = 'c',
    }
    for mode, cfg in pairs(mappings) do
        local modePrefix = mode_lookup[mode]
        if modePrefix == nil then -- fallback to just the key
            modePrefix = tostring(mode)
        end
        for kh, mo in pairs(cfg) do
            local m = nil
            if type(mo) == 'function' or type(mo) == 'string' then -- allows: ['v'] = func
                m = { act = mo, opts = { silent = true } }
            elseif type(mo) == 'table' then
                m = vim.deepcopy(mo)
            else
                error("invalid type for map value: " .. type(mo))
            end
            if type(kh) == 'string' then
                m.seq = kh
            end
            local opts = m.opts or {}
            if bufnr ~= nil then
                opts.buffer = bufnr
            end
            if is_del then -- skip argument processing if we're just deleting
                fn(modePrefix, m.seq)
            else
                opts.noremap = ((opts.remap ~= nil) and not opts.remap) or true
                -- if we don't have keymap we have to fallback to the function store approach
                if not has_keymap then
                    if type(m.act) == 'function' then
                        local fid = fstore.set(m.act)
                        m.act = '<cmd>' .. fstore.fmt_for_vim(fid) .. "<CR>"
                        if m.opts.silent == nil then -- default to silent
                            m.opts.silent = true
                        end
                    end
                end
                assert(m.seq, "sequence for keymap is nil")
                assert(m.act, "action for " .. m.seq .. " is nil")
                fn(modePrefix, m.seq, m.act, opts)
            end
        end
    end
end



local C = { using_keymap = has_keymap }
C.buf = {}

function C.buf.add(bufnr, mappings)
    bufnr = bufnr or vim.fn.bufnr()
    local buf = nil
    local binding = util.bind(vim.api.nvim_buf_set_keymap, bufnr)
    if has_keymap then
        binding = vim.keymap.set
        buf = bufnr
    end

    iterate_mappings(mappings, binding, false, buf)
end

function C.buf.rm(bufnr, mappings)
    bufnr = bufnr or vim.fn.bufnr()
    local buf = nil
    local binding = util.bind(vim.api.nvim_buf_del_keymap, bufnr)
    if has_keymap then
        binding = vim.keymap.del
        buf = bufnr
    end
    iterate_mappings(mappings, binding, true, buf)
end

function C.add(mappings)
    local binding = vim.api.nvim_set_keymap
    if has_keymap then
        binding = vim.keymap.set
    end
    iterate_mappings(mappings, binding, false, nil)
end

function C.rm(mappings)
    local binding = vim.api.nvim_del_keymap
    if has_keymap then
        binding = vim.keymap.del
    end
    iterate_mappings(mappings, binding, true, nil)
end


return C
