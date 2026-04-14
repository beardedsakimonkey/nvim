local _print = _G.print

-- Patch `print` to call vim.inspect on each table arg
_G.print = function(...)
    local args = {}
    local num_args = select('#', ...)
    -- Use for loop instead of `tbl_map` because `pairs` iteration stops at nil
    for i = 1, num_args do
        local arg = select(i, ...)
        if type(arg) == 'table' then
            table.insert(args, vim.inspect(arg))
        elseif type(arg) == 'nil' then
            table.insert(args, 'nil')  -- lest it be ignored
        else
            table.insert(args, arg)
        end
    end
    _print(unpack(args))
end

_G.fe = vim.fn.fnameescape
_G.se = vim.fn.shellescape

_G.com = function(name, command, opts)
    vim.api.nvim_create_user_command(name, command, opts or {})
end

_G.aug = function(group)
    vim.api.nvim_create_augroup(group, {})
    local function au(event, pattern, cmd, opts)
        opts = opts or {}
        opts.group = group
        opts.pattern = pattern
        if type(cmd) == 'string' then
            opts.command = cmd
        else
            opts.callback = cmd
        end
        vim.api.nvim_create_autocmd(event, opts)
    end
    return au
end

_G.map = vim.keymap.set

-- Convert snake_case to PascalCase
-- Ex: `:s/\w\+/\=v:lua.cc(submatch(0))/g`
_G.cc = function(str)
    return str:gsub('_(.)', function(match)
        return match:upper()
    end):gsub('^%l', function(match)
        return match:upper()
    end)
end
