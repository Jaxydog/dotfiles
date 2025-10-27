vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'Enable buffer formatting on save',
    callback = function(event)
        local lsp_client_id = vim.tbl_get(event, 'data', 'client_id')
        local lsp_client = lsp_client_id and vim.lsp.get_client_by_id(lsp_client_id)

        if lsp_client == nil or not lsp_client:supports_method('textDocument/formatting') then return end

        local group_id = vim.api.nvim_create_augroup('lsp_format_on_save', { clear = false })

        vim.api.nvim_clear_autocmds({ buffer = event.buf, group = group_id })
        vim.api.nvim_create_autocmd('BufWritePre', {
            group = group_id,
            desc = 'Format buffer on save',
            callback = function(format_event)
                vim.lsp.buf.format({ bufnr = format_event.buf, timeout_ms = 3000 })
            end,
        })
    end,
})
