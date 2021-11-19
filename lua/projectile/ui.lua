local popup = require('plenary.popup')
local selector_win_id, selector_win,  selector_bufnr

local function create_selector_prompt(height)
    local width = 60
    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

    selector_win_id, selector_win = popup.create("", {
        title = "Projectile",
        highlight = "ProjectileWinHL",
        borderchars = borderchars,
        minwidth = width,
        minheight = height,
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
    })

    -- Clear the border Hl
    vim.api.nvim_win_set_option(
        selector_win.border.win_id,
        "winhl",
        "Normal:ProjectileBorderHl"
    )

    selector_bufnr = vim.api.nvim_win_get_buf(selector_win_id)
end

local function set_selection(selection)
    vim.api.nvim_buf_set_lines(selector_bufnr, 0, -1, false, selection)
end

return {
    create_selector_prompt = create_selector_prompt,
    set_selection = set_selection,
}
