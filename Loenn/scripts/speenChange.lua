local script = {
    name = "speenChange",
    displayName = "Change Spinners",
    parameters = {
        dust = false,
        color = "Blue",
    },
    fieldOrder = {
        "color", "dust"
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
        dust = "Whether the spinners should be dust bunnies",
        color = "The color of spinners",
    },
}

function script.run(room, args)
    local color = args.color
    local dust = args.dust

    for _, entity in ipairs(room.entities) do
        if entity._name == "spinner" then
            entity.color = color
            entity.dust = dust
            entity.dusty = nil
        end
    end
end

return script