local scriptsLibrary = require("mods").requireFromPlugin("library.scriptsLibrary")

local script = {
    name = "runFile",
    displayName = "_Run From File",
    parameters = {
        from = "",
    },
    fieldInformation = {
        from = {
            fieldType = "loennScripts.directFilepath",
            extension = "lua"
        }
    },
    tooltip = "Runs a script from any .lua file.\nMake sure to understand what the script does before running it!\nThe scripts ran by this may or may not be revertable by ctrl+z!",
    tooltips = {
        from = "The file from which the script will be loaded"
    },
    ignoredFields = { "__handler" },
}

-- Making any arbitrary script ctrl+z compliant could be impossible
function script.prerun(args)
    local file = io.open(args.from)
    local l = file:read("*a")
    file:close()
    local f = assert(loadstring(l))
    args.__handler = f()

    if type(args.__handler) ~= "table" then
        -- This wasn't a handler. The code already ran, nothing more to do
        return
    end

    local filename = scriptsLibrary.filename(args.from, true)

    if not args.__handler.name then
        args.__handler.name = filename
    end

    if not args.__handler.displayName then
        args.__handler.displayName = filename
    end

    script.scriptsTool.useScript(args.__handler)
end

return script
