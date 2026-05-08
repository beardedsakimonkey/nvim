local util = require'util'

local function update_userjs()
    vim.cmd(('botright new | terminal cd %s && ./updater.sh && ./prefsCleaner.sh')
        :format(se(util.FF_PROFILE)))
end

local function open_github_url()
    local ok, res = pcall(function()
        local function git(args, err)
            local out = vim.fn.system(vim.list_extend({'git'}, args))
            assert(vim.v.shell_error == 0, (err and err .. '\n' or '') .. out)
            return out:gsub('%s+$', '')
        end
        local remote = git({'remote', 'get-url', '--push', 'origin'}, 'Not in a git repo?')
                        :gsub('%.git$', '')
                        :gsub('^git@github%.com:', 'https://github.com/')
        local root = git({'rev-parse', '--show-toplevel'})
        local ref = git({'branch', '--show-current'})
        if ref == '' then
            ref = git({'rev-parse', 'HEAD'})
        end
        local fname = vim.fn.expand('%:p')
        local relpath = assert(vim.fs.relpath(root, fname),
            'Current file is not inside git root: ' .. fname)
        return remote .. '/blob/' .. ref .. '/' .. relpath
    end)
    if not ok then
        vim.notify(res, vim.log.levels.WARN)
    else
        vim.ui.open(res)
    end
end

local function restart_with_session()
    if vim.g.my_session and vim.g.MY_LAST_SESSION then
        vim.cmd('restart SLoad ' .. vim.g.MY_LAST_SESSION)
    end
    vim.cmd('restart')
end

com('FormatJSON', ':%!jq .')
com('StripTrailingSpace', '%s/\\s\\+$//e')
com('UpdateUserJs', update_userjs)
com('OpenGithubUrl', open_github_url)
com('Restart', restart_with_session)
com('TSPlayground', 'InspectTree')
