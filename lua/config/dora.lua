local dora = require'dora'

dora.config = vim.tbl_deep_extend('force', dora.config, {
    keymaps = {
        ['<tab>'] = "next_sibling",
        ['<s-tab>'] = "prev_sibling",
    },
})

map('n', '-', '<Cmd>Dora<CR>')
