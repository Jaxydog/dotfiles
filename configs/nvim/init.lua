require('config.nvim')
require('config.lazy')
require('config.nvim-buffer-format-on-save')
require('config.nvim-lsp-keybinds')
require('config.nvim-selected-line-nr-hl')
require('config.nvim-treesitter')
require('config.rustaceanvim')

if vim.tbl_contains(vim.fn.getcompletion('', 'color'), 'catppuccin-mocha') then
    vim.cmd.colorscheme('catppuccin-mocha')
end
