local popup = require('plenary.popup')

local function create_selector_prompt(height)
    local width = 60
    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

    local win_id, win = popup.create("", {
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
        win.border.win_id,
        "winhl",
        "Normal:ProjectileBorderHl"
    )

    local bufnr = vim.api.nvim_win_get_buf(win_id)

    return win_id, bufnr
end

return {
    create_selector_prompt = create_selector_prompt,
}
