--
-- Royal Mod
--
-- @author Royal Modding
-- @version 1.0.1.0
-- @date 03/12/2020

---@class RoyalMod
---@field directory string mod directory
---@field userProfileDirectory string user profile directory
---@field name string mod name
---@field mod table g_modManager mod object
---@field version string mod version
---@field author string mod author
---@field modEnv table mod scripting environment
---@field gameEnv table game scripting environment
---@field super table mod super class
---@field debug boolean mod debug state
RoyalMod = {}

---@param debug boolean defines if debug is enabled
---@param mpSync boolean defines if mp sync is enabled
---@return RoyalMod
function RoyalMod.new(debug, mpSync)
    local mod = {}
    mod.directory = g_currentModDirectory
    mod.userProfileDirectory = getUserProfileAppPath()
    mod.name = g_currentModName
    mod.mod = g_modManager:getModByName(mod.name)
    mod.version = mod.mod.version
    mod.author = mod.mod.author
    mod.modEnv = getfenv()
    mod.gameEnv = getfenv(0)
    mod.super = {}
    mod.debug = debug

    if mod.debug then
        mod.gameEnv["g_showDevelopmentWarnings"] = true
    --mod.gameEnv["g_isDevelopmentConsoleScriptModTesting"] = true
    end

    mod.super.oldFunctions = {}

    mod.super.errorHandle = function(error)
        g_logManager:devError("RoyalMod caught it from %s (%s)", mod.name, mod.version)
        g_logManager:error(error)
    end

    mod.super.getSavegameDirectory = function()
        if g_currentMission ~= nil and g_currentMission.missionInfo ~= nil then
            if g_currentMission.missionInfo.savegameDirectory ~= nil then
                return string.format("%s/", g_currentMission.missionInfo.savegameDirectory)
            end

            if g_currentMission.missionInfo.savegameIndex ~= nil then
                return string.format("%ssavegame%d/", mod.userProfileDirectory, g_currentMission.missionInfo.savegameIndex)
            end
        end
        return mod.userProfileDirectory
    end

    if mpSync then
        mod.super.sync = Object:new(g_server ~= nil, g_client ~= nil, Class(nil, Object))

        mod.super.sync.writeStream = function(self, streamId)
            self:superClass().writeStream(self, streamId)
            if mod.onWriteStream ~= nil then
                xpcall(mod.onWriteStream, mod.super.errorHandle, mod, streamId)
            end
        end

        mod.super.sync.readStream = function(self, streamId)
            self:superClass().readStream(self, streamId)
            if mod.onReadStream ~= nil then
                xpcall(mod.onReadStream, mod.super.errorHandle, mod, streamId)
            end
        end

        mod.super.sync.updateTick = function(self, dt)
            self:superClass().updateTick(self, dt)
            if mod.onUpdateTick ~= nil then
                xpcall(mod.onUpdateTick, mod.super.errorHandle, mod, dt)
            end
        end

        mod.super.sync.writeUpdateStream = function(self, streamId, connection, dirtyMask)
            self:superClass().writeUpdateStream(self, streamId, connection, dirtyMask)
            if mod.onWriteUpdateStream ~= nil then
                xpcall(mod.onWriteUpdateStream, mod.super.errorHandle, mod, streamId, connection, dirtyMask)
            end
        end

        mod.super.sync.readUpdateStream = function(self, streamId, timestamp, connection)
            self:superClass().readUpdateStream(self, streamId, timestamp, connection)
            if mod.onReadUpdateStream ~= nil then
                xpcall(mod.onReadUpdateStream, mod.super.errorHandle, mod, streamId, timestamp, connection)
            end
        end
    end

    mod.super.loadMap = function(_, mapFile)
        if mod.onLoadMap ~= nil then
            xpcall(mod.onLoadMap, mod.super.errorHandle, mod, mod.mapNode, mapFile)
        end
    end

    mod.super.deleteMap = function(_)
        if mod.onDeleteMap ~= nil then
            xpcall(mod.onDeleteMap, mod.super.errorHandle, mod)
        end
    end

    mod.super.draw = function(_)
        if mod.onDraw ~= nil then
            xpcall(mod.onDraw, mod.super.errorHandle, mod)
        end
    end

    mod.super.update = function(_, dt)
        if mod.onUpdate ~= nil then
            xpcall(mod.onUpdate, mod.super.errorHandle, mod, dt)
        end
    end

    mod.super.mouseEvent = function(_, posX, posY, isDown, isUp, button)
        if mod.onMouseEvent ~= nil then
            xpcall(mod.onMouseEvent, mod.super.errorHandle, mod, posX, posY, isDown, isUp, button)
        end
    end

    mod.super.keyEvent = function(_, unicode, sym, modifier, isDown)
        if mod.onKeyEvent ~= nil then
            xpcall(mod.onKeyEvent, mod.super.errorHandle, mod, unicode, sym, modifier, isDown)
        end
    end

    mod.super.oldFunctions.Mission00new = Mission00.new
    Mission00.new = function(self, baseDirectory, customMt, missionCollaborators)
        local global = mod.gameEnv["g_i18n"].texts
        for key, text in pairs(g_i18n.texts) do
            if global[key] == nil then
                global[key] = text
            end
        end
        if mod.initialize ~= nil then
            --- g_currentMission is still nil here
            --- All mods are loaded here
            xpcall(mod.initialize, mod.super.errorHandle, mod, baseDirectory, missionCollaborators)
        end
        return mod.super.oldFunctions.Mission00new(self, baseDirectory, customMt, missionCollaborators)
    end

    mod.super.oldFunctions.Mission00setMissionInfo = Mission00.setMissionInfo
    Mission00.setMissionInfo = function(self, missionInfo, missionDynamicInfo)
        g_currentMission:addLoadFinishedListener(mod.super)
        g_currentMission:registerObjectToCallOnMissionStart(mod.super)
        if mod.onSetMissionInfo ~= nil then
            --- g_currentMission is no more nil here
            xpcall(mod.onSetMissionInfo, mod.super.errorHandle, mod, missionInfo, missionDynamicInfo)
        end
        mod.super.oldFunctions.Mission00setMissionInfo(self, missionInfo, missionDynamicInfo)
    end

    mod.super.oldFunctions.Mission00load = Mission00.load
    Mission00.load = function(self)
        if mod.onLoad ~= nil then
            xpcall(mod.onLoad, mod.super.errorHandle, mod)
        end
        mod.super.oldFunctions.Mission00load(self)
    end

    mod.super.oldFunctions.FSBaseMissionloadMap = FSBaseMission.loadMap
    FSBaseMission.loadMap = function(self, mapFile, addPhysics, asyncCallbackFunction, asyncCallbackObject, asyncCallbackArguments)
        if mod.onPreLoadMap ~= nil then
            xpcall(mod.onPreLoadMap, mod.super.errorHandle, mod, mapFile)
        end
        mod.super.oldFunctions.FSBaseMissionloadMap(self, mapFile, addPhysics, asyncCallbackFunction, asyncCallbackObject, asyncCallbackArguments)
    end

    mod.super.oldFunctions.Mission00onCreateStartPoint = Mission00.onCreateStartPoint
    Mission00.onCreateStartPoint = function(self, startPointNode)
        mod.super.oldFunctions.Mission00onCreateStartPoint(self, startPointNode)
        if mod.super.sync ~= nil then
            g_currentMission:addOnCreateLoadedObject(mod.super.sync)
            mod.super.sync:register(true)
        end
        if mod.onCreateStartPoint ~= nil then
            xpcall(mod.onCreateStartPoint, mod.super.errorHandle, mod, startPointNode)
        end
    end

    mod.super.oldFunctions.BaseMissionloadMapFinished = BaseMission.loadMapFinished
    BaseMission.loadMapFinished = function(self, mapNode, arguments, callAsyncCallback)
        mod.mapNode = mapNode
        local mapFile, _, _, _ = unpack(arguments)
        mod.super.oldFunctions.BaseMissionloadMapFinished(self, mapNode, arguments, callAsyncCallback)
        if mod.onPostLoadMap ~= nil then
            xpcall(mod.onPostLoadMap, mod.super.errorHandle, mod, mapNode, mapFile)
        end
    end

    mod.super.oldFunctions.Mission00loadMission00Finished = Mission00.loadMission00Finished
    Mission00.loadMission00Finished = function(self, mapNode, arguments)
        if mod.onLoadSavegame ~= nil then
            xpcall(mod.onLoadSavegame, mod.super.errorHandle, mod, mod.super.getSavegameDirectory(), g_currentMission.missionInfo.savegameIndex)
        end
        mod.super.oldFunctions.Mission00loadMission00Finished(self, mapNode, arguments)
    end

    mod.super.oldFunctions.Mission00loadVehicles = Mission00.loadVehicles
    Mission00.loadVehicles = function(self, xmlFile, resetVehicles)
        if mod.onPreLoadVehicles ~= nil then
            xpcall(mod.onPreLoadVehicles, mod.super.errorHandle, mod, xmlFile, resetVehicles)
        end
        mod.super.oldFunctions.Mission00loadVehicles(self, xmlFile, resetVehicles)
    end

    mod.super.oldFunctions.Mission00loadItems = Mission00.loadItems
    Mission00.loadItems = function(self, xmlFile)
        if mod.onPreLoadItems ~= nil then
            xpcall(mod.onPreLoadItems, mod.super.errorHandle, mod, xmlFile)
        end
        mod.super.oldFunctions.Mission00loadItems(self, xmlFile)
    end

    mod.super.oldFunctions.Mission00loadOnCreateLoadedObjects = Mission00.loadOnCreateLoadedObjects
    Mission00.loadOnCreateLoadedObjects = function(self, xmlFile)
        if mod.onPreLoadOnCreateLoadedObjects ~= nil then
            xpcall(mod.onPreLoadOnCreateLoadedObjects, mod.super.errorHandle, mod, xmlFile)
        end
        mod.super.oldFunctions.Mission00loadOnCreateLoadedObjects(self, xmlFile)
    end

    mod.super.onLoadFinished = function()
        if mod.onLoadFinished ~= nil then
            xpcall(mod.onLoadFinished, mod.super.errorHandle, mod)
        end
    end

    mod.super.oldFunctions.Mission00onStartMission = Mission00.onStartMission
    Mission00.onStartMission = function(self)
        if mod.onStartMission ~= nil then
            xpcall(mod.onStartMission, mod.super.errorHandle, mod)
        end
        mod.super.oldFunctions.Mission00onStartMission(self)
    end

    mod.super.onMissionStarted = function(...)
        if mod.onMissionStarted ~= nil then
            xpcall(mod.onMissionStarted, mod.super.errorHandle, mod)
        end
    end

    mod.super.oldFunctions.Mission00delete = Mission00.delete
    Mission00.delete = function(self)
        if mod.onPreDeleteMap ~= nil then
            xpcall(mod.onPreDeleteMap, mod.super.errorHandle, mod)
        end
        mod.super.oldFunctions.Mission00delete(self)
    end

    mod.super.oldFunctions.FSBaseMissionsaveSavegame = FSBaseMission.saveSavegame
    FSBaseMission.saveSavegame = function(self)
        if mod.onPreSaveSavegame ~= nil then
            -- before all vhicles, items and onCreateObjects are saved
            xpcall(mod.onPreSaveSavegame, mod.super.errorHandle, mod, mod.super.getSavegameDirectory(), g_currentMission.missionInfo.savegameIndex)
        end
        mod.super.oldFunctions.FSBaseMissionsaveSavegame(self)
        if mod.onPostSaveSavegame ~= nil then
            -- after all vhicles, items and onCreateObjects are saved
            xpcall(mod.onPostSaveSavegame, mod.super.errorHandle, mod, mod.super.getSavegameDirectory(), g_currentMission.missionInfo.savegameIndex)
        end
    end

    addModEventListener(mod.super)
    return mod
end
