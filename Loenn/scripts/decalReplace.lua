local script = {
    name = "changeDecalPaths",
    displayName = "Change Decal Paths",
    tooltip = "Change paths of all decals in a room, according to a pattern",
    parameters = {
        from = "decals/",
        to = "decals/",
    },
    fieldOrder = { "from", "to" },
    tooltips = {
        from = "The lua pattern to search for in decal texture paths. This pattern will be replaced by the value from the \"to\" parameter",
        to = "The value to replace the pattern with"
    },
}

local function doLayer(layer, args)
    local from, to = args.from, args.to

    for _, decal in ipairs(layer) do
        decal.texture = decal.texture:gsub(from, to)
    end
end

script.run = function(room, args)
    doLayer(room.decalsFg, args)
    doLayer(room.decalsBg, args)
end

return script