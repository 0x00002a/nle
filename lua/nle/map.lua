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
        for _, m in pairs(cfg) do
            if is_del then -- skip argument processing if we're just deleting
                fn(modePrefix, m.seq)
            else
                local opts = m.opts
                if opts == nil then
                    opts = {}
                end
                local act = m.act
                if type(act) == 'function' then
                    local fid = fstore.set(act)
                    act = ':' .. fstore.fmt_for_vim(fid) .. "<CR>"
                end
                fn(modePrefix, m.seq, act, opts)
            end
        end
    end
end



local C = {}
C.buf = {}

function C.buf.add(bufnr, mappings)
    iterate_mappings(mappings, util.bind(vim.api.nvim_buf_set_keymap, bufnr), false)
end

function C.buf.rm(bufnr, mappings)
    iterate_mappings(mappings, util.bind(vim.api.nvim_buf_del_keymap, bufnr), true)
end

function C.add(mappings)
    iterate_mappings(mappings, vim.api.nvim_set_keymap, false)
end
function C.rm(mappings)
    iterate_mappings(mappings, vim.api.nvim_del_keymap, true)
end
return C
