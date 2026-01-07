vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP-enabled keybindings',
    callback = function(event)
        vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, { buffer = event.buf })
        vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, { buffer = event.buf })
    end,
})
