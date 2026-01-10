require('jdtls').start_or_attach({
    name = 'jdtls',
    cmd = { vim.fn.exepath('jdtls') },
    root_dir = vim.fs.root(0, { '.git', 'gradlew' }),
    settings = {
        java = {},
    },
    init_options = {
        bundles = {},
    },
})

local buffer = vim.api.nvim_get_current_buf()

local function set_jdtls_keymap(modes, pattern, command)
    vim.keymap.set(
        modes,
        pattern,
        function() vim.cmd(('hor bo te %s/gradlew %s'):format(vim.fs.root(0, { '.git', 'gradlew' }), command)) end,
        { buffer = buffer, silent = true }
    )
end

set_jdtls_keymap('n', '<leader>rc', 'runClient')
set_jdtls_keymap('n', '<leader>rs', 'runServer')
