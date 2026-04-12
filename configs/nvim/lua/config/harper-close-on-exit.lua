vim.api.nvim_create_autocmd('BufUnload', {
    desc = 'Ensure that harper_ls is properly closed on exit to prevent LSP crashes',
    callback = function(event)
        for _, client in ipairs(vim.lsp.get_clients({ name = 'harper_ls', bufnr = event.buf })) do
            client:stop()
        end
    end,
})
