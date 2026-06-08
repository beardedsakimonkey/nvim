local pinned = {}

local function get_inactive_plugins()
    return vim.iter(vim.pack.get())
        :filter(function(p) return not p.active end)
        :map(function(p) return p.spec.name end)
        :totable()
end

local function pack_clean()
    local inactive = get_inactive_plugins()
    if #inactive == 0 then
        vim.notify('No inactive plugins.', vim.log.levels.INFO)
        return
    end

    vim.api.nvim_echo({
        { "Inactive plugins found:\n", "Title" },
        { " • " .. table.concat(inactive, '\n • ') .. "\n", "WarningMsg" }
    }, true, {})

    vim.ui.input({
        prompt = 'Delete these ' .. #inactive .. ' plugins? (y/N): '
    }, function(input)
        if input and input:lower() == 'y' then
            vim.pack.del(inactive)
            vim.notify('\nSuccessfully deleted ' .. #inactive .. ' plugin(s)', vim.log.levels.INFO)
            vim.api.nvim_exec_autocmds('User', { pattern = 'PackChanged' })
        end
    end)
end

local function update_unpinned(opts)
    local names = vim.iter(vim.pack.get(nil, {info = false}))
        :filter(function(plugin) return not pinned[plugin.spec.name] end)
        :map(function(plugin) return plugin.spec.name end)
        :totable()
    vim.pack.update(names, opts)
end

com('PackUpdate', function() update_unpinned({force = true}) end)
com('PackList',   function() update_unpinned({offline = true}) end)
com('PackClean',  pack_clean)

map('n', '<space>pu', '<Cmd>PackUpdate<CR>')
map('n', '<space>pl', '<Cmd>PackList<CR>')
map('n', '<space>pc', '<Cmd>PackClean<CR>')

local M = {}

local function expand_src(src)
    if src:match('^[%w_.-]+/[%w_.-]+$') then
        return 'https://github.com/' .. src
    end
    return src
end

function M.add(specs)
    local expanded_specs = vim.iter(ipairs(specs)):map(function(index, spec)
        if type(spec) == 'string' then
            local src = expand_src(spec)
            pinned[vim.fs.basename(src):gsub('%.git$', '')] = true
            return src
        end

        local src = spec.src or spec[1]
        vim.validate(('specs[%d].src'):format(index), src, 'string')
        local expanded = vim.tbl_extend('force', spec, {src = expand_src(src)})
        expanded[1] = nil
        if expanded.version == nil and expanded.pin ~= false then
            local name = expanded.name or vim.fs.basename(expanded.src):gsub('%.git$', '')
            pinned[name] = true
        end
        expanded.pin = nil
        return expanded
    end):totable()

    local ok, err = xpcall(function() vim.pack.add(expanded_specs) end, debug.traceback)
    if not ok then
        -- fallback to :packadd
        for _, spec in ipairs(expanded_specs) do
            local src = type(spec) == 'string' and spec or spec.src
            local name = vim.fs.basename(src):gsub('%.git$', '')
            pcall(vim.cmd.packadd, {args = {name}, bang = true})
        end
        vim.notify(err, vim.log.levels.ERROR, {title = 'vim.pack.add'})
    end
end

return M
