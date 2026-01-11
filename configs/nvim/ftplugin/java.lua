require('jdtls').start_or_attach({
    name = 'jdtls',
    cmd = { vim.fn.exepath('jdtls') },
    root_dir = vim.fs.root(0, { '.git', 'gradlew' }),
    settings = {
        java = {
            format = {
                enabled = true,
                settings = {
                    profile = 'default',
                    --- @diagnostic disable-next-line: param-type-mismatch
                    url = vim.fs.joinpath(vim.fn.stdpath('config'), 'jdtls-style.xml'),
                },
            },
        },
    },
})

local keymap_options = { buffer = vim.api.nvim_get_current_buf(), silent = true }

local function set_jdtls_keymap(pattern, command)
    vim.keymap.set('n', pattern, function() command({}) end, keymap_options)
    vim.keymap.set('v', pattern, function() command({ visual = true }) end, keymap_options)
end

set_jdtls_keymap('<leader>exv', function(options) require('jdtls').extract_variable(options) end)
set_jdtls_keymap('<leader>exV', function(options) require('jdtls').extract_variable_all(options) end)
set_jdtls_keymap('<leader>exc', function(options) require('jdtls').extract_constant(options) end)
set_jdtls_keymap('<leader>exm', function(options) require('jdtls').extract_method(options) end)

vim.keymap.set('n', '<leader>R', vim.cmd.JdtRestart, keymap_options)

local function set_jdtls_gradle_keymap(modes, pattern, command)
    local function run()
        local root_path = vim.fs.root(0, { '.git', 'gradlew' })

        vim.cmd(('hor bo te %s/gradlew %s'):format(root_path, command))
    end

    vim.keymap.set(modes, pattern, run, keymap_options)
end

set_jdtls_gradle_keymap('n', '<leader>gs', 'genSources')
set_jdtls_gradle_keymap('n', '<leader>rc', 'runClient')
set_jdtls_gradle_keymap('n', '<leader>rs', 'runServer')
