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
    }):start()
end

return {
    get = get
}
