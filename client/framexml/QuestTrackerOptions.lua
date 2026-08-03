-- Quest Tracker Interface Options Panel
-- Reads/writes CVars only — never calls C++ directly.
-- Communicates via QuestTrackerReloadSettings(table) C++ function.

local function PushSettings()
    local s = {
        enabled       = GetCVar("wxTrackerEnabled") == "1",
        autoTrack     = GetCVar("wxTrackerAutoTrack") == "1",
        showCompleted = GetCVar("wxTrackerShowCompleted") == "1",
        showMarker    = GetCVar("wxTrackerShowMarker") == "1",
        markerStyle   = tonumber(GetCVar("wxTrackerMarkerStyle")) or 0,
        markerSize    = tonumber(GetCVar("wxTrackerMarkerSize")) or 1,
        fadeClose     = GetCVar("wxTrackerFadeClose") == "1",
        fadeDist      = tonumber(GetCVar("wxTrackerFadeDist")) or 10,
        showThrough   = GetCVar("wxTrackerShowThrough") == "1",
        animated      = GetCVar("wxTrackerAnimated") == "1",
        showDistance  = GetCVar("wxTrackerShowDistance") == "1",
        distUnits     = tonumber(GetCVar("wxTrackerDistUnits")) or 1,
        fontSize      = tonumber(GetCVar("wxTrackerFontSize")) or 14,
        fontOutline   = GetCVar("wxTrackerFontOutline") == "1",
        alpha         = tonumber(GetCVar("wxTrackerAlpha")) or 160,
        debug         = GetCVar("wxTrackerDebug") == "1",
    }
    -- Update Lua globals for the renderer script
    wxqmEnabled = s.enabled
    wxqmShowDistance = s.showDistance
    wxqmMarkerAlpha = s.alpha
    -- Push to C++
    QuestTrackerReloadSettings(s)
end

function QuestTrackerPushSettings()
    PushSettings()
end

local function RefreshControls()
    WXTrackerEnabled:SetChecked(GetCVar("wxTrackerEnabled") == "1")
    WXTrackerAutoTrack:SetChecked(GetCVar("wxTrackerAutoTrack") == "1")
    WXTrackerShowCompleted:SetChecked(GetCVar("wxTrackerShowCompleted") == "1")
    WXTrackerShowMarker:SetChecked(GetCVar("wxTrackerShowMarker") == "1")
    WXTrackerFadeClose:SetChecked(GetCVar("wxTrackerFadeClose") == "1")
    WXTrackerShowThrough:SetChecked(GetCVar("wxTrackerShowThrough") == "1")
    WXTrackerAnimated:SetChecked(GetCVar("wxTrackerAnimated") == "1")
    WXTrackerShowDistance:SetChecked(GetCVar("wxTrackerShowDistance") == "1")
    WXTrackerFontOutline:SetChecked(GetCVar("wxTrackerFontOutline") == "1")
end

