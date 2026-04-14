local util = require'util'

local function setup()
    require'paq'{
        {'beardedsakimonkey/nvim-udir', branch='develop'},
        {'beardedsakimonkey/nvim-ufind'},
        {'tpope/vim-commentary'},
        {'tpope/vim-sleuth'},
        {'tpope/vim-abolish'},

        'neovim/nvim-lspconfig',
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-nvim-lsp',
        'kkharji/xbase',
        'keith/swift.vim',
        'Bakudankun/PICO-8.vim',

        {'savq/paq-nvim',               pin=true},
        {'kylechui/nvim-surround',      pin=true},
        {'AndrewRadev/linediff.vim',    pin=true},
        {'echasnovski/mini.operators',  pin=true},
        {'echasnovski/mini.hipatterns', pin=true, opt=true},
        {'dstein64/vim-startuptime',    pin=true, opt=true},
        'mhartington/formatter.nvim',
    }
end

local function configure()
    local function stub_com(cmd, pack)
        com(cmd, function()
            vim.api.nvim_del_user_command(cmd)
            vim.cmd('pa ' .. pack)
            vim.cmd(cmd)
        end)
    end

    local function stub_map(mode, lhs, pack)
        map(mode, lhs, function()
            vim.keymap.del(mode, lhs)
            vim.cmd('pa ' .. pack)
            vim.api.nvim_input(lhs)
        end)
    end

    require_safe 'config.udir'
    require_safe 'config.ufind'

    -- paq ---------------------------------------------------------------------
    com('PInstall', 'PaqInstall')
    com('PUpdate', 'PaqLogClean | PaqUpdate')
    com('PClean', 'PaqClean')
    com('PSync', 'PaqLogClean | PaqSync')

    -- linediff ----------------------------------------------------------------
    vim.g.linediff_buffer_type = 'scratch'
    map('x', 'D', "mode() is# 'V' ? ':Linediff<cr>' : 'D'", {expr = true})

    -- nvim-surround -----------------------------------------------------------
    require'nvim-surround'.setup{
        indent_lines = false,
    }

    -- mini.hipatterns ---------------------------------------------------------
    local color_map

    local function enable_hipatterns(opts)
        vim.cmd'pa mini.hipatterns'
        local hipatterns = require'mini.hipatterns'
        hipatterns.enable(opts.buf, {
            highlighters = {
                hex_color = hipatterns.gen_highlighter.hex_color(),
                named_color = {
                    pattern = '%w+',
                    group = function(_, match)
                        local color = color_map[match]
                        if color == nil then return nil end
                        return hipatterns.compute_hex_color_group(color, 'bg')
                    end
                },
            },
        })
    end

    local au = aug'my/hipatterns'
    au('BufEnter', {'papyrus.lua', 'rgb.txt', '*.css'}, function(opts)
        color_map = color_map or vim.tbl_map(
            function(dec) return string.format('#%06x', dec) end,
            vim.api.nvim_get_color_map()
        )
        enable_hipatterns(opts)
    end)
    -- Sourcing colorscheme invokes `:hi clear`, which clears mini's highlight
    -- groups.
    au('BufWritePost', 'papyrus.lua', function(opts)
        package.loaded['mini.hipatterns'] = nil
        enable_hipatterns(opts)
    end)

    -- mini.operators ----------------------------------------------------------
    require('mini.operators').setup({
        evaluate = { prefix = 'g=' },
        exchange = { prefix = 'gx' },
        multiply = { prefix = 'gm' },
        replace  = { prefix = 'gr' },
        sort     = { prefix = 'gs' }
    })

    -- vim-startuptime ---------------------------------------------------------
    stub_com('StartupTime', 'vim-startuptime')

    -- vim-abolish -------------------------------------------------------------
    -- Abbreviations in ../after/plugin/abolish.vim

    -- xbase -------------------------------------------------------------------
    require'xbase'.setup{
        sourcekit = {},
        simctl = {
            iOS = {
                "iPhone 14 Pro",
            },
        },
    }

    -- nvim-cmp ----------------------------------------------------------------
      local cmp = require'cmp'

      cmp.setup({
          snippet = {
              -- REQUIRED - you must specify a snippet engine
              expand = function(args)
              end,
          },
          window = {
              -- completion = cmp.config.window.bordered(),
              -- documentation = cmp.config.window.bordered(),
          },
          mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          }),
          sources = cmp.config.sources({
              { name = 'nvim_lsp' },
          }, {
              { name = 'buffer' },
          })
      })
      -- Set up lspconfig.
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
      require('lspconfig')['sourcekit'].setup {
          root_dir = require'lspconfig'.util.root_pattern("Package.swift", ".git", "*.xcodeproj"),
          capabilities = capabilities,
      }

      -- formatter.nvim --------------------------------------------------------
      require('formatter').setup{
          filetype = {
              typescript = {
                  function()
                      return {
                          exe = 'dprint',
                          args = {'fmt', '--stdin', '.ts'},
                          stdin = true,
                      }
                  end
              }
          }
      }
      local au2 = aug'my/formatter'
      au2('BufWritePost', '*.ts', ':FormatWrite')
end

local path = vim.fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
if not util.exists(path) then  -- bootstrap
    print('Cloning paq-nvim...')
    vim.fn.system{'git', 'clone', '--depth', '1',
        'https://github.com/savq/paq-nvim', path}
    vim.cmd 'pa paq-nvim'
    setup()
    require'paq'.install()
    vim.api.nvim_create_autocmd('User', {
        pattern = 'PaqDoneInstall',
        callback = configure,
        once = true,
    })
else
    setup()
    configure()
end
