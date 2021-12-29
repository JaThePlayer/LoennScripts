local script = {
    name = "speenChange",
    displayName = "Change Spinners",
    parameters = {
        dusty = false,
        color = "Blue",
    },
    fieldOrder = {
        "color", "dusty"
    },
    fieldInformation = {
        color = {
            fieldType = "loennScripts.dropdown",
            options = {
                "Blue", "Red", "Purple", "Core", "Rainbow"
            }
        }
    },
    tooltip = "Changes the settings of all vanilla spinners",
    tooltips = {
        dusty = "Whether the spinners should be dust bunnies",
        color = "The color of spinners",
    },
}

function script.run(room, args)
    local color = args.color
    local dusty = args.dusty

    for _, entity in ipairs(room.entities) do
        if entity._name == "spinner" then
            entity.color = color
            entity.dusty = dusty
        end
    end
end

return script