function QuestTrackerOptionsPanel_OnLoad(self)
    self.name = "Quest Tracker"
    self.okay = function() end
    self.cancel = function()
        RefreshControls()
    end
    self.default = function()
        SetCVar("wxTrackerEnabled", "1")
        SetCVar("wxTrackerAutoTrack", "1")
        SetCVar("wxTrackerShowCompleted", "0")
        SetCVar("wxTrackerShowMarker", "1")
        SetCVar("wxTrackerMarkerStyle", "0")
        SetCVar("wxTrackerMarkerSize", "1")
        SetCVar("wxTrackerFadeClose", "0")
        SetCVar("wxTrackerFadeDist", "10")
        SetCVar("wxTrackerShowThrough", "0")
        SetCVar("wxTrackerAnimated", "0")
        SetCVar("wxTrackerShowDistance", "1")
        SetCVar("wxTrackerDistUnits", "1")
        SetCVar("wxTrackerFontSize", "14")
        SetCVar("wxTrackerFontOutline", "0")
        SetCVar("wxTrackerAlpha", "160")
        SetCVar("wxTrackerDebug", "0")
        RefreshControls()
        PushSettings()
    end
    self.refresh = function()
        RefreshControls()
    end
    InterfaceOptions_AddCategory(self)

    -- Wire controls
    WXTrackerEnabled:SetScript("OnClick", function()
        SetCVar("wxTrackerEnabled", WXTrackerEnabled:GetChecked() and "1" or "0")
        PushSettings()
    end)
    WXTrackerAutoTrack:SetScript("OnClick", function()
        SetCVar("wxTrackerAutoTrack", WXTrackerAutoTrack:GetChecked() and "1" or "0")
        PushSettings()
    end)
    WXTrackerShowCompleted:SetScript("OnClick", function()
        SetCVar("wxTrackerShowCompleted", WXTrackerShowCompleted:GetChecked() and "1" or "0")
        PushSettings()
    end)
    WXTrackerShowMarker:SetScript("OnClick", function()
        SetCVar("wxTrackerShowMarker", WXTrackerShowMarker:GetChecked() and "1" or "0")
        PushSettings()
    end)

    -- Marker Style dropdown
    local styleNames = { "Arrow", "Diamond", "Circle", "Custom" }
    UIDropDownMenu_SetWidth(WXTrackerMarkerStyle, 140)
    UIDropDownMenu_Initialize(WXTrackerMarkerStyle, function()
        for i, name in ipairs(styleNames) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.func = function()
                UIDropDownMenu_SetSelectedID(WXTrackerMarkerStyle, i)
                SetCVar("wxTrackerMarkerStyle", tostring(i - 1))
                PushSettings()
            end
            info.checked = tonumber(GetCVar("wxTrackerMarkerStyle") or 0) == (i - 1)
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetSelectedID(WXTrackerMarkerStyle, (tonumber(GetCVar("wxTrackerMarkerStyle")) or 0) + 1)

    -- Marker Size dropdown
    local sizeNames = { "Small", "Medium", "Large" }
    UIDropDownMenu_SetWidth(WXTrackerMarkerSize, 140)
    UIDropDownMenu_Initialize(WXTrackerMarkerSize, function()
        for i, name in ipairs(sizeNames) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.func = function()
                UIDropDownMenu_SetSelectedID(WXTrackerMarkerSize, i)
                SetCVar("wxTrackerMarkerSize", tostring(i - 1))
                PushSettings()
            end
            info.checked = tonumber(GetCVar("wxTrackerMarkerSize") or 1) == (i - 1)
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetSelectedID(WXTrackerMarkerSize, (tonumber(GetCVar("wxTrackerMarkerSize")) or 1) + 1)

    WXTrackerFadeClose:SetScript("OnClick", function()
        SetCVar("wxTrackerFadeClose", WXTrackerFadeClose:GetChecked() and "1" or "0")
        PushSettings()
    end)
    WXTrackerShowThrough:SetScript("OnClick", function()
        SetCVar("wxTrackerShowThrough", WXTrackerShowThrough:GetChecked() and "1" or "0")
        PushSettings()
    end)
    WXTrackerAnimated:SetScript("OnClick", function()
        SetCVar("wxTrackerAnimated", WXTrackerAnimated:GetChecked() and "1" or "0")
        PushSettings()
    end)
    WXTrackerShowDistance:SetScript("OnClick", function()
        SetCVar("wxTrackerShowDistance", WXTrackerShowDistance:GetChecked() and "1" or "0")
        PushSettings()
    end)

    -- Distance Units dropdown
    local unitNames = { "Meters", "Yards", "Auto" }
    UIDropDownMenu_SetWidth(WXTrackerDistUnits, 140)
    UIDropDownMenu_Initialize(WXTrackerDistUnits, function()
        for i, name in ipairs(unitNames) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.func = function()
                UIDropDownMenu_SetSelectedID(WXTrackerDistUnits, i)
                SetCVar("wxTrackerDistUnits", tostring(i - 1))
                PushSettings()
            end
            info.checked = tonumber(GetCVar("wxTrackerDistUnits") or 1) == (i - 1)
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetSelectedID(WXTrackerDistUnits, (tonumber(GetCVar("wxTrackerDistUnits")) or 1) + 1)

    -- Font Size dropdown
    local fontSizeNames = { "10", "12", "14", "16", "18", "20", "24" }
    UIDropDownMenu_SetWidth(WXTrackerFontSize, 140)
    UIDropDownMenu_Initialize(WXTrackerFontSize, function()
        for i, name in ipairs(fontSizeNames) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.func = function()
                UIDropDownMenu_SetSelectedID(WXTrackerFontSize, i)
                SetCVar("wxTrackerFontSize", name)
                PushSettings()
            end
            info.checked = tonumber(GetCVar("wxTrackerFontSize") or 14) == tonumber(name)
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetSelectedID(WXTrackerFontSize, (tonumber(GetCVar("wxTrackerFontSize")) or 14) == 10 and 1 or (tonumber(GetCVar("wxTrackerFontSize")) or 14) == 12 and 2 or (tonumber(GetCVar("wxTrackerFontSize")) or 14) == 14 and 3 or (tonumber(GetCVar("wxTrackerFontSize")) or 14) == 16 and 4 or (tonumber(GetCVar("wxTrackerFontSize")) or 14) == 18 and 5 or (tonumber(GetCVar("wxTrackerFontSize")) or 14) == 20 and 6 or 7)

    WXTrackerFontOutline:SetScript("OnClick", function()
        SetCVar("wxTrackerFontOutline", WXTrackerFontOutline:GetChecked() and "1" or "0")
        PushSettings()
    end)
end
