local M = {}
local config = {
    wait = {
        wait_text = 'Projectile',
        rate = 1000,
    },
    done = {
        success_symbol = '✔',
        success_text = 'Success',
        fail_symbol = '✖',
        fail_text = 'Fail',
        delay = 3000,
    }
}

local loader = {
    "[.  ]",
    "[.. ]",
    "[...]",
    "[   ]",
}

local notifier = {
    bufnr = nil,
    winid = nil,
    stopped = false,
    close = false,
    load_idx = 0,
    height = 2,
    width = 16,
}

local function reset()
    notifier.stopped = false
    notifier.close = false
    notifier.load_idx = 0
end

local function wait()
    if notifier.stopped then
        return
    end

    notifier.load_idx = (notifier.load_idx + 1) % #loader
    vim.api.nvim_buf_set_lines(notifier.bufnr, 0, 1, false, {loader[notifier.load_idx + 1] .. ' ' .. config.wait.wait_text})

    vim.defer_fn(wait, config.wait.rate)
end

local function create_window()
    local row = vim.api.nvim_win_get_height(0)
    local col = vim.api.nvim_win_get_width(0)

    if notifier.bufnr == nil or not vim.api.nvim_buf_is_valid(notifier.bufnr) then
        notifier.bufnr = vim.api.nvim_create_buf(false, true)
    end

    if notifier.winid == nil or not vim.api.nvim_win_is_valid(notifier.winid) then
        notifier.winid = vim.api.nvim_open_win(notifier.bufnr, false, {
            relative = 'win',
            width = notifier.width,
            height = notifier.height,
            row = row,
            col = col,
            anchor = 'SE',
            focusable = false,
            style = 'minimal',
            zindex = nil,
            noautocmd = true,
        })
    else
        vim.api.nvim_win_set_config(notifier.winid, {
            win = vim.api.nvim_get_current_win(),
            relative = 'win',
            width = notifier.width,
            height = notifier.height,
            row = row,
            col = col,
            anchor = 'SE',
            zindex = nil,
        })
    end

    vim.api.nvim_win_set_option(notifier.winid, "winhighlight", "Normal:NotifierText")
end

function M.start()
    reset()
    create_window()
    wait()
end

local function close_window()
    if notifier.winid ~= nil and vim.api.nvim_win_is_valid(notifier.winid) then
        vim.api.nvim_win_hide(notifier.winid)
        notifier.winid = nil
    end
    if notifier.bufnr ~= nil and vim.api.nvim_buf_is_valid(notifier.bufnr) then
        vim.api.nvim_buf_delete(notifier.bufnr, { force = true })
        notifier.bufnr = nil
    end
end

local function longest_str_length()
    local success_len = #config.done.success_symbol + #config.done.success_text
    local fail_len = #config.done.fail_symbol + #config.done.fail_text

    local longest = #config.wait.wait_text + #loader[1]
    if success_len > longest then
        longest = success_len
    end
    if fail_len > longest then
        longest = fail_len
    end

    return longest
end

local function delay_close()
    if notifier.close then
        close_window()
    else
        notifier.close = true
        vim.defer_fn(function ()
            delay_close()
        end, config.done.delay)
    end
end

function M.stop(success)
    notifier.stopped = true
    local text = success and config.done.success_symbol .. ' ' .. config.done.success_text
                         or config.done.fail_symbol .. ' ' .. config.done.fail_text

    if success then
        vim.api.nvim_win_set_option(notifier.winid, "winhighlight", "Normal:NotifierSuccess")
    else
        vim.api.nvim_win_set_option(notifier.winid, "winhighlight", "Normal:NotifierFail")
    end

    vim.api.nvim_buf_set_lines(notifier.bufnr, 0, 1, false, {text})
    delay_close()
end

function M.setup(conf)
    config = vim.tbl_deep_extend("force", config, conf or {})

    vim.cmd([[highlight default link NotifierText Title]])

    notifier.width = longest_str_length() + 2 -- 1 space + 1 padding
end

return M
