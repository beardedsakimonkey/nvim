local util = require'util'

local function handle_large_buffer()
    local size = vim.fn.getfsize(vim.fn.expand'<afile>')
    if size > (1024 * 1024) or size == -2 then
        vim.cmd 'syntax clear'
    end
end

local function setup_formatoptions()
    vim.opt.fo = vim.opt.fo
        + 'j' -- remove comment leader joining lines
        + 'c' -- auto-wrap comments
    local amatch = vim.fn.expand'<amatch>'
    if amatch ~= 'markdown' and amatch ~= 'gitcommit' then
        vim.opt.fo = vim.opt.fo - 't'  -- don't auto-wrap text
    end
    vim.opt.fo = vim.opt.fo - 'o'  -- don't auto-insert comment leader on 'o'
end

local function source_lua()
    local name = vim.fn.expand'<afile>:p'
    if vim.startswith(name, vim.fn.stdpath'config')
        and not name:match('after/ftplugin') then
        vim.cmd('luafile ' .. fe(name))
    end
end

local function source_tmux()
    vim.fn.system('tmux source-file ' .. se(vim.fn.expand'<afile>:p'))
end

local function update_user_js()
    local cmd = util.FF_PROFILE .. 'updater.sh'
    vim.uv.spawn(cmd, {args = {'-d', '-s', '-b'}}, function(exit)
        print(exit == 0 and 'Updated user.js' or ('exited nonzero: ' .. exit))
    end)
end

local function fast_theme()
    local zsh = os.getenv'HOME'
        .. '/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh'
    if util.exists(zsh) then
        local out = vim.fn.system('source ' .. zsh .. ' && fast-theme '
            .. vim.fn.expand'<afile>:p')
        if vim.v.shell_error ~= 0 then
            vim.api.nvim_err_writeln(out)
        end
    else
        vim.api.nvim_err_writeln('zsh script not found')
    end
end

local function set_diagnostic_undercurl()
    local function hl(name)
        vim.api.nvim_set_hl(0, name, {undercurl = true, update = true})
    end
    hl('DiagnosticUnderlineError')
    hl('DiagnosticUnderlineWarn')
    hl('DiagnosticUnderlineInfo')
    hl('DiagnosticUnderlineHint')
    hl('DiagnosticUnderlineOk')
end

local au = aug'my/autocmds'
au('BufReadPre', '*', handle_large_buffer)
au('BufRead', {'.bash_history', '.zsh_history'}, 'setlocal noundofile')
au('FileType', '*', setup_formatoptions)
au('BufWritePost', '*.lua', source_lua)
au('BufWritePost', '*/.config/nvim/plugin/*.vim', 'source <afile>:p')
au('BufWritePost', '*tmux.conf', source_tmux)
au('BufWritePost', 'user-overrides.js', update_user_js)
au('BufWritePost', '*/.zsh/overlay.ini', fast_theme)
au('VimResized', '*', 'wincmd =')
au({'FocusGained', 'BufEnter'}, '*', 'checktime')
au('TextYankPost', '*', function() vim.highlight.on_yank{on_visual = false} end)
au('ColorScheme', '*', set_diagnostic_undercurl)
