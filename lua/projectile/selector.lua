local ui = require('projectile.ui')
local jobs = require('projectile.jobs')

local actions = {}
local nbr_actions = 0

local win_id = 0
local bufnr = 0

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

local function set_action_selection(selection)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, selection)
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
end

return {
    toggle = toggle,
}
