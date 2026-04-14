local udir = require'udir'

local function cd(cmd)
    local state = require'udir.store'.get()
    vim.cmd(cmd .. ' ' .. vim.fn.fnameescape(state.cwd))
    vim.cmd 'pwd'
end

local function sort_by_mtime(files)
    local cwd = require'udir.store'.cwd
    local mtimes = {}
    for _, file in ipairs(files) do
        --`fs_stat` fails in case of a broken symlink
        local fstat = vim.loop.fs_stat(cwd .. '/' .. file.name)
        mtimes[file.name] = fstat and fstat.mtime.sec or 0
    end
    table.sort(files, function(a, b)
        if (a.type == 'directory') == (b.type == 'directory') then
            return mtimes[a.name] > mtimes[b.name]
        else
            return a.type == 'directory'
        end
    end)
end

local function toggle_sort()
    udir.config.sort = udir.config.sort ~= sort_by_mtime and sort_by_mtime or nil
    require'udir.core'.reload()
end

udir.config = {
    keymaps = {
        q = "<Cmd>lua require'udir.core'.quit()<CR>",
        h = "<Cmd>lua require'udir.core'.up_dir()<CR>",
        ['-'] = "<Cmd>lua require'udir.core'.up_dir()<CR>",
        l = "<Cmd>lua require'udir.core'.open()<CR>",
        i = "<Cmd>lua require'udir.core'.open()<CR>",
        ['<CR>'] = "<Cmd>lua require'udir.core'.open()<CR>",
        s = "<Cmd>lua require'udir.core'.open('split')<CR>",
        v = "<Cmd>lua require'udir.core'.open('vsplit')<CR>",
        t = "<Cmd>lua require'udir.core'.open('tabedit')<CR>",
        R = "<Cmd>lua require'udir.core'.reload()<CR>",
        d = "<Cmd>lua require'udir.core'.delete()<CR>",
        ['+'] = "<Cmd>lua require'udir.core'.create()<CR>",
        m = "<Cmd>lua require'udir.core'.move()<CR>",
        r = "<Cmd>lua require'udir.core'.move()<CR>",
        c = "<Cmd>lua require'udir.core'.copy()<CR>",
        gh = "<Cmd>lua require'udir.core'.toggle_hidden_files()<CR>",
        T = toggle_sort,
        C = function() cd 'cd' end,
        L = function() cd 'lcd' end,
    },
    is_file_hidden = function(file, files)
        return false
        -- return vim.endswith(file.name, '.o')
        --     or file.name == '.git'
    end,
    show_hidden_files = false,
}

map('n', '-', '<Cmd>Udir<CR>')
