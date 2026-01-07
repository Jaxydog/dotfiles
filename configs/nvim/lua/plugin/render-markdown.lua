return {
    {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
            completions = {
                lsp = { enabled = true },
            },
        },
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter' },
            { 'nvim-mini/mini.icons' },
        },
    },
}
