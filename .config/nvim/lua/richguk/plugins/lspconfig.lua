return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
    },
    config = function()
      local ensure_installed = {}
      if os.getenv("FULL_DOTFILES") then
        ensure_installed = {
          'tsserver',
          'eslint',
          'golangci_lint_ls',
          'gopls',
        }
      end

      local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
      require('mason').setup({})
      require('mason-lspconfig').setup({
        ensure_installed = ensure_installed,
        handlers = {
          function(server)
            require('lspconfig')[server].setup({
              capabilities = lsp_capabilities,
            })
          end,
          lua_ls = function()
            require('lspconfig').lua_ls.setup({
              capabilities = lsp_capabilities,
              settings = {
                Lua = {
                  diagnostics = {
                    globals = { 'vim' },
                  },
                }
              }
            })
          end
        }
      })
      require('lspconfig').solargraph.setup({})

      local cmp = require('cmp')
      local luasnip = require('luasnip')

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
      end

      cmp.setup({
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered()
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end
        },
        sources = {
          { name = 'path' },
          { name = 'nvim_lsp' },
          { name = 'nvim_lua' },
          { name = 'buffer',  keyword_length = 3 },
          { name = 'luasnip' },
        },
        mapping = cmp.mapping.preset.insert({
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end,
          ['<S-Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end,
        }),
      })
    end
  }
}
