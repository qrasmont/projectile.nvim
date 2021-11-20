local selector = require('projectile.selector')

local function run(path)
    selector.toggle(path)
end

return {
    run = run,
}
