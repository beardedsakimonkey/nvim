local dora = require'dora'

dora.config = vim.tbl_deep_extend('force', dora.config, {
    keymaps = {
    },
})

map('n', '-', '<Cmd>Dora<CR>')
