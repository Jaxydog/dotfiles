return {
    {
        'saghen/blink.cmp',
        version = '1.*',
        dependencies = {
            { 'rafamadriz/friendly-snippets' },
        },
        opts = {
            completion = {
                ghost_text = {
                    enabled = true,
                    show_with_menu = true,
                },
                list = {
                    selection = {
                        auto_insert = false,
                        preselect = true,
                    },
                },
                menu = {
                    draw = {
                        components = {
                            kind_icon = {
                                text = function(context)
                                    local success, icons = pcall(require, 'mini.icons')

                                    if not success then return end

                                    local icon, _, _ = icons.get('lsp', context.kind)

                                    return icon
                                end,
                            },
                        },
                    },
                },
            },
            fuzzy = {
                implementation = 'prefer_rust_with_warning'
            },
            keymap = {
                preset = 'default',
                ['<Tab>'] = {
                    function(cmp)
                        if cmp.snippet_active() then
                            return cmp.accept()
                        else
                            return cmp.select_and_accept()
                        end
                    end,
                    'fallback'
                },
            },
            signature = {
                enabled = true,
                window = {
                    show_documentation = false,
                },
            },
            sources = {
                default = { 'lazydev', 'lsp', 'path', 'snippets', --[[ 'buffer' ]] },
                providers = {
                    lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
                },
            },
        },
    },
}
