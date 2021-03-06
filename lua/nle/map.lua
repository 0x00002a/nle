local util = require('nle.util')
local fstore = require('nle.func-store')

local function iterate_mappings(mappings, fn, is_del)
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
            if is_del then -- skip argument processing if we're just deleting
                fn(modePrefix, m.seq)
            else
                local opts = m.opts or {}
                opts.noremap = ((opts.remap ~= nil) and not opts.remap) or true
                if type(m.act) == 'function' then
                    local fid = fstore.set(m.act)
                    m.act = '<cmd>' .. fstore.fmt_for_vim(fid) .. "<CR>"
                    if m.opts.silent == nil then -- default to silent
                        m.opts.silent = true
                    end
                end
                assert(m.seq, "sequence for keymap is nil")
                assert(m.act, "action for " .. m.seq .. " is nil")
                fn(modePrefix, m.seq, m.act, opts)
            end
        end
    end
end



local C = {}
C.buf = {}

function C.buf.add(bufnr, mappings)
    bufnr = bufnr or vim.fn.bufnr()
    iterate_mappings(mappings, util.bind(vim.api.nvim_buf_set_keymap, bufnr), false)
end

function C.buf.rm(bufnr, mappings)
    bufnr = bufnr or vim.fn.bufnr()
    iterate_mappings(mappings, util.bind(vim.api.nvim_buf_del_keymap, bufnr), true)
end

function C.add(mappings)
    iterate_mappings(mappings, vim.api.nvim_set_keymap, false)
end
function C.rm(mappings)
    iterate_mappings(mappings, vim.api.nvim_del_keymap, true)
end
return C
