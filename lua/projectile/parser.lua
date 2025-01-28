local user_config = nil

local function load(path)
    local t, _ = loadfile('.projectile.lua')
    if not t then
        return false
    end

    user_config = t()
    return true
end

local function parse()
    local actions = {}
    for key, _ in pairs(user_config) do
        table.insert(actions, #actions + 1, key)
    end
    return actions
end

return  {
    load = load,
    parse = parse
}
