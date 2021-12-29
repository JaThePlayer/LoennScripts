local state = require("loaded_state")
local snapshot = require("structs.snapshot")
local utils = require("utils")

local script = {
    name = "removeFillers",
    displayName = "Remove Fillers"
}

--prerun can be used when you want to make global changes to the map
--global changes here need manual snapshot creation to allow ctrl+z
function script.prerun()
    local prev = utils.deepcopy(state.map.fillers)

    local function forward(data)
        state.map.fillers = {}
    end

    local function backward(data)
        state.map.fillers = prev
    end

    forward()

    return snapshot.create(script.name, {}, backward, forward)
end

return script