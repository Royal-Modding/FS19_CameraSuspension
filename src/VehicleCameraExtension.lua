--
-- ${title}
--
-- @author ${author}
-- @version ${version}
-- @date 27/11/2020

VehicleCameraExtension = {}

function VehicleCameraExtension:loadFromXML(superFunc, xmlFile, key)
    local ret = superFunc(self, xmlFile, key)
    if self.isInside then
        Utility.overwrittenFunction(self, "onActivate", VehicleCameraExtension.onActivate)
        Utility.overwrittenFunction(self, "update", VehicleCameraExtension.update)
        self.vehicle.camSuspensionNodes = {}
        self.camSuspension = {}
        self.camSuspension.enabled = false
        self.camSuspension.offset = {0, 0, 0}
        self.camSuspension.targetOffset = {0, 0, 0}
        self.camSuspension.lastTargetOffset = {0, 0, 0}
    end
    return ret
end
Utility.overwrittenFunction(VehicleCamera, "loadFromXML", VehicleCameraExtension.loadFromXML)

function VehicleCameraExtension:update(superFunc, dt)
    if self.camSuspension ~= nil and self.camSuspension.enabled then
        self.camSuspension.targetOffset = Suspensions.getSuspensionModfiers(self.vehicle)

        self.camSuspension.offset[1], self.camSuspension.offset[2], self.camSuspension.offset[3] =
            self:getSmoothed(
            self.positionSmoothingParameter,
            self.camSuspension.offset[1],
            self.camSuspension.offset[2],
            self.camSuspension.offset[3],
            self.camSuspension.targetOffset[1],
            self.camSuspension.targetOffset[2],
            self.camSuspension.targetOffset[3],
            self.camSuspension.lastTargetOffset[1],
            self.camSuspension.lastTargetOffset[2],
            self.camSuspension.lastTargetOffset[3],
            dt
        )

        local oldTransDirX = self.transDirX
        local oldTransDirY = self.transDirY
        local oldTransDirZ = self.transDirZ

        self.transDirX = self.transDirX + (self.camSuspension.offset[1] / self.zoom)
        self.transDirY = self.transDirY + (self.camSuspension.offset[2] / self.zoom)
        self.transDirZ = self.transDirZ + (self.camSuspension.offset[3] / self.zoom)

        superFunc(self, dt)

        self.transDirX = oldTransDirX
        self.transDirY = oldTransDirY
        self.transDirZ = oldTransDirZ

        self.camSuspension.lastTargetOffset[1], self.camSuspension.lastTargetOffset[2], self.camSuspension.lastTargetOffset[3] = self.camSuspension.targetOffset[1], self.camSuspension.targetOffset[2], self.camSuspension.targetOffset[3]
    else
        superFunc(self, dt)
    end
end

function VehicleCameraExtension:onActivate(superFunc)
    superFunc(self)
    if self.vehicle.spec_suspensions ~= nil and self.camSuspension ~= nil and not self.camSuspension.enabled then
        local index = 1
        -- try to get the seat suspension, normally on index 2 (if no cabin suspension on index 1)
        if #self.vehicle.spec_suspensions.suspensionNodes >= 2 and not self.vehicle.spec_suspensions.suspensionNodes[2].useCharacterTorso then
            index = 2
        end
        local suspensionNode = self.vehicle.spec_suspensions.suspensionNodes[index].node
        if not Utility.isChildOf(self.cameraPositionNode, suspensionNode) then
            self.camSuspension.enabled = true
        end
    end
end
