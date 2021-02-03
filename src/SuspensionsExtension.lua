---${title}

---@author ${author}
---@version r_version_r
---@date 28/11/2020

function Suspensions.getSuspensionModfiers(self)
    local spec = self.spec_suspensions
    local index = 1
    -- try to get the seat suspension, normally on index 2 (if no cabin suspension on index 1)
    if #spec.suspensionNodes >= 2 and not spec.suspensionNodes[2].useCharacterTorso then
        index = 2
    end

    local suspensionNode = spec.suspensionNodes[index]
    if suspensionNode ~= nil then
        if not suspensionNode.isRotational then
            return suspensionNode.curTranslation
        end
    end

    return {0, 0, 0}
end
