require('config.nvim')
require('config.nvim-buffer-format-on-save')
require('config.nvim-lsp-keybinds')
require('config.nvim-selected-line-nr-hl')
require('config.lazy')
require('config.rustaceanvim')

if vim.tbl_contains(vim.fn.getcompletion('', 'color'), 'catppuccin-mocha') then
    vim.cmd.colorscheme('catppuccin-mocha')
end
