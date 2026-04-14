vim.diagnostic.config({
    signs = false,
    virtual_text = false,
})

com('LspLog', function() vim.cmd('tabnew ' .. vim.lsp.get_log_path()) end)
com('LspInfo', function() print(vim.lsp.get_active_clients()) end)

local function cfg(t)
    assert(t.name)  -- `name` is used by the default `reuse_client` predicate
    return vim.tbl_deep_extend('keep', t, {
        handlers = {
            ['textDocument/definition'] = function(...)
                vim.lsp.handlers['textDocument/definition'](...)
                vim.cmd 'norm! zz'
            end,
        }
    })
end

local function find_dir(fnames)
    return vim.fs.dirname(
        vim.fs.find(fnames, {upward = true})[1]
    )
end

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

-- Disabling because goto definition jumps to header file.
-- https://github.com/clangd/clangd/issues/1348

-- au('FileType', 'c', function()
--     vim.lsp.start(cfg{
--         name = 'c',
--         cmd = {'clangd'},
--         root_dir = find_dir{
--             '.clangd',
--             '.clang-format',
--             'compile_commands.json',
--             'compile_flags.txt',
--             'configure.ac', -- AutoTools
--         },
--         single_file_support = true,
--         capabilities = {
--             textDocument = {
--                 completion = {
--                     editsNearCursor = true,
--                 },
--             },
--             offsetEncoding = {'utf-8', 'utf-16'},
--         },
--     })
-- end)

-- au('FileType', 'rust', function()
--     vim.lsp.start(cfg{
--         name = 'rust',
--         cmd = {'rls'},
--         root_dir = find_dir'Cargo.toml',
--     })
-- end)

au('FileType', 'typescript', function()
    vim.lsp.start(cfg{
        name = 'tsserver',
        cmd = { 'typescript-language-server', '--stdio' },
        root_dir = find_dir{'tsconfig.json', 'package.json', '.git'},
        single_file_support = true,
    })
end)
