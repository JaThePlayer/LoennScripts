local state = require("loaded_state")
local configs = require("configs")
local utils = require("utils")
local toolUtils = require("tool_utils")
local history = require("history")
local snapshotUtils = require("snapshot_utils")
local celesteRender = require("celeste_render")
local pluginLoader = require("plugin_loader")
local modHandler = require("mods")
local logging = require("logging")
local scriptParameterWindow = require("mods").requireFromPlugin("ui.windows.scriptParameterWindow")
local scriptsLibrary = require("mods").requireFromPlugin("library.scriptsLibrary")
local notifications = require("ui.notification")
local viewportHandler = require("viewport_handler")
local drawing = require("utils.drawing")
local colors = require("consts.colors")

local tool = {}

tool._type = "tool"
tool.name = "scripts"
tool.group = "placement"
tool.image = nil
tool.layer = "Current Room"
tool.validLayers = {
    "Current Room",
    "All Rooms",
}

-- the positions of all currently active scripts (aka those with the property window open), used for rendering previews
---x:number, y:number color:table[3]
local activeScriptPositions = {}

local scriptLocationPreviewColors = {
    {1, 0, 0},
    {0, 1, 0},
    {0, 0, 1},
    {1, 1, 0},
    {1, 0, 1},
    {0, 1, 1},
    {1, 1, 1},
}

function tool.reset(load)
    tool.currentScript = ""
    tool.scriptsAvailable = {}
    tool.scripts = { }

    if load then
        tool.load()
        toolUtils.sendLayerEvent(tool, tool.layer)
    end
end
tool.reset(false)

local function addScript(name, displayName, tooltip, mod)
    table.insert(tool.scriptsAvailable, {
        name = name,
        displayName = (displayName or name) .. " [" .. mod .."]",
        tooltipText = tooltip,
    } )
end

local function getTargetRooms()
    if tool.layer == "All Rooms" then
        return state.map.rooms
    else
        return { state.getSelectedRoom() }
    end
end

function tool.execScript(script, args, ctx)
    local snapshots = {}

    ctx = ctx or { }

    ctx.mouseX = ctx.mouseX or 0
    ctx.mouseY = ctx.mouseY or 0

    if script.prerun then
        local room = state.getSelectedRoom()
        ctx.mouseRoomX, ctx.mouseRoomY = ctx.mouseMapX - room.x, ctx.mouseMapY - room.y

        local prerunSnapshot = script.prerun(args, tool.layer, ctx)
        if prerunSnapshot then
            table.insert(snapshots, prerunSnapshot)
        end
    end

    if script.run then
        for _, room in ipairs(getTargetRooms()) do
            ctx.mouseRoomX, ctx.mouseRoomY = ctx.mouseMapX - room.x, ctx.mouseMapY - room.y

            local before = utils.deepcopy(room)
            script.run(room, args, ctx)
            local after = utils.deepcopy(room)

            local snapshot = snapshotUtils.roomSnapshot(room, "script_" .. (script.name or "unkScript") .. "_" .. room.name, before, after)
            table.insert(snapshots, snapshot)

            celesteRender.invalidateRoomCache(room.name)
        end
    end

    history.addSnapshot(snapshotUtils.multiSnapshot("script_multi_" .. (script.name or "unkScript"), snapshots))
end

function tool.safeExecScript(script, args, contextTable)
    local success, message = pcall(tool.execScript, script, args, contextTable)
    if not success then
        logging.warning(string.format("Failed to run script!"))
        logging.warning(debug.traceback(message))
        notifications.notify("Failed to run script!")
    end
end

local function indexofPos(table, pos)
    for i, value in ipairs(table) do
        if pos.x == value.x and pos.y == value.y then
            return i
        end
    end

    return -1
end

