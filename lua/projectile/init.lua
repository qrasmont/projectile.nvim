local Job = require('plenary.job')
local ui = require('projectile.ui')

local cached_actions = {}
local nbr_actions = 0

-- Run projectile get
-- @param path: where to run
-- @param on_result: function callback, called when job ends
local function get(path, on_result)
    -- Use cwd if no path is provided
    if path == nil or path == '' then
        path = vim.fn.getcwd()
    end

    -- Excute projectile's get command
    Job:new({
        command = 'projectile',
        args = { 'get' },
        cwd = path,
        on_exit = on_result,
    }):sync()
end

-- Run projectile do
-- @param path: where to run
-- @param actions: a set of the actions to perform
-- @param on_result: callback function, call when job ends
local function do_actions(path, actions, on_result)
    -- Use cwd if no path is provided
    if path == nil or path == '' then
        path = vim.fn.getcwd()
    end

    -- append the do commands to action list
    table.insert(actions, 1, 'do')

    -- Excute projectile's get command
    Job:new({
        command = 'projectile',
        args = actions,
        cwd = path,
        on_exit = on_result,
    }):start()
end

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
    get(path, select_actions_cb)

    -- Create popup window for action selection
    ui.create_selector_prompt(nbr_actions)

    -- set action list in buffer
    ui.set_selection(cached_actions)
end

return {
    run = run,
    get = get,
    do_actions = do_actions
}
