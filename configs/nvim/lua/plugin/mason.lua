return {
    {
        'mason-org/mason.nvim',
        opts = {
            ui = {
                icons = {
                    package_installed = '+',
                    package_pending = '~',
                    package_uninstalled = '-',
                },
            },
        },
    },
    {
        'mason-org/mason-lspconfig.nvim',
        opts = {
            automatic_installation = true,
            ensure_installed = { 'bashls', 'lua_ls', 'taplo' },
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