function tool.useScript(script, contextTable)
    if type(script) == "string" then
        script = tool.scripts[script]
    end

    if not script then return end

    if script.parameters then
        local storedPos = {
            x = contextTable.mouseMapX or 0,
            y = contextTable.mouseMapY or 0,
            color = scriptLocationPreviewColors[((#activeScriptPositions) % (#scriptLocationPreviewColors)) + 1]
        }

        table.insert(activeScriptPositions, storedPos)
        scriptParameterWindow.createContextMenu(script, tool.safeExecScript, contextTable, function()
            table.remove(activeScriptPositions, indexofPos(activeScriptPositions, storedPos))
        end)
    else
        tool.safeExecScript(script, {}, contextTable or {})
    end
end

function tool.setLayer(layer)
    if layer ~= tool.layer or not tool.scriptsAvailable then
        tool.layer = layer

        toolUtils.sendLayerEvent(tool, layer)
    end
end

function tool.setMaterial(material)
    if type(material) ~= "number" then
        tool.currentScript = material
    end
end

function tool.mouseclicked(x, y, button, istouch, pressed)
    local actionButton = configs.editor.toolActionButton

    if button == actionButton then
        local mx, my = viewportHandler.getMapCoordinates(x, y or 0)

        tool.useScript(tool.currentScript, {
            mouseX = x,
            mouseY = y,
            mouseMapX = mx,
            mouseMapY = my,
        })
    end
end

function tool.getMaterials(layer)
    return tool.scriptsAvailable
end

local function finalizeScript(handler, name, source, mod)
    handler.scriptsTool = tool
    handler.__mod = mod

    if configs.debug.logPluginLoading then
        logging.info("Loaded script '" .. name ..  "' [" .. mod .. "] " .. " from: " .. source)
    end


    addScript(name, handler.displayName, handler.tooltip, handler.__mod)
    tool.scripts[name] = handler

    return name
end

local function getModFromRelativePath(filename)
    local modFolder = string.sub(filename, 2, string.find(filename, "/") - 2)
    return utils.humanizeVariableName(modFolder):gsub(" Zip", "")
end

local function loadScript(filename)
    local pathNoExt = utils.stripExtension(filename)
    local filenameNoExt = utils.filename(pathNoExt, "/")

    --print(filename)
    local mod = getModFromRelativePath(filename)

    local handler = utils.rerequire(pathNoExt)

    return finalizeScript(handler, handler.name or filenameNoExt, filename, mod)
end

function tool.loadScripts()
    local filenames = modHandler.findPlugins("scripts")

    pluginLoader.loadPlugins(filenames, nil, loadScript, false)
end

function tool.load()
    tool.loadScripts()

    for key, value in pairs(scriptsLibrary.getCustomScripts()) do
        if utils.isFile(value) then
            local file = io.open(value)
            local l = file:read("*a")
            file:close()
            local handler = assert(loadstring(l))()
            handler.displayName = key

            finalizeScript(handler, key, value, "Custom")
        else
            -- just a string
            local handler = assert(loadstring(value))()
            handler.displayName = key
            finalizeScript(handler, key, value, "Custom")
        end
    end
end

local function drawPreviewRect(px, py)
    love.graphics.rectangle("line", px - 2.5, py - 2.5, 5, 5)
    love.graphics.rectangle("line", px, py, .1, .1)
end

function tool.draw()
    local room = state.getSelectedRoom()

    if room then
        local px, py = viewportHandler.getRoomCoordindates(room)

        drawing.callKeepOriginalColor(function()
            -- draw preview for the currently held script
            viewportHandler.drawRelativeTo(room.x, room.y, function()
                love.graphics.setColor(colors.brushColor)
                drawPreviewRect(px, py)
            end)

            -- draw previews for any active scripts
            viewportHandler.drawRelativeTo(0, 0, function()
                for i, pos in ipairs(activeScriptPositions) do
                    love.graphics.setColor(pos.color)
                    drawPreviewRect(pos.x, pos.y)
                end
            end)
        end)
    end
end

return tool