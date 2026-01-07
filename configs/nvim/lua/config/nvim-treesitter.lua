require('nvim-treesitter').install({
    'bash',
    'diff',
    'fish',
    'git_config',
    'git_rebase',
    'gitattributes',
    'gitcommit',
    'gitignore',
    'json',
    'markdown',
    'markdown_inline',
    'regex',
    'rust',
    'toml',
})

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('nvim_treesitter_support', { clear = false }),
    desc = 'Enable folding and indentation detection based on `nvim-treesitter`',
    callback = function(event)
        if not pcall(vim.treesitter.start, event.buf) then return end

        vim.wo.foldmethod = 'expr'
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.wo.foldlevel = 255

        -- This currently breaks automatic indentation on line creation, which is slightly annoying.
        -- vim.bo.indentexpr = 'v:lua.require("nvim-treesitter").indentexpr()'
    end,
})

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp_override_folding', { clear = false }),
    desc = 'Enable folding for the active buffer using the active LSP',
    callback = function(event)
        local lsp_client_id = vim.tbl_get(event, 'data', 'client_id')
        local lsp_client = lsp_client_id and vim.lsp.get_client_by_id(lsp_client_id)

        if lsp_client == nil or not lsp_client:supports_method('textDocument/foldingRange') then return end

        local window_id = vim.api.nvim_get_current_win()

        if vim.api.nvim_win_get_buf(window_id) ~= event.buf then
            vim.api.nvim_echo({ { 'Attempted to configure an unfocused window', 'WarningMsg' } }, true, {})
        else
            vim.wo[window_id][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
        end
    end,
})
