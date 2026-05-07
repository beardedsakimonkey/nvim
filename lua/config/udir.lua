local udir = require'udir'

udir.config = vim.tbl_deep_extend('force', udir.config, {
    keymaps = {
        r = "<Cmd>lua require'udir.core'.move()<CR>",
        gh = "<Cmd>lua require'udir.core'.toggle_hidden_files()<CR>",
        L = "<Cmd>lcd %<CR>",
        ['<Tab>'] = "<Cmd>lua require'udir.core'.toggle_mark()<CR>",
    },
    is_file_hidden = function(file, files)
        return file.name == '.git'
    end,
    show_hidden_files = false,
    sync_local_cwd = true,
})

map('n', '-', '<Cmd>Udir<CR>')
