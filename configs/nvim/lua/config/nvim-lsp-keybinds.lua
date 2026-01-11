vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP-enabled keybindings',
    callback = function(event)
        vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, { buffer = event.buf })
        vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, { buffer = event.buf })
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = event.buf })
        vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, { buffer = event.buf })
    end,
})
