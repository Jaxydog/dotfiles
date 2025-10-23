local lazy_install_directory = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazy_install_directory) then
    local lazy_git_repository = 'https://github.com/folke/lazy.nvim.git'
    local command_output = vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        '--branch=stable',
        lazy_git_repository,
        lazy_install_directory,
    })

    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { 'Failed to install lazy.nvim:\n', 'ErrorMsg' },
            { command_output,                   'WarningMsg' },
            { '\nPress any key to exit...' },
        }, true, {})

        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazy_install_directory)

require('lazy').setup({
    spec = { { import = 'plugin' } },
    install = { colorscheme = { 'catpucchin-mocha' } },
    checker = { enabled = true },
})
