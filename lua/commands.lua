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

local function restart_with_session(opts)
    local cmd = 'restart'
    local session = vim.g.MY_LAST_SESSION
    if session and session ~= '' then
        cmd = cmd .. ' SLoad ' .. session
    end
    vim.cmd(cmd)
end

com('FormatJSON', ':%!jq .')

com('UpdateUserJs', update_userjs)
com('OpenGithubUrl', open_github_url)
com('StripTrailingSpace', '%s/\\s\\+$//e')
com('Restart', restart_with_session, { nargs = '*' })
