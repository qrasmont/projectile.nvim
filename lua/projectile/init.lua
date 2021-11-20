local ui = require('projectile.ui')
local jobs = require('projectile.jobs')

local cached_actions = {}
local nbr_actions = 0

local function select_actions_cb(job, exit_code)
    if exit_code ~= 0 then
        print(job:result()[1])
        return
    end

    -- empty cache
    cached_actions = {}

    for _, action in pairs(job:result()) do
        table.insert(cached_actions, #cached_actions + 1, action)
    end

    nbr_actions = #cached_actions
end

local function run(path)
    -- Entry point get the action list then run select_actions
    jobs.get(path, select_actions_cb)

    -- Create popup window for action selection
    ui.create_selector_prompt(nbr_actions)

    -- set action list in buffer
    ui.set_selection(cached_actions)
end

return {
    run = run,
}
