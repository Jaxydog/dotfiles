local ignored_snippet_labels = {
    -- Default snippets that are always active and I will never use.
    'copyright',
    'date',
    'dateDMY',
    'dateMDY',
    'datetime',
    'diso',
    'time',
    'timeHMS',
    'uuid',
}
local ignored_snippet_patterns = {
    -- Added alongside other Rust snippets, and they're very big and annoying to scroll over. I also don't use Relm.
    '^relm',
}

return {
    {
        'saghen/blink.cmp',
        version = '1.*',
        dependencies = {
            { 'rafamadriz/friendly-snippets' },
        },
        --- @type blink.cmp.Config
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
                implementation = 'prefer_rust_with_warning',
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
                    'fallback',
                },
            },
            signature = {
                enabled = true,
                window = {
                    show_documentation = false,
                },
            },
            sources = {
                default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
                providers = {
                    lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
                },
                transform_items = function(_, items)
                    local is_buffer_only = vim.tbl_isempty(vim.tbl_filter(function(item)
                        --- @cast item blink.cmp.CompletionItem
                        return item.source_name ~= 'buffer'
                    end, items))

                    if is_buffer_only then return items end

                    return vim.tbl_filter(function(item)
                        --- @cast item blink.cmp.CompletionItem

                        return item.kind ~= require('blink.cmp.types').CompletionItemKind.Snippet
                            or (
                                not vim.tbl_contains(ignored_snippet_labels, item.label)
                                and not vim.tbl_contains(ignored_snippet_patterns, function(pattern)
                                    return item.label:match(pattern)
                                end, { predicate = true })
                            )
                    end, items)
                end,
            },
        },
    },
}
