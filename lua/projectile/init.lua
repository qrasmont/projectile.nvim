local selector = require('projectile.selector')

local function run(path)
    selector.toggle_selector(path)
end

local function setup(conf)
    selector.setup(conf)
end

return {
    setup = setup,
    run = run,
    toggle_output = selector.toggle_output,
}
