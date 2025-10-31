return {
    {
        'mason-org/mason.nvim',
        opts = {
            ui = {
                icons = {
                    package_installed = '󰄬',
                    package_pending = '󰔟',
                    package_uninstalled = '󰮏',
                },
            },
        },
    },
    {
        'mason-org/mason-lspconfig.nvim',
        opts = {
            ensure_installed = { 'bashls', 'harper_ls', 'fish_lsp', 'lua_ls', 'taplo' },
            automatic_installation = true,
            automatic_enable = {
                exclude = { 'jdtls', 'rust_analyzer' },
            },
        },
        dependencies = {
            { 'mason-org/mason.nvim' },
            { 'neovim/nvim-lspconfig' },
        },
    },
    {
        'zapling/mason-lock.nvim',
        opts = {
            lockfile_path = vim.fn.stdpath('config') .. '/mason-lock.json'
        },
        dependencies = {
            { 'mason-org/mason.nvim' },
        },
    },
}
