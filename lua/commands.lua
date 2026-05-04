local util = require'util'

local function update_userjs()
    vim.cmd(('botright new | terminal cd %s && ./updater.sh && ./prefsCleaner.sh')
        :format(se(util.FF_PROFILE)))
end

local function open_github_url()
    local ok, res = pcall(function()
        local remote_out = vim.fn.system('git remote get-url --push origin')
        assert(vim.v.shell_error == 0, 'Not in a git repo?\n' .. remote_out)
        local remote = remote_out
                        :gsub('\n$', '')
                        :gsub('.git$', '')
                        :gsub('^git@github%.com:', 'https://github.com/')
        local root = vim.fs.find('.git', {upward = true, type = 'directory'})[1]
        local root_len = #root - 3 -- exclude trailing ".git"
        local branch = vim.fn.system('git branch --show-current'):match('%S+')
        return remote .. '/blob/' .. branch .. '/'
            .. vim.fn.expand('%:p'):sub(root_len)
    end)
    if not ok then
        vim.notify(res, vim.log.levels.WARN)
    else
        vim.ui.open(res)
    end
end

com('Scratch', 'call my#scratch(<q-args>, <q-mods>)', {nargs = 1, complete = 'command'})
com('Messages', '<mods> Scratch messages', {nargs = 0})
com('Marks', '<mods> Scratch marks <args>', {nargs = '?'})
com('Highlight', '<mods> Scratch highlight <args>', {nargs = '?', complete = 'highlight'})
com('Jumps', '<mods> Scratch jumps', {nargs = 0})
com('Scriptnames', '<mods> Scratch scriptnames', {nargs = 0})

com('FormatJSON', ':%!jq .')

com('UpdateUserJs', update_userjs)
com('OpenGithubUrl', open_github_url)
com('StripTrailingSpace', '%s/\\s\\+$//e')

-- vim.pack -------------------------------------------------------------
com('PackUpdate', function(opts)
    if opts.args == '' then -- update all
        vim.pack.update()
    else -- update specific plugins
        local plugins = vim.split(opts.args, '%s+', { trimempty = true })
        vim.pack.update(plugins)
    end
end, { nargs = '*' })


com('PackClean', function()
    local non_active = vim.iter(vim.pack.get())
    :filter(function(p) return not p.active end)
    :map(function(p) return p.spec.name end)
    :totable()

    if #non_active == 0 then
        vim.notify('No inactive plugins found', vim.log.levels.INFO)
        return
    end

    vim.api.nvim_echo({
        { "Inactive plugins found:\n", "Title" },
        { " • " .. table.concat(non_active, '\n • ') .. "\n", "WarningMsg" }
    }, true, {})

    vim.ui.input({
        prompt = 'Delete these ' .. #non_active .. ' plugins? (y/N): '
    }, function(input)
        if input and input:lower() == 'y' then
            vim.pack.del(non_active)
            vim.notify('\nSuccessfully deleted ' .. #non_active .. ' plugin(s)', vim.log.levels.INFO)
            vim.api.nvim_exec_autocmds('User', { pattern = 'PackChanged' })
        end
    end)
end, {})
