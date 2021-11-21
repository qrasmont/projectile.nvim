local selector = require('projectile.selector')

local function run(path)
    selector.toggle_selector(path)
end

return {
    run = run,
    toggle_output = selector.toggle_output
}
