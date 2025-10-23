local buffer = vim.api.nvim_get_current_buf()

local function set_rustlsp_keymap(mode, pattern, command)
    vim.keymap.set(mode, pattern, function() vim.cmd.RustLsp(command) end, { buffer = buffer, silent = true })
end

set_rustlsp_keymap('n', '<leader>-', 'parentModule')

set_rustlsp_keymap({ 'n', 'v' }, '<leader>jl', 'joinLines')

set_rustlsp_keymap({ 'n', 'v' }, '<leader>d', 'renderDiagnostic')
set_rustlsp_keymap({ 'n', 'v' }, '<leader>D', 'explainError')

set_rustlsp_keymap('n', '<leader>R', 'rebuildProcMacros')
set_rustlsp_keymap({ 'n', 'v' }, '<leader>x', 'expandMacro')

set_rustlsp_keymap('n', '<leader>vh', { 'view', 'hir' })
set_rustlsp_keymap('n', '<leader>vm', { 'view', 'mir' })

set_rustlsp_keymap({ 'n', 'v' }, '<leader><Up>', { 'moveItem', 'up' })
set_rustlsp_keymap({ 'n', 'v' }, '<leader><Down>', { 'moveItem', 'down' })
