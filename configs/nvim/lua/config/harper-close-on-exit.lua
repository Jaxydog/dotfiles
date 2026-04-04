vim.api.nvim_create_autocmd('ExitPre', {
    desc = 'Ensure that harper_ls is properly closed on exit to prevent LSP crashes',
    callback = function(event)
        for _, client in ipairs(vim.lsp.get_clients({ name = 'harper_ls' })) do
            client:stop()
        end
    end,
})
