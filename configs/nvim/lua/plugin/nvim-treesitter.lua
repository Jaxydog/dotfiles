return {
    {
        'nvim-treesitter/nvim-treesitter',
        opts = {
            ensure_installed = { 'bash', 'regex', 'rust', 'toml', 'markdown', 'markdown_inline' },
            auto_install = true,
            sync_install = false,
            modules = {},
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
        },
    },
}
