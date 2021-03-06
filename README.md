# Natomic's Lua Extensions (for Neovim)

Collection of lua utilities for neovim configuration, mostly wrappers for vim stuff which isn't (or wasn't as of 0.6) in neovim.

## autocmd wrapper

> nle.autocmd

```lua
local au = require('nle.autocmd')
au.BufEnter = {'*', {'some action', function() dothing end}}
au.BufLeave = 'some action'
au.BufLeave = function() dothing end
```

## command wrapper

> nle.command

```lua
local cmd = require('nle.command')
cmd.add('MyCmd', function() dothing end)
cmd.add('MyCmdWithArg', function(arg) dothing end)
cmd.add('MyCmdWithDirComp', { fn = function() dothing end, args = { complete = 'dir' } })
cmd.rm('MyCmd')
```

`nargs` is calculated from the number of arguments of the function object, if it is varadic it uses `*`

## keymap wrapper

> nle.map

```lua
local map = require('nle.map')
local mappings = {
    normal = {
        { seq = '<CR>', act = function() dothing end, opts = { silent = true }}, -- nnoremap <silent> <CR> <cmd>lua dothing<CR>
        { seq = '<C-m>', act = 'vim command', opts = { remap = true }}, -- nmap <C-m> vim command
        ["<C-j>"] = function() dothing end, -- nnoremap <silent> <C-j> <cmd>lua dothing<CR>
    }
}

map.add(mappings)
map.buf.add(vim.fn.bufnr(), mappings)
```


## highlight wrapper

> nle.highlight

```lua
local hi = require('nle.highlight')
hi.Cursor = { blend = 100, gui = 'reverse' }
```

## variable wrapper

> nle.variables
```lua
local vars = require('nle.variables')
vars.g.myvar = 2
if vars.g.somevar then
end
if vars.g.somevar2 == nil then -- nil if doesn't exist
end
```

## func-store

This is used to provide storage for lua functions to be called from vimscript. The basic usage is to call
`require('nle.func-store').exec(<some id>)` where `<some id>` is the value returned from `func-store.set(...)`.







