local success, registryOrErrorMessage = pcall(require, 'mason-registry')

if not success then
    ---@cast registryOrErrorMessage string

    vim.api.nvim_echo({
        { 'Failed to import `mason-registry`', 'WarningMsg' },
        { registryOrErrorMessage,              'ErrorMsg' },
    }, true, {})

    return
end

-- Any packages installed here should not a valid package for usage with Mason's `ensure_installed` field.

--- @module 'mason-registry'
local registry = registryOrErrorMessage
local packagesToPreinstall = { 'codelldb', 'emmylua_ls', 'jq', 'shellcheck', 'shfmt', 'taplo' }
local packagesToActuallyInstall = {}

for _, packageName in ipairs(packagesToPreinstall) do
    if not registry.has_package(packageName) then
        vim.api.nvim_echo({ { ('Invalid package name `%s`'):format(packageName), 'WarningMsg' } }, true, {})
    elseif not registry.is_installed(packageName) then
        packagesToActuallyInstall[#packagesToActuallyInstall + 1] = packageName
    end
end
