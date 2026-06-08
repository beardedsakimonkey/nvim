local picky = require('picky')

picky.setup({
    window = {
        border = 'single',
    },
    keymaps = {
        ['<C-l>'] = 'vsplit',
    },
})

map('n', '<space>o', function()
    picky.open({
        source = picky.sources.oldfiles(),
    })
end)

map('n', '<space>b', function()
    picky.open({
        source = picky.sources.buffers(),
        keymaps = {
            ['<C-d>'] = function(ctx)
                for _, item in ipairs(ctx.targets) do
                    vim.api.nvim_buf_delete(item.bufnr, {})
                end
                ctx.refresh()
            end,
        },
    })
end)

map('n', '<space>f', function()
    picky.open({
        source = picky.sources.files({
            live = true,
            limit = 100,
        }),
    })
end)

map('n', '<space>h', function()
    picky.open({
        source = picky.sources.help({
            live = true,
        }),
    })
end)

-- Grep -----------------------------------------------------------------------

local function absolute_path(cwd, path)
    if vim.fn.isabsolutepath(path) == 1 then
        return path
    end
    return vim.fs.joinpath(cwd, path)
end

local function open_grep_targets(action)
    return function(ctx)
        if #ctx.targets == 1 then
            picky.actions[action](ctx)
            return
        end

        local items = vim.tbl_map(function(item)
            return {
                filename = absolute_path(ctx.cwd, item.path),
                text = item.text,
                lnum = item.lnum,
                col = item.col,
            }
        end, ctx.targets)

        ctx.close()
        vim.fn.setqflist({}, ' ', {
            nr = '$',
            items = items,
        })
        vim.cmd(action)
        vim.cmd.copen()
        vim.cmd('cc!')
    end
end

local grep_keymaps = {
    ['<CR>'] = open_grep_targets('edit'),
    ['<C-s>'] = open_grep_targets('split'),
    ['<C-l>'] = open_grep_targets('vsplit'),
    ['<C-t>'] = open_grep_targets('tabedit'),
}

local function exists(path)
    return vim.uv.fs_access(path, '') == true
end

local function grep(query, parts)
    parts = vim.deepcopy(parts)
    local paths

    if #parts > 1 and exists(parts[#parts]) then
        paths = { table.remove(parts) }
        query = table.concat(parts, ' ')
    end

    picky.open({
        source = picky.sources.grep({
            pattern = query,
            paths = paths,
        }),
        keymaps = grep_keymaps,
    })
end

com('Grep', function(o) grep(o.args, o.fargs) end, { nargs = '+' })
map('x', '<space>a', '"vy:Grep <C-r>v<CR>')
map('n', '<space>a', ':<C-u>Grep ')
