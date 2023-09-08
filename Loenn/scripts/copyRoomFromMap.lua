local state = require("loaded_state")
local snapshot = require("structs.snapshot")
local utils = require("utils")
local mapcoder = require("mapcoder")
local mapStruct = require("structs.map")
local mapItemUtils = require("map_item_utils")
local celesteRender = require("celeste_render")

local script = {
    name = "copyRoomFromMap",
    displayName = "Copy Room From Map",
    parameters = {
        from = "",
        fromRoomName = "",
        newRoomName = "copiedRoom",
        replace = false,
    },
    fieldOrder = { "from", "fromRoomName", "newRoomName", "replace" },
    fieldInformation = {
        from = {
            fieldType = "loennScripts.directFilepath",
            extension = "bin"
        },
        newRoomName = {
            --fieldType = "room_name_unique",
        }
    },
    tooltip = "Copies a room from another map",
    tooltips = {
        from = "The file from which the room will be copied",
        fromRoomName = "The room name to copy from the other map",
        newRoomName = "The room name to use in this map",
        replace = "If enabled, the room in the current map with the same name as the New Room Name gets replaced with the newly copied room."
    },
}

--copied from state.getRoomByName
local function getRoomByName(rooms, name)
    local nameWithLvl = "lvl_" .. name

    for i, room in ipairs(rooms) do
        if room.name == name or room.name == nameWithLvl then
            return room, i
        end
    end
end

function script.prerun(args)
    local targetMap = mapStruct.decode(mapcoder.decodeFile(args.from))
    local targetRoom = getRoomByName(targetMap.rooms, args.fromRoomName)

    targetMap = nil
    local newRoom = nil
    local oldRoom = getRoomByName(state.map.rooms, args.newRoomName)

    local function forward(data)
        local map = state.map

        newRoom = utils.deepcopy(targetRoom)
        newRoom.name = args.newRoomName
        if oldRoom then
            newRoom.x = oldRoom.x
            newRoom.y = oldRoom.y
        end

        if args.replace and oldRoom then
            mapItemUtils.deleteRoom(map, oldRoom)
        end

        mapItemUtils.addItem(map, newRoom)

        if state.isItemSelected(oldRoom) then
            state.selectItem(newRoom)
        end
    end

    local function backward(data)
        local map = state.map

        mapItemUtils.deleteRoom(map, newRoom)

        if args.replace and oldRoom then
            mapItemUtils.addItem(map, oldRoom)

            if state.isItemSelected(newRoom) then
                state.selectItem(oldRoom)
            end
        end
    end

    forward()

    return snapshot.create(script.name, {}, backward, forward)
end

return script