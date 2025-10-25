vim.g.rustaceanvim = {
    tools = {
        enable_clippy = true,
        test_executor = 'background',
    },
}

local success, registry = pcall(require, 'mason-registry')

-- `codelldb` is not a valid package for usage with Mason's `ensure_installed` field.
if success and not registry.is_installed('codelldb') then
    vim.cmd({ cmd = 'MasonInstall', args = { 'codelldb' } })
end
