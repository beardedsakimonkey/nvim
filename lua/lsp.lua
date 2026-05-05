vim.diagnostic.config({
    signs = false,
    virtual_text = false,
})

com('LspLog', function() vim.cmd('tabnew ' .. vim.lsp.get_log_path()) end)

local au = aug'my/lsp'

au('LspAttach', '*', function(args)
    local buf = args.buf
    -- The built-in on_attach handler sets this to use the lsp server. But this
    -- means we can't gq on comments. So reset it.
    -- Note that we *could* still get builtin formatting using gw.
    vim.bo[buf].formatexpr = ''

    local function map(lhs, rhs)
        vim.keymap.set('n', lhs, rhs, {noremap = true, silent = true,
            buffer = buf})
    end
    vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', {buffer = buf})
    map('gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>')
    map('gd', '<Cmd>lua vim.lsp.buf.definition()<CR>')
    map('gh', '<Cmd>lua vim.lsp.buf.hover()<CR>')
    map('gm', '<Cmd>lua vim.lsp.buf.implementation()<CR>')
    map('gs', '<Cmd>lua vim.lsp.buf.signature_help()<CR>')
    map('gt', '<Cmd>lua vim.lsp.buf.type_definition()<CR>')
    map('gr', '<Cmd>lua vim.lsp.buf.rename()<CR>')
    map('ga', '<Cmd>lua vim.lsp.buf.code_action()<CR>')
    map(',f', '<Cmd>lua vim.lsp.buf.format({async=true})<CR>')

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client:supports_method('textDocument/completion') then
        vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
end)


local definition_handler = function(...)
    vim.lsp.handlers['textDocument/definition'](...)
    vim.cmd 'norm! zz'
end

vim.lsp.config('tsserver', {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = {'typescript', 'typescriptreact'},
    root_markers = {'tsconfig.json', 'package.json', '.git'},
    handlers = { ['textDocument/definition'] = definition_handler },
})
vim.lsp.enable('tsserver')
