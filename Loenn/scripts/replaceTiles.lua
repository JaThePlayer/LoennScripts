local tilesStruct = require("structs.tiles")

local script = {
    name = "replaceTiles",
    displayName = "Replace Tiles",
    parameters = {
        layer = "Fg",
        from = "g",
        to = "7",
    },
    fieldInformation = {
        layer = {
            fieldType = "loennScripts.dropdown",
            options = {
                "Fg", "Bg"
            }
        }
    },
    fieldOrder = { "from", "to" },
    tooltip = "Replaces all tiles of a given type with another type",
    tooltips = {
        layer = "The layer to replace tiles in",
        from = "The tileset ID which will be replaced",
        to = "The tileset ID which will be placed instead",
    },
}

local function encodeString(str)
    return { innerText = str }
end

function script.run(room, args)
    local from = args.from or "g"
    local to = args.to or "7"

    local propertyName = "tiles" .. args.layer

    room[propertyName] = tilesStruct.decode(encodeString(string.gsub(tilesStruct.matrixToTileString(room[propertyName].matrix), from, to)))
end

return script