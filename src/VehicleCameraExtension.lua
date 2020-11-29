--
-- ${title}
--
-- @author ${author}
-- @version ${version}
-- @date 27/11/2020

VehicleCameraExtension = {}
VehicleCameraExtension.enabled = true

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
    if self.camSuspension ~= nil and self.camSuspension.enabled and VehicleCameraExtension.enabled then
        self.camSuspension.targetOffset = Suspensions.getSuspensionModfiers(self.vehicle)
        self.camSuspension.targetOffset[1] = self.camSuspension.targetOffset[1] * 0.9
        self.camSuspension.targetOffset[2] = self.camSuspension.targetOffset[2] * 0.9
        self.camSuspension.targetOffset[3] = self.camSuspension.targetOffset[3] * 0.9

        self.camSuspension.offset[1], self.camSuspension.offset[2], self.camSuspension.offset[3] =
            self:getSmoothed(
            self.camSuspension.positionSmoothingParameter,
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

        if g_gameSettings:getValue("isHeadTrackingEnabled") and isHeadTrackingAvailable() and self.allowHeadTracking and self.headTrackingNode ~= nil then
            local tx, ty, tz = getTranslation(self.cameraNode)
            setTranslation(self.cameraNode, tx + self.camSuspension.offset[1], ty + self.camSuspension.offset[2], tz + self.camSuspension.offset[3])
        end

        self.transDirX = oldTransDirX
        self.transDirY = oldTransDirY
        self.transDirZ = oldTransDirZ

        self.camSuspension.lastTargetOffset[1], self.camSuspension.lastTargetOffset[2], self.camSuspension.lastTargetOffset[3] = self.camSuspension.targetOffset[1], self.camSuspension.targetOffset[2], self.camSuspension.targetOffset[3]
    else
        if self.camSuspension ~= nil and self.camSuspension.enabled then
            self.camSuspension.lastTargetOffset = {0, 0, 0}
            self.camSuspension.offset = {0, 0, 0}
        end
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
        if self.vehicle.spec_suspensions.suspensionNodes[index] ~= nil and self.vehicle.spec_suspensions.suspensionNodes[index].node ~= nil then
            local suspensionNode = self.vehicle.spec_suspensions.suspensionNodes[index].node
            if not Utility.isChildOf(self.cameraPositionNode, suspensionNode) then
                self.camSuspension.enabled = true
                if self.positionSmoothingParameter > 0 then
                    self.camSuspension.positionSmoothingParameter = self.positionSmoothingParameter * 0.9
                else
                    self.camSuspension.positionSmoothingParameter = 0.128 * 0.9
                end
            end
        end
    end
end
