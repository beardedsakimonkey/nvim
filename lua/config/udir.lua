local udir = require'udir'

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
        L = "<Cmd>lcd %<CR>",
        ['<Tab>'] = "<Cmd>lua require'udir.core'.toggle_mark()<CR>",
    },
    is_file_hidden = function(file, files)
        return file.name == '.git'
    end,
    show_hidden_files = false,
    sync_local_cwd = true,
}

map('n', '-', '<Cmd>Udir<CR>')
