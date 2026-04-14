local util = require'util'

local function update_userjs()
    vim.cmd(('botright new | terminal cd %s && ./updater.sh && ./prefsCleaner.sh')
        :format(se(util.FF_PROFILE)))
end

local function github_url()
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
        print(res)
    end
end

com('Scratch', 'call my#scratch(<q-args>, <q-mods>)',
    {nargs = 1, complete = 'command'})
com('Messages', '<mods> Scratch messages', {nargs = 0})
com('Marks', '<mods> Scratch marks <args>', {nargs = '?'})
com('Highlight', '<mods> Scratch highlight <args>',
    {nargs = '?', complete = 'highlight'})
com('Jumps', '<mods> Scratch jumps', {nargs = 0})
com('Scriptnames', '<mods> Scratch scriptnames', {nargs = 0})

com('UpdateUserJs', update_userjs)
com('GithubUrl', github_url)
com('StripTrailingSpace', '%s/\\s\\+$//e')
