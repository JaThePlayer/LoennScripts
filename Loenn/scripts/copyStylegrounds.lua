local state = require("loaded_state")
local snapshot = require("structs.snapshot")
local utils = require("utils")
local mapcoder = require("mapcoder")
local mapStruct = require("structs.map")

local script = {
    name = "copyStylegrounds",
    displayName = "Copy Stylegrounds",
    parameters = {
        from = "",
        clearExisting = false
    },
    fieldOrder = { "from", "clearExisting" },
    fieldInformation = {
        from = {
            fieldType = "loennScripts.directFilepath",
            extension = "bin"
        }
    },
    tooltip = "Copies stylegrounds from another map",
    tooltips = {
        from = "The file from which the stylegrounds will be copied",
        clearExisting = "Whether already existing stylegrounds should be deleted from the map",
    },
}

function script.prerun(args)
    local targetMap = mapStruct.decode(mapcoder.decodeFile(args.from))
    local oldStylesFg = utils.deepcopy(state.map.stylesFg)
    local oldStylesBg = utils.deepcopy(state.map.stylesBg)

    local function forward(data)
        local map = state.map

        local newStylesFg = utils.deepcopy(targetMap.stylesFg)
        local newStylesBg = utils.deepcopy(targetMap.stylesBg)

        if args.clearExisting then
            map.stylesFg = newStylesFg
            map.stylesBg = newStylesBg
        else
            for _,v in ipairs(newStylesFg) do
                table.insert(map.stylesFg, v)
            end
            for _,v in ipairs(newStylesBg) do
                table.insert(map.stylesBg, v)
            end
        end
    end

    local function backward(data)
        local map = state.map

        map.stylesFg = oldStylesFg
        map.stylesBg = oldStylesBg
    end

    forward()

    return snapshot.create(script.name, {}, backward, forward)
end

return script