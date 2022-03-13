local ui = require('projectile.ui')
local jobs = require('projectile.jobs')
local notifier = require('projectile.notifier')

local run_path = ''

local actions = {}
local nbr_actions = 0

local selected_ids = {}

local run_output = {}

local select_win_id = -1
local select_bufnr = 0

local start_win_id = 0
local output_win_id = -1
local output_bufnr = 0

local last_pos = 1

local output_behavior = 'notify'

-- Toggle the window containing the output of 'projectile do'
local function toggle_output()
    if vim.api.nvim_win_is_valid(output_win_id) then
        last_pos, _ = unpack(vim.api.nvim_win_get_cursor(output_win_id))
        vim.api.nvim_win_close(output_win_id, true)
    else
        start_win_id, output_win_id, output_bufnr = ui.create_output_window()
        vim.api.nvim_buf_set_lines(output_bufnr, 0, -1, false, run_output)
        vim.api.nvim_win_set_cursor(output_win_id, {last_pos, 0})
        vim.api.nvim_set_current_win(start_win_id)
   end
end

-- Callback for 'projectile do'
-- @param job: the job object
-- @param exit_code: the process exit code
local function run_on_exit_cb(job, exit_code)
    if exit_code ~= 0 then
        vim.schedule(function()
            vim.notify('FAILED'.. job:result()[1])
            notifier.stop(false)
        end)
        return
    end

    run_output = {}

    for _, line in pairs(job:result()) do
        table.insert(run_output, #run_output + 1, line)
    end

    vim.schedule(function()
        if output_behavior == 'notify' then
            vim.notify('Success')
            notifier.stop(true)
        elseif output_behavior == 'on_exit' then
            toggle_output()
        end
    end)
end

-- Callback for 'projectile do'
-- @param line: the new line from stdout
local function run_on_sdtout_cb(_, line)
    table.insert(run_output, #run_output + 1, line)

    vim.schedule(function()
        vim.api.nvim_buf_set_lines(output_bufnr, 0, -1, false, run_output)
        vim.api.nvim_win_set_cursor(output_win_id, {#run_output, 0})
    end)
end

-- Callback for 'projectile get'
-- @param job: the job object
-- @param exit_code: the process exit code
local function select_actions_cb(job, exit_code)
    if exit_code ~= 0 then
        vim.schedule(function()
            vim.notify(job:result()[1])
        end)
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
    vim.api.nvim_buf_set_lines(select_bufnr, 0, -1, false, selection)
    vim.api.nvim_buf_set_option(0, 'modifiable', false)
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

    local selected_action = vim.api.nvim_buf_get_lines(select_bufnr, r-1, r, false)

    vim.api.nvim_buf_set_option(0, 'modifiable', true)
    local updated_str = ''
    if (string.sub(selected_action[1], 1, 1) == '*') then
        updated_str = selected_action[1]:sub(3)
        update_selected(r, false)
    else
        updated_str = '* ' .. selected_action[1]
        update_selected(r, true)
    end
    vim.api.nvim_buf_set_lines(select_bufnr, r-1, r, false, {updated_str})
    vim.api.nvim_buf_set_option(0, 'modifiable', false)

end

-- Run 'projectile do' with selected actions
local function on_start()
    -- Check for empty selection
    if next(selected_ids) == nil then
        vim.notify('Projectile: No actions selected!')
        return
    end

    local actions_to_run = {}
    for _, id in pairs(selected_ids) do
        table.insert(actions_to_run, #actions_to_run + 1, actions[id])
    end

    vim.api.nvim_win_close(select_win_id, true)

    if output_behavior == 'on_stdout' then
        run_output = {}
        toggle_output()
        jobs.do_actions(run_path, actions_to_run, nil, run_on_sdtout_cb)
    else
        notifier.start()
        jobs.do_actions(run_path, actions_to_run, run_on_exit_cb, nil)
    end
end

-- Set the keybindings for the popup window
local function set_keybindings()
    vim.api.nvim_buf_set_keymap(
    select_bufnr,
    "n",
    "s",
    "<Cmd>lua require('projectile.selector').on_action_toggle()<CR>",
    { silent = true }
    )
    vim.api.nvim_buf_set_keymap(
    select_bufnr,
    "n",
    "<CR>",
    "<Cmd>lua require('projectile.selector').on_start()<CR>",
    { silent = true }
    )
    vim.api.nvim_buf_set_keymap(
    select_bufnr,
    "n",
    "q",
    "<Cmd>lua require('projectile.selector').toggle_selector()<CR>",
    { silent = true }
    )
    vim.api.nvim_buf_set_keymap(
    select_bufnr,
    "n",
    "<ESC>",
    "<Cmd>lua require('projectile.selector').toggle_selector()<CR>",
    { silent = true }
    )
end

-- Open the actions selection window
-- @param path: the path to where projectile should run
local function toggle_selector(path)
    if vim.api.nvim_win_is_valid(select_win_id) then
        vim.api.nvim_win_close(select_win_id, true)
    else
        run_path = path

        -- Run 'projectile get' to populate the actions set
        jobs.get(run_path, select_actions_cb)

        -- Create popup window for action selection
        select_win_id, select_bufnr = ui.create_selector_prompt(nbr_actions)

        -- set action list in buffer
        set_action_selection(actions)

        -- set popup keybindings
        set_keybindings()
    end
end

local function setup(conf)
    notifier.setup(conf)
end

return {
    setup = setup,
    toggle_selector = toggle_selector,
    toggle_output = toggle_output,
    on_action_toggle = on_action_toggle,
    on_start = on_start,
}
