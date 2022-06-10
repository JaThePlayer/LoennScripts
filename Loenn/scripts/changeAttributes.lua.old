local script = {
    name = "changeAttrs",
    displayName = "Change Attributes",
    tooltip = "Changes specified attributes in all entities/triggers of a specified type",
    tooltips = {
        types = "List of entity/triggers names that will be affected by this script.\nExample: spinner,FrostHelper/IceSpinner",
        attributes = "List of attributes to change, seperated by a comma.\nEach attribute needs to have a type specified\nPossible types: string,number,bool\nExample: color:string,dusty:bool",
        values = "List of values to set the attributes to.\nThis list is in the same order as the list in the attributes field.\nExample: Blue,false",
        layer = "The layer this script will affect."
    },
    parameters = {
        types = "",
        attributes = "",
        layer = "entities",
        values = "",
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

local function toboolean(str)
    if str == nil then
        return false
    end
    return string.lower(str) == 'true'
end

local function getValue(val, type)
    if type == "string" then
        return val
    elseif type == "number" then
        return tonumber(val)
    elseif type == "bool" then
        return toboolean(val)
    end
end

function script.run(room, args)
    local types = args.types:split(",")()
    local attributes = args.attributes:split(",")()
    local values = args.values:split(",")()
    local layer = args.layer

    for _, entity in ipairs(room[layer]) do
        if contains(types, entity._name) then
            for i, attr in ipairs(attributes) do
                local split = attr:split(":")()
                local name = split[1]
                local type = split[2] or "string"
                print(entity._id, name, type, values[i])
                entity[name] = getValue(values[i], type)
            end

        end
    end
end

return script