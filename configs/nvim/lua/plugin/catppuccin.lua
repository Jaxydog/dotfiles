return {
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000,
        opts = {
            float = { solid = true, transparent = false },
            integrations = {
                blink_cmp = {
                    style = 'bordered',
                },
                mason = true,
                mini = {
                    enabled = true,
                    identscope_color = 'mocha',
                },
                render_markdown = true,
            },
            custom_highlights = function(colors)
                return {
                    DiagnosticUnderlineError = { undercurl = true },
                    DiagnosticUnderlineWarn = { undercurl = true },
                    DiagnosticUnderlineInfo = { undercurl = true },
                    DiagnosticUnderlineHint = { undercurl = true },

                    SelectLineNr = { bold = true, foreground = colors.lavender, background = colors.surface2 },
                    PartialSelectLineNr = { foreground = colors.lavender, background = colors.surface0 },
                }
            end,
        },
    },
}
