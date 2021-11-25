local Job = require('plenary.job')

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
local function do_actions(path, actions, on_result, on_output)
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
        on_stdout = on_output,
    }):start()
end

return  {
    get = get,
    do_actions = do_actions
}
