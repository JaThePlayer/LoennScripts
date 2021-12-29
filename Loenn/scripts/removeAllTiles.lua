local roomStruct = require("structs.room")

local script = {
    name = "removeTiles",
    displayName = "Remove All Tiles"
}

function script.run(room)
    local h = room.height / 8
    roomStruct.directionalResize(room, "up", -h)
    roomStruct.directionalResize(room, "up", h)
end

return script