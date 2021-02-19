---${title}

---@author ${author}
---@version r_version_r
---@date 27/11/2020

InitRoyalMod(Utils.getFilename("lib/rmod/", g_currentModDirectory))
InitRoyalUtility(Utils.getFilename("lib/utility/", g_currentModDirectory))
InitRoyalSettings(Utils.getFilename("lib/rset/", g_currentModDirectory))

---@class CameraSuspension : RoyalMod
CameraSuspension = RoyalMod.new(r_debug_r)

function CameraSuspension:initialize()
    source(Utils.getFilename("SuspensionsExtension.lua", self.directory))
    source(Utils.getFilename("VehicleCameraExtension.lua", self.directory))
end

function CameraSuspension:onLoad()
    g_royalSettings:registerMod(self.name, self.directory .. "settings_icon.dds", "$l10n_cs_mod_settings_title")

    g_royalSettings:registerSetting(self.name, "enabled", g_royalSettings.TYPES.GLOBAL, g_royalSettings.OWNERS.USER, 1, {true, false}, {"$l10n_ui_on", "$l10n_ui_off"}, "$l10n_cs_setting_enabled", "$l10n_cs_setting_enabled_tooltip"):addCallback(
        self.onEnabledChange,
        self
    )
    g_royalSettings:registerSetting(
        self.name,
        "stiffness",
        g_royalSettings.TYPES.GLOBAL,
        g_royalSettings.OWNERS.USER,
        3,
        {1.1, 1, 0.9, 0.8, 0.6, 0.45, 0.35},
        {"50%", "75%", "100%", "125%", "150%", "175%", "200%"},
        "$l10n_cs_setting_stiffness",
        "$l10n_cs_setting_stiffness_tooltip"
    ):addCallback(self.onStiffnessChange, self)
end

function CameraSuspension:onEnabledChange(value)
    VehicleCameraExtension.enabled = value
end

function CameraSuspension:onStiffnessChange(value)
    VehicleCameraExtension.stiffness = value
end
