local script = {
    name = "removeAttrs",
    displayName = "Remove Attributes",
    tooltip = "Removes specified attributes from all entities/triggers of a specified type",
    tooltips = {
        types = "List of entity/triggers names that will be affected by this script.\nExample: spinner,FrostHelper/IceSpinner",
        attributes = "List of attributes to remove, seperated by a comma.\nExample: color,dusty",
        layer = "The layer this script will affect."
    },
    parameters = {
        types = "",
        attributes = "",
        layer = "entities"
    },
    fieldInformation = {
        layer = {
            fieldType = "loennScripts.dropdown",
            options = {
                "entities", "triggers"
            }
        }
    },
}

local function contains(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function script.run(room, args)
    local types = args.types:split(",")()
    local attributes = args.attributes:split(",")()
    local layer = args.layer

    for _, entity in ipairs(room[layer]) do
        if contains(types, entity._name) then
            for _, attr in ipairs(attributes) do
                entity[attr] = nil
            end

        end
    end
end

return script