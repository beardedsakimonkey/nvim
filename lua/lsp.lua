vim.diagnostic.config({
    signs = false,
    virtual_text = false,
})

com('LspLog', function() vim.cmd('tabnew ' .. vim.lsp.get_log_path()) end)
com('LspInfo', function() print(vim.inspect(vim.lsp.get_clients())) end)

local au = aug'my/lsp'

au('LspAttach', '*', function(args)
    local buf = args.buf
    -- The built-in on_attach handler sets this to use the lsp server. But this
    -- means we can't gq on comments. So reset it.
    -- Note that we *could* still get builtin formatting using gw.
    vim.bo[buf].formatexpr = ''

    vim.lsp.completion.enable(true, args.data.client_id, buf, { autotrigger = true })

    local function map(lhs, rhs)
        vim.keymap.set('n', lhs, rhs, {noremap = true, silent = true,
            buffer = buf})
    end
    vim.keymap.set('i', '<C-Space>', vim.lsp.completion.trigger, {buffer = buf})
    -- NOTE: Diagnostic mappings are in mappings.lua because they aren't
    -- necessarily associated with an lsp.
    map('gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>')
    map('gd', '<Cmd>lua vim.lsp.buf.definition()<CR>')
    map('gh', '<Cmd>lua vim.lsp.buf.hover()<CR>')
    map('gm', '<Cmd>lua vim.lsp.buf.implementation()<CR>')
    map('gs', '<Cmd>lua vim.lsp.buf.signature_help()<CR>')
    map('gt', '<Cmd>lua vim.lsp.buf.type_definition()<CR>')
    map('gr', '<Cmd>lua vim.lsp.buf.rename()<CR>')
    map('ga', '<Cmd>lua vim.lsp.buf.code_action()<CR>')
    map(',f', '<Cmd>lua vim.lsp.buf.format({async=true})<CR>')
end)

local definition_handler = function(...)
    vim.lsp.handlers['textDocument/definition'](...)
    vim.cmd 'norm! zz'
end

-- Disabling because goto definition jumps to header file.
-- https://github.com/clangd/clangd/issues/1348

-- vim.lsp.config('clangd', {
--     cmd = {'clangd'},
--     filetypes = {'c'},
--     root_markers = {'.clangd', '.clang-format', 'compile_commands.json', 'compile_flags.txt', 'configure.ac'},
--     capabilities = {
--         textDocument = {
--             completion = { editsNearCursor = true },
--         },
--         offsetEncoding = {'utf-8', 'utf-16'},
--     },
--     handlers = { ['textDocument/definition'] = definition_handler },
-- })
-- vim.lsp.enable('clangd')

-- vim.lsp.config('rls', {
--     cmd = {'rls'},
--     filetypes = {'rust'},
--     root_markers = {'Cargo.toml'},
--     handlers = { ['textDocument/definition'] = definition_handler },
-- })
-- vim.lsp.enable('rls')

vim.lsp.config('tsserver', {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = {'typescript', 'typescriptreact'},
    root_markers = {'tsconfig.json', 'package.json', '.git'},
    handlers = { ['textDocument/definition'] = definition_handler },
})
vim.lsp.enable('tsserver')
