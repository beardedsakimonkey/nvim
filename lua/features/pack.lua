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

com('PackUpdate', function() vim.pack.update(nil, { force = true }) end)
com('PackList',   function() vim.pack.update(nil, { offline = true }) end)
com('PackClean',  pack_clean)

map('n', '<space>pu', '<Cmd>PackUpdate<CR>')
map('n', '<space>pl', '<Cmd>PackList<CR>')
map('n', '<space>pc', '<Cmd>PackClean<CR>')
