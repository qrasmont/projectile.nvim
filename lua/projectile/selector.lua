local ui = require('projectile.ui')
local jobs = require('projectile.jobs')

local actions = {}
local nbr_actions = 0

local selected_ids = {}

local win_id = 0
local bufnr = 0

-- Callback for 'projectile get'
-- @param job: the job object
-- @param exit_code: the process exit code
local function select_actions_cb(job, exit_code)
    if exit_code ~= 0 then
        print(job:result()[1])
        return
    end

    -- empty existing actions
    actions = {}

    for _, action in pairs(job:result()) do
        table.insert(actions, #actions + 1, action)
    end

    nbr_actions = #actions
end

-- Populate the popup window with the action list
-- @param selection: the action list
local function set_action_selection(selection)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, selection)
end


-- Update action selection
-- @param id: index of the action
-- @param selected: selected or de-selected (bool)
local function update_selected(id, selected)
    if selected then
        table.insert(selected_ids, id)
    else
        for i=#selected_ids,1,-1 do
            if selected_ids[i] == id then
                table.remove(selected_ids, i)
            end
        end
    end
end

-- Handle action toggle
local function on_action_toggle()
    local r, _ = unpack(vim.api.nvim_win_get_cursor(0))

    local selected_action = vim.api.nvim_buf_get_lines(bufnr, r-1, r, false)

    local updated_str = ''
    if (string.sub(selected_action[1], 1, 1) == '*') then
        updated_str = selected_action[1]:sub(3)
        update_selected(r, false)
    else
        updated_str = '* ' .. selected_action[1]
        update_selected(r, true)
    end
    vim.api.nvim_buf_set_lines(bufnr, r-1, r, false, {updated_str})

end

-- Run 'projectile do' with selected actions
local function on_start()
    -- Check for empty selection
    if next(selected_ids) == nil then
        print('Projectile: No actions selected!')
        return
    end

    local actions_to_run = {}
    for _, id in pairs(selected_ids) do
        table.insert(actions_to_run, #actions_to_run + 1, actions[id])
    end

    vim.api.nvim_win_close(win_id, true)

    jobs.do_actions(nil, actions_to_run, nil)
end

-- Set the keybindings for the popup window
local function set_keybindings()
    vim.api.nvim_buf_set_keymap(
        bufnr,
        "n",
        "s",
        "<Cmd>lua require('projectile.selector').on_action_toggle()<CR>",
        { silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        bufnr,
        "n",
        "<CR>",
        "<Cmd>lua require('projectile.selector').on_start()<CR>",
        { silent = true }
    )
end

-- Open the actions selection window
-- @param path: the path to where projectile should run
local function toggle(path)

    -- Run 'projectile get' to populate the actions set
    jobs.get(path, select_actions_cb)

    -- Create popup window for action selection
    win_id, bufnr = ui.create_selector_prompt(nbr_actions)

    -- set action list in buffer
    set_action_selection(actions)

    -- set popup keybindings
    set_keybindings()
end

return {
    toggle = toggle,
    on_action_toggle = on_action_toggle,
    on_start = on_start,
}
