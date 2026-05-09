local dirtree = require'dirtree'

dirtree.config = vim.tbl_deep_extend('force', dirtree.config, {
    keymaps = {
        r = "<Cmd>lua require'dirtree.core'.move()<CR>",
        H = {"<Cmd>lua require'dirtree.core'.help()<CR>", desc="Open Help"},
        gh = "<Cmd>lua require'dirtree.core'.toggle_hidden_files()<CR>",
    },
})

map('n', '-', '<Cmd>Dirtree<CR>')
