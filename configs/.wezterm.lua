local wezterm = require('wezterm')
local wezterm_config = wezterm.config_builder()

wezterm_config.webgpu_power_preference = 'HighPerformance'

wezterm_config.color_scheme = 'catppuccin-mocha'
wezterm_config.colors = {
    tab_bar = {
        active_tab = {
            bg_color = '#1e1e2e',
            fg_color = '#cdd6f4',
        },
        inactive_tab = {
            bg_color = '#181825',
            fg_color = '#a6adc8',
        },
        inactive_tab_hover = {
            bg_color = '#181825',
            fg_color = '#bac2de',
        },
        inactive_tab_edge = '#181825',
        new_tab = {
            bg_color = '#181825',
            fg_color = '#a6adc8',
        },
        new_tab_hover = {
            bg_color = '#181825',
            fg_color = '#bac2de',
        },
    }
}

wezterm_config.font = wezterm.font('Monaspace Neon NF', {})
wezterm_config.font_size = 10

wezterm_config.window_background_opacity = 0.95
-- TODO: Uncomment when this is stable.
-- wezterm_config.kde_window_background_blur = true
wezterm_config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
wezterm_config.window_frame = {
    font = wezterm.font('Noto Sans'),
    font_size = 10.0,

    active_titlebar_bg = '#11111b',
    inactive_titlebar_bg = '#11111b',
}

wezterm_config.initial_cols = 120
wezterm_config.initial_rows = 36

wezterm_config.mouse_bindings = {
    {
        event = { Down = { streak = 1, button = 'Right' } },
        action = wezterm.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ''

            if has_selection then
                window:perform_action(wezterm.action.CopyTo('ClipboardAndPrimarySelection'), pane)
                window:perform_action(wezterm.action.ClearSelection, pane)
            else
                window:perform_action(wezterm.action.PasteFrom('Clipboard'), pane)
            end
        end),
    },
}

return wezterm_config
