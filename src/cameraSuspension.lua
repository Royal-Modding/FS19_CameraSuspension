---${title}

---@author ${author}
---@version r_version_r
---@date 27/11/2020

InitRoyalMod(Utils.getFilename("lib/rmod/", g_currentModDirectory))
InitRoyalUtility(Utils.getFilename("lib/utility/", g_currentModDirectory))

CameraSuspension = RoyalMod.new(r_debug_r)

function CameraSuspension:initialize()
    addConsoleCommand("csToggleCameraSuspension", "Toggle camera suspension.", "consoleCommandToggleCameraSuspension", self)

    source(Utils.getFilename("SuspensionsExtension.lua", self.directory))
    source(Utils.getFilename("VehicleCameraExtension.lua", self.directory))
end

function CameraSuspension:consoleCommandToggleCameraSuspension()
    VehicleCameraExtension.enabled = not VehicleCameraExtension.enabled
    print("csToggleCameraSuspension = " .. tostring(VehicleCameraExtension.enabled))
end
