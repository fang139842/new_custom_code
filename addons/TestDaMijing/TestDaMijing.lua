print("Finished loading DifficultyLevels.lua!")
if not DaMijing_AddonDB then
    DaMijing_AddonDB = {}
end
local frame = CreateFrame("Frame")

function OnMythicPlusSelected(difficulty)
    if difficulty == MYTHIC_PLUS_DIFFICULTIES[1].text then
        DaMijing_AddonDB.selectedDifficulty = "MYTHIC_PLUS1"
    elseif difficulty == MYTHIC_PLUS_DIFFICULTIES[2].text then
        DaMijing_AddonDB.selectedDifficulty = "MYTHIC_PLUS2"
    elseif difficulty == MYTHIC_PLUS_DIFFICULTIES[3].text then
        DaMijing_AddonDB.selectedDifficulty = "MYTHIC_PLUS3"
    elseif difficulty == MYTHIC_PLUS_DIFFICULTIES[4].text then
        DaMijing_AddonDB.selectedDifficulty = "MYTHIC_PLUS4"
    end
    SendChatMessage(".set mythicplus " .. DaMijing_AddonDB.selectedDifficulty, "GUILD")
end

local function ModifyUnitPopupMenus()
    for _, item in pairs(UnitPopupMenus["SELF"]) do
        if item == "MYTHIC_PLUS" then
            return
        end
    end

    for index, item in pairs(UnitPopupMenus["SELF"]) do
        if item == "RAID_DIFFICULTY" then
            table.insert(UnitPopupMenus["SELF"], index + 1, "MYTHIC_PLUS")
            break
        end
    end
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        ModifyUnitPopupMenus() 
        UnitPopupButtons["MYTHIC_PLUS"] = { text = "大秘境", dist = 0, nested = 1 }

        UnitPopupButtons["MYTHIC_PLUS1"] = { text = MYTHIC_PLUS_DIFFICULTIES[1].text, dist = 0, checked = true }
        UnitPopupButtons["MYTHIC_PLUS2"] = { text = MYTHIC_PLUS_DIFFICULTIES[2].text, dist = 0 }
        UnitPopupButtons["MYTHIC_PLUS3"] = { text = MYTHIC_PLUS_DIFFICULTIES[3].text, dist = 0 }
        UnitPopupButtons["MYTHIC_PLUS4"] = { text = MYTHIC_PLUS_DIFFICULTIES[4].text, dist = 0 }
        UnitPopupMenus["MYTHIC_PLUS"] = { "MYTHIC_PLUS1", "MYTHIC_PLUS2", "MYTHIC_PLUS3", "MYTHIC_PLUS4" };
        hooksecurefunc("UnitPopup_ShowMenu", ModifyUnitPopupMenus)

        if DaMijing_AddonDB.selectedDifficulty and UnitPopupButtons[DaMijing_AddonDB.selectedDifficulty] then
            print("初始化成功")
            UnitPopupButtons[DaMijing_AddonDB.selectedDifficulty].check = true
            -- ... 可能还需要其他代码来更新UI ...
        end
    end
end)

hooksecurefunc("UnitPopup_OnClick", function(self)
    local button = _G[self:GetName()]
    local buttonText = button:GetText()

    -- 清除所有的check属性
    for _, item in pairs(UnitPopupMenus["MYTHIC_PLUS"]) do
        UnitPopupButtons[item].check = false
    end

    -- 根据点击的按钮设置check属性
    if buttonText == MYTHIC_PLUS_DIFFICULTIES[1].text then
        UnitPopupButtons["MYTHIC_PLUS1"].check = true
    elseif buttonText == MYTHIC_PLUS_DIFFICULTIES[2].text then
        UnitPopupButtons["MYTHIC_PLUS2"].check = true
    elseif buttonText == MYTHIC_PLUS_DIFFICULTIES[3].text then
        UnitPopupButtons["MYTHIC_PLUS3"].check = true
    elseif buttonText == MYTHIC_PLUS_DIFFICULTIES[4].text then
        UnitPopupButtons["MYTHIC_PLUS4"].check = true
    end

    OnMythicPlusSelected(buttonText)
end)

-- 这个函数会在官方的UnitPopup_ShowMenu之后执行
local function CustomizeMythicPlusMenu(dropdownMenu, which, unit, name, userData)
    local MYTHIC_PLUS_OFFSET = 0; -- 初始值为0
    if which ~= "SELF" then       -- 我们只对SELF菜单感兴趣
        return
    end

    for i = 1, UIDROPDOWNMENU_MAXBUTTONS do -- 遍历所有菜单项
        local button = _G["DropDownList" .. UIDROPDOWNMENU_MENU_LEVEL .. "Button" .. i]
        local buttonText = button:GetText()

        -- 检查是否是您的“大秘境”难度
        if buttonText == "普通" or buttonText == "一般" or buttonText == "困难" or buttonText == "厄运" then
            -- 如果此难度在UnitPopupButtons中被标记为选中，则设置checked属性
            if UnitPopupButtons["MYTHIC_PLUS" .. (i - MYTHIC_PLUS_OFFSET)].check then -- 注意：您可能需要根据实际情况调整SOME_OFFSET的值
                button.checked = true
                _G[button:GetName() .. "Check"]:Show()                                -- 显示“√”图标
            else
                button.checked = false
                _G[button:GetName() .. "Check"]:Hide() -- 隐藏“√”图标
            end
        end
    end
end

-- hook到官方的UnitPopup_ShowMenu函数
hooksecurefunc("UnitPopup_ShowMenu", CustomizeMythicPlusMenu)
