local hl_group = 'SelectLineNr'
local hl_partial_group = 'PartialSelectLineNr'
local hl_namespace = vim.api.nvim_create_namespace('hl-' .. hl_group)

local function get_hl_bounds(start_row, start_col, stop_row, stop_col)
    return {
        start = start_row - 1,
        stop = stop_row - 1,
        is_start_partial = start_col > 1,
        is_stop_partial = stop_col < vim.fn.charcol({ stop_row, '$' }) - 1,
    }
end

local function hl_selected_line_nr(event)
    vim.api.nvim_buf_clear_namespace(event.buf, hl_namespace, 0, -1)

    local visual_modes = { 'v', 'V', '<C-V>' }
    local current_mode = vim.api.nvim_get_mode().mode

    if not vim.tbl_contains(visual_modes, current_mode) then return end

    local _, cursor_row, cursor_col = unpack(vim.fn.getpos('.'))
    local _, select_row, select_col = unpack(vim.fn.getpos('v'))
    local hl_bounds

    if cursor_row == select_row then
        if cursor_col >= select_col then
            hl_bounds = get_hl_bounds(select_row, select_col, cursor_row, cursor_col)
        else
            hl_bounds = get_hl_bounds(select_row, cursor_col, cursor_row, select_col)
        end
    else
        if cursor_row > select_row then
            hl_bounds = get_hl_bounds(select_row, select_col, cursor_row, cursor_col)
        else
            hl_bounds = get_hl_bounds(cursor_row, cursor_col, select_row, select_col)
        end
    end

    for line_number = hl_bounds.start, hl_bounds.stop, 1 do
        local is_line_partial = false

        if line_number == hl_bounds.start then
            is_line_partial = hl_bounds.is_start_partial
        end
        if line_number == hl_bounds.stop then
            is_line_partial = hl_bounds.is_stop_partial
        end

        local number_hl_group = (current_mode ~= 'V' and is_line_partial) and hl_partial_group or hl_group

        vim.api.nvim_buf_set_extmark(event.buf, hl_namespace, line_number, 0, { number_hl_group = number_hl_group })
    end
end

vim.api.nvim_create_autocmd({ 'CursorMoved', 'ModeChanged' }, {
    group = vim.api.nvim_create_augroup('hl_selected_line_nr', {}),
    desc = 'Add highlighting to the number column for selected lines',
    callback = hl_selected_line_nr,
})
