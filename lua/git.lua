local M = {}

local function get_repo_root(path)
    local git_dir = vim.fs.find('.git', {
        path = vim.fs.dirname(path),
        upward = true,
    })[1]
    if not git_dir then
        return nil
    end
    return vim.fs.dirname(git_dir)
end

local function read_head_file(root, relpath)
    local out = vim.fn.system({
        'git',
        '-C',
        root,
        'show',
        '--no-ext-diff',
        '--text',
        'HEAD:' .. relpath,
    })
    if vim.v.shell_error ~= 0 then
        return {}
    end
    -- `git show` preserves the file's terminal newline; Neovim buffer lines do not.
    return vim.split(out, '\n', { plain = true, trimempty = true })
end

local function git_diff()
    local bufnr = vim.api.nvim_get_current_buf()
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path == '' then
        vim.notify('GitDiff requires a file-backed buffer', vim.log.levels.WARN)
        return
    end

    local root = get_repo_root(path)
    if not root then
        vim.notify('GitDiff requires a git repository', vim.log.levels.WARN)
        return
    end

    local relpath = path:sub(#root + 2)
    local head_lines = read_head_file(root, relpath)
    local ft = vim.bo[bufnr].filetype

    local current_win = vim.api.nvim_get_current_win()
    vim.cmd('botright vert new')
    local diff_win = vim.api.nvim_get_current_win()
    local diff_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(diff_win, diff_buf)

    vim.bo[diff_buf].bufhidden = 'wipe'
    vim.bo[diff_buf].buftype = 'nofile'
    vim.bo[diff_buf].swapfile = false
    vim.bo[diff_buf].modifiable = true
    vim.bo[diff_buf].readonly = false
    vim.bo[diff_buf].filetype = ft
    vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, head_lines)
    vim.bo[diff_buf].modifiable = false
    vim.bo[diff_buf].readonly = true
    vim.api.nvim_buf_set_name(diff_buf, ('[GitDiff HEAD] %s'):format(relpath))

    vim.cmd('diffthis')
    vim.api.nvim_set_current_win(current_win)
    vim.cmd('diffthis')
    vim.api.nvim_set_current_win(current_win)
end

com('GitDiff', git_diff, { desc = 'Open a diff view against HEAD' })
map('n', '<space>gd', '<Cmd>GitDiff<CR>', { silent = true })

return M
