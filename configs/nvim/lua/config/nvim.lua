vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

vim.opt.nu = true
vim.opt.tabstop = 8
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.isfname:append('@-@')
vim.opt.updatetime = 50
vim.opt.colorcolumn = '120'
vim.opt.cursorline = true
vim.opt.cursorlineopt = 'number'

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.INFO] = '',
            [vim.diagnostic.severity.HINT] = '',
        },
    },
})

vim.keymap.set('n', '<C-w>e', vim.cmd.Ex)
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)

vim.api.nvim_create_user_command('Write', 'noautocmd write', {
    desc = 'Write without running autocommands',
})
