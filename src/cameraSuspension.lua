--
-- ${title}
--
-- @author ${author}
-- @version ${version}
-- @date 27/11/2020

CameraSuspension = {}

addConsoleCommand("csToggleCameraSuspension", "Toggle camera suspension.", "consoleCommandToggleCameraSuspension", CameraSuspension)

InitRoyalUtility(Utils.getFilename("lib/utility/", g_currentModDirectory))

function CameraSuspension:loadMap()
end

function CameraSuspension:loadSavegame()
end

function CameraSuspension:saveSavegame()
end

function CameraSuspension:update(dt)
    if g_currentMission.controlledVehicle ~= nil and g_currentMission.controlledVehicle.camSuspensionNodes ~= nil then
        for _, node in pairs(g_currentMission.controlledVehicle.camSuspensionNodes) do
            DebugUtil.drawDebugReferenceAxisFromNode(node)
        end
    end
end

function CameraSuspension:mouseEvent(posX, posY, isDown, isUp, button)
end

function CameraSuspension:keyEvent(unicode, sym, modifier, isDown)
end

function CameraSuspension:draw()
end

function CameraSuspension:delete()
end

function CameraSuspension:deleteMap()
end

function CameraSuspension:consoleCommandToggleCameraSuspension()
    VehicleCameraExtension.enabled = not VehicleCameraExtension.enabled
    print("csToggleCameraSuspension = " .. tostring(VehicleCameraExtension.enabled))
end

addModEventListener(CameraSuspension)
