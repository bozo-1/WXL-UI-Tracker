#include "CustomInterface.hpp"

#include "runtime/LuaBindings.hpp"
#include "runtime/ModuleInstall.hpp"

namespace wxl::scripts::custominterface
{
    static void InstallModule()
    {
        wxl::runtime::lua::RegisterScript("wxl-custom-interface", R"lua(
            local triCats = {}
            local triTabReady = false

            -- Register a panel under the Custom tab
            function TriAddCategory(frame)
                if not frame or not frame.name then return end
                frame.okay = frame.okay or function() end
                frame.cancel = frame.cancel or function() end
                frame.default = frame.default or function() end
                frame.refresh = frame.refresh or function() end
                tinsert(triCats, frame)
                local list = _G["InterfaceOptionsFrameCustom"]
                if list and list.update then list.update() end
            end

            local function SetupCustomTab()
                if not InterfaceOptionsFrame or not InterfaceOptionsFrameTab1 then return end
                if InterfaceOptionsFrameTab3 then triTabReady = true; return end
                if triTabReady then return end
                triTabReady = true

                -- Bump to 3 tabs, create Tab3
                PanelTemplates_SetNumTabs(InterfaceOptionsFrame, 3)
                local tab3 = CreateFrame("Button", "InterfaceOptionsFrameTab3",
                    InterfaceOptionsFrame, "OptionsFrameTabButtonTemplate")
                tab3:SetPoint("TOPLEFT", InterfaceOptionsFrameTab1, "TOPRIGHT", -16, 0)
                tab3:SetID(3)
                tab3:SetText("Custom Features")
                tab3:SetScript("OnClick", function()
                    PlaySound("igCharacterInfoTab")
                    PanelTemplates_Tab_OnClick(this, InterfaceOptionsFrame)
                    PanelTemplates_UpdateTabs(InterfaceOptionsFrame)
                    InterfaceOptionsFrame_TabOnClick()
                end)
                tab3:Show()
                PanelTemplates_UpdateTabs(InterfaceOptionsFrame)

                -- Category list using native template
                local clist = CreateFrame("Frame", "InterfaceOptionsFrameCustom",
                    InterfaceOptionsFrame, "OptionsFrameListTemplate")
                clist:SetSize(175, 429)
                clist:SetPoint("TOPLEFT", 22, -40)
                clist.labelText = "Custom"
                OptionsList_OnLoad(clist, "InterfaceOptionsListButtonTemplate")
                clist.update = function()
                    local buttons = clist.buttons
                    for i = 1, #buttons do
                        local cat = triCats[i]
                        if not cat then
                            OptionsList_HideButton(buttons[i])
                        else
                            buttons[i].element = cat
                            OptionsList_DisplayButton(buttons[i], cat)
                        end
                    end
                end
                clist:Hide()

                -- Hook TabOnClick
                local origTab = InterfaceOptionsFrame_TabOnClick
                InterfaceOptionsFrame_TabOnClick = function()
                    local tab = InterfaceOptionsFrame.selectedTab
                    InterfaceOptionsFrameCategories:Hide()
                    InterfaceOptionsFrameAddOns:Hide()
                    if clist then clist:Hide() end
                    InterfaceOptionsFrameTab1TabSpacer:Hide()
                    InterfaceOptionsFrameTab2TabSpacer1:Hide()
                    InterfaceOptionsFrameTab2TabSpacer2:Hide()
                    if tab == 1 then
                        InterfaceOptionsFrameCategories:Show()
                        InterfaceOptionsFrameTab1TabSpacer:Show()
                    elseif tab == 2 then
                        InterfaceOptionsFrameAddOns:Show()
                        InterfaceOptionsFrameTab2TabSpacer1:Show()
                        InterfaceOptionsFrameTab2TabSpacer2:Show()
                    elseif tab == 3 and clist then
                        clist:Show()
                        clist.update()
                        if clist.buttons and clist.buttons[1] and clist.buttons[1].element then
                            clist.buttons[1]:Click()
                        end
                    end
                    -- Auto-navigate away from Custom panels when leaving tab 3
                    if tab ~= 3 and #triCats > 0 then
                        local dp = InterfaceOptionsFramePanelContainer.displayedPanel
                        if dp then
                            for _, cat in ipairs(triCats) do
                                if cat == dp then
                                    InterfaceOptionsFrame_OpenToCategory(CONTROLS_LABEL)
                                    break
                                end
                            end
                        end
                    end
                end

                -- Hook AddOns update to keep tabs visible
                local origAddon = InterfaceAddOnsList_Update
                InterfaceAddOnsList_Update = function()
                    origAddon()
                    InterfaceOptionsFrameTab1:Show()
                    InterfaceOptionsFrameTab3:Show()
                end

                -- Hook OnShow to keep tabs visible
                local origShow = InterfaceOptionsFrame_OnShow
                InterfaceOptionsFrame_OnShow = function(s)
                    origShow(s)
                    InterfaceOptionsFrameTab1:Show()
                    InterfaceOptionsFrameTab3:Show()
                end

                -- Hook lifecycle callbacks for custom panels
                local function RunAll(fn)
                    for _, cat in ipairs(triCats) do
                        if cat[fn] then pcall(cat[fn], cat) end
                    end
                end

                local origOkay = InterfaceOptionsFrameOkay_OnClick
                InterfaceOptionsFrameOkay_OnClick = function(self, b, a)
                    origOkay(self, b, a); RunAll("okay")
                end
                local origCancel = InterfaceOptionsFrameCancel_OnClick
                InterfaceOptionsFrameCancel_OnClick = function(self, b)
                    origCancel(self, b); RunAll("cancel")
                end
                local origDef = InterfaceOptionsFrame_SetAllToDefaults
                InterfaceOptionsFrame_SetAllToDefaults = function()
                    origDef(); RunAll("default")
                end
            end

            -- Retry until InterfaceOptionsFrame exists
            local wait = CreateFrame("Frame")
            local n = 0
            wait:SetScript("OnUpdate", function()
                n = n + 1
                SetupCustomTab()
                if triTabReady or n > 120 then
                    wait:SetScript("OnUpdate", nil)
                end
            end)
        )lua");
    }

    struct CIRegistrar
    {
        CIRegistrar() {
            wxl::runtime::modules::Register("wxl-custom-interface", &InstallModule);
        }
    } g_customInterfaceRegistrar;
}
