--DifficultyData.lua

print("PlayerAttemptLoot")
local SMSG_VIRTUAL_KEYSTONE_INFO_LOOT = "SMSG_VIRTUAL_KEYSTONE_INFO_LOOT"
local SMSG_VIRTUAL_KEYSTONE_INFO_BAG  = "SMSG_VIRTUAL_KEYSTONE_INFO_BAG"
local HasRequestedKeystone = false  --是否已经拾取过物品

------------------------------      鼠标上拖动纹理      -----------------------------------

local CursorHideFrame = CreateFrame("Frame")
local customCursorHide = CreateFrame("Frame", nil, UIParent)
customCursorHide:SetSize(25, 25)
customCursorHide.texture = customCursorHide:CreateTexture(nil, "BACKGROUND")
customCursorHide.texture:SetAllPoints(customCursorHide)
--customCursorHide.texture:SetTexture("Interface\\ICONS\\INV_Belt_61")
customCursorHide:Hide()
local function UpdateCustomCursorPos()
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
   
    local xOffset = 12  -- 向右移动的像素值
    local yOffset = -12  -- 向下移动的像素值

    customCursorHide:SetPoint("CENTER", UIParent, "BOTTOMLEFT", (x + xOffset)/scale, (y + yOffset)/scale)

end
customCursorHide:SetScript("OnUpdate", UpdateCustomCursorPos)
local function CheckCursor()
    local type = GetCursorInfo()
    if type == "item" then
        ResetCursor() -- 先清除原始纹理
        customCursorHide:Show() -- 然后显示自定义纹理
    else
        customCursorHide:Hide()
    end
end
--使自定义纹理位于其他UI元素之上
customCursorHide:SetFrameStrata("TOOLTIP")
CursorHideFrame:SetScript("OnUpdate", CheckCursor)
local function HandleCursorUpdate()
    if GetCursorInfo() == "item" then
        SetCursor("") -- 尝试隐藏默认鼠标纹理
        ResetCursor()
    end
end

CursorHideFrame:RegisterEvent("CURSOR_UPDATE")
CursorHideFrame:SetScript("OnEvent", HandleCursorUpdate)

------------------------------      鼠标上拖动纹理      -----------------------------------

--初始化一个纹理数组来存储每个背包位置的纹理。
BagTextures                           = {}
for bag = 0, 4 do
    BagTextures[bag] = {}
    for slot = 1, GetContainerNumSlots(bag) do
        BagTextures[bag][slot] = nil
    end
end

local lootWindow = _G["PlayerAttemptLootFrame"]
lootWindow:Hide()

function LootWindowFrameClose(lootWindowName)
    local frame = _G[lootWindowName]
    frame:Hide()
end

local keystoneInfoText = lootWindow:CreateFontString(nil, "OVERLAY")
keystoneInfoText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
keystoneInfoText:SetPoint("TOP", 0, -10)

function RequestAddKeystoneToBag(keystoneId)
    if HasRequestedKeystone then
        return -- 提前退出，因为已经请求过了
    end
    if not keystoneId then
        print("Error: Keystone ID is nil.")
        return
    end
    SendChatMessage(".addkeystone " .. keystoneId, "GUILD")
    HasRequestedKeystone = true -- 标记请求已发出
end

local function UpdateLootWindow(IsLoot, keystoneId, mapId, name, difficulty, iconIdStr, GSR_Des)
    print("IsLoot= "..IsLoot)
    if IsLoot == tostring(1) then
        local buttonIcon = _G["PlayerAttemptLootButton1"]
        buttonIcon.keystoneId = keystoneId
        buttonIcon:HookScript("OnClick", function(self)
            RequestAddKeystoneToBag(self.keystoneId)
        end)
        local buttonIconTexture = _G["PlayerAttemptLootButton1Icon"]
        buttonIconTexture:SetTexture("Interface\\Icons\\" .. iconIdStr)

        local buttonText = _G["PlayerAttemptLootButton1Text"]
        buttonText:SetText(name)
        -- 添加鼠标悬停 (OnEnter) 和鼠标离开 (OnLeave) 脚本
        buttonIcon:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine("|TInterface\\Icons\\" .. iconIdStr .. ":20:20|t " .. name)
            GameTooltip:AddDoubleLine("秘境ID:", mapId)
            GameTooltip:AddDoubleLine("钥石ID:", keystoneId)
            GameTooltip:AddDoubleLine("秘境难度:", difficulty)           
            GameTooltip:AddLine(GSR_Des, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        buttonIcon:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        lootWindow:Show()
    else
        lootWindow:Hide()
        return;
    end
end

----------------当开始自动拾取或者按下了shift+右键拾取  最好不要开自动拾取，不是很稳定
local LootWindowframe = CreateFrame("Frame")
LootWindowframe:RegisterEvent("LOOT_OPENED")
LootWindowframe:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
    if event == "LOOT_OPENED" then
        -- 检查是否按下了Shift键或者是否开启了自动拾取
        if GetModifiedClick("AUTOLOOTTOGGLE") == "AUTOLOOT" or IsModifiedClick("AUTOLOOTTOGGLE") then
            print("拾取拾取拾取")
            -- 模拟点击按钮来触发它的OnClick脚本
            local buttonIcon = _G["PlayerAttemptLootButton1"]
            buttonIcon:Click()
        end
    end
end)


local function OnBagUpdate()
    -- 检查所有背包格子
    for bag = 0, 4 do
        local slotCount = GetContainerNumSlots(bag)
        for actualSlot = 1, slotCount do
            local itemID = GetContainerItemID(bag, actualSlot)
            if not itemID then
                ClearBagSlotTexture(bag, actualSlot)
            end
        end
    end
    -- 调用您之前提供的纹理更新函数
    UpdateBagTextures()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
    if event == "PLAYER_LOGIN" then
        ItemNamesToGUIDs = ItemNamesToGUIDs or {}
        MythicKeystones = MythicKeystones or {}
        -- 添加事件处理函数到每个背包按钮
        for bag = 0, 4 do
            for slot = 1, GetContainerNumSlots(bag) do
                local button = _G["ContainerFrame" .. bag + 1 .. "Item" .. slot]
                if button then
                    button:HookScript("PostClick", OnDaMiJingKey_DragStart)
                end
            end
        end
    end
    if event == "BAG_UPDATE" then
        OnBagUpdate()
    else
        if prefix then
            local opcode, message = strsplit(" ", prefix)
            --弹出拾取窗口时的显示信息
            if opcode == SMSG_VIRTUAL_KEYSTONE_INFO_LOOT then
                HasRequestedKeystone = false    --刚打开拾取窗口 标注未拾取
                -- 处理不包含itemGUID的数据包
                local IsLootStr, keystoneIdStr, mapIdStr, name, difficultyStr, iconIdStr, GSR_Des = strsplit(":", message)
                local IsLoot = tonumber(IsLootStr)
                local keystoneId = tonumber(keystoneIdStr)
                local mapId = tonumber(mapIdStr)
                local difficulty = tonumber(difficultyStr)
                -- 这里不使用itemGUID
                UpdateLootWindow(IsLootStr, keystoneId, mapId, name, difficulty, iconIdStr, GSR_Des)
    
                --拾取物品后的显示信息
            elseif opcode == SMSG_VIRTUAL_KEYSTONE_INFO_BAG then
                lootWindow:Hide()
    
                -- 处理包含itemGUID的数据包
                local itemGUIDStr, keystoneIdStr, mapIdStr, name, difficultyStr, iconIdStr, GSR_Des = strsplit(":", message)
    
                local itemGUID = itemGUIDStr
                local keystoneId = tonumber(keystoneIdStr)
                local mapId = tonumber(mapIdStr)
                local difficulty = tonumber(difficultyStr)
    
                -- 存储物品名称到物品GUID的映射
                ItemNamesToGUIDs[itemGUID] = itemGUID
    
                -- 存储钥石信息到 MythicKeystones 表格中
                if itemGUID then
                    ItemNamesToGUIDs[itemGUID] = keystoneId
                    MythicKeystones[itemGUID] = {
                        keystoneId = keystoneId,
                        mapId = mapId,
                        name = name,
                        difficulty = difficulty,
                        iconTexture = iconIdStr,
                        GSR_Des = GSR_Des
                    }
                end
            end
        end

    end
end)

-- 清理纹理函数
function ClearBagSlotTexture(bag, actualSlot)
    local buttonSlot = GetContainerNumSlots(bag) - actualSlot + 1
    local buttonName = "ContainerFrame" .. bag + 1 .. "Item" .. buttonSlot
    local button = _G[buttonName]
    
    if button then
        button:SetNormalTexture(nil)
    end
end



-- 把更改背包纹理的代码放到一个单独的函数中，这样我们可以在多个地方调用它
function UpdateBagTextures()
    for bag = 0, 4 do
        local slotCount = GetContainerNumSlots(bag) -- 获取该背包的格子数量

        for actualSlot = 1, slotCount do
            local itemID, _, _, _, _, _, itemLink = GetContainerItemInfo(bag, actualSlot)

            -- 检查itemLink是否是字符串，如果是，则继续后续处理
            if type(itemLink) == "string" then
                local enchantID = itemLink:match("Hitem:%d+:(%d+)")
                local info = MythicKeystones[enchantID]

                if info then
                    local buttonSlot = slotCount - actualSlot + 1
                    local buttonName = "ContainerFrame" .. bag + 1 .. "Item" .. buttonSlot
                    local button = _G[buttonName]

                    if button then
                        local newTexturePath = "Interface\\Icons\\" .. info.iconTexture
                        --print("找到背包按钮:", buttonName)

                        -- 设置纹理
                        button:SetNormalTexture(newTexturePath)

                        -- 获取纹理并设置其尺寸
                        local texture = button:GetNormalTexture()
                        local buttonWidth = button:GetWidth()
                        local buttonHeight = button:GetHeight()
                        texture:SetWidth(buttonWidth)
                        texture:SetHeight(buttonHeight)

                        --print("纹理已设置")
                    else
                       -- print("未找到背包按钮:", buttonName)
                    end
                end
            end
        end
    end
end

-------------------------提示框动画特效变量------------------------
local currentFrame      = 0
local totalFrames       = 16             -- 动画图片张数
local animationSpeed    = 0.1           -- 动画速度，每0.1秒更换一帧
local elapsedTime       = 0

-------------------------贪吃蛇动画特效变量------------------------
local speed             = 10            -- 移动速度
local textureQueue      = {}            -- 用于存放纹理的位置的队列
local maxTrail          = 80            -- 跑马灯纹理数量
local distanceBetweenTextures = 1       -- 每个纹理之间的像素距离
local distanceSinceLastTexture = 0

-- 当物品按钮被点击后调用的函数
function OnDaMiJingKey_DragStart(button)
    --print("进入OnDaMiJingKey_DragStart")
    local bag = button:GetParent():GetID()
    local slot = button:GetID()
    local _, _, _, _, _, _, itemLink, _ = GetContainerItemInfo(bag, slot)

    if itemLink then
        local keystoneId = itemLink:match("Hitem:%d+:(%d+)")
        local info = MythicKeystones[keystoneId]
        
        if info then
            local newTexturePath = "Interface\\Icons\\" .. info.iconTexture

            -- 设置鼠标上的自定义纹理
            customCursorHide.texture:SetTexture(newTexturePath)
            
            -- 如果您仍然想要设置鼠标的纹理为该物品的默认纹理，您可以保留下面的代码。
            -- 否则，您可以选择移除它
            SetCursor("item:" .. itemLink:match("Hitem:(%d+):"))
        else
            -- 这里是新添加的代码，当点击一个非自定义物品时，重置鼠标纹理
            ResetCursor()
            customCursorHide.texture:SetTexture(nil)
        end
    end
end

function OnDaMiJingKey_TooltipSetItem(tooltip, keystoneIdOverride)--加入可选参数，供新增拾取框调用
    -- 当不需要显示贪吃蛇效果时，清除已存在的纹理和OnUpdate事件
    if tooltip.texture then
        tooltip.texture:Hide()
        tooltip.texture = nil
    end
    if tooltip.borderTexture then
        tooltip.borderTexture:Hide()
        tooltip.borderTexture = nil
    end
    for i = 1, #textureQueue do
        if tooltip["trailTexture" .. i] then
            tooltip["trailTexture" .. i]:Hide()
            tooltip["trailTexture" .. i] = nil
        end
    end
    textureQueue = {} -- 重置队列
    tooltip:SetScript("OnUpdate", nil)

    local itemName, itemLink = tooltip:GetItem()

    local keystoneId = keystoneIdOverride or (itemLink and itemLink:match("Hitem:%d+:(%d+)"))
    if not keystoneId then return end

    local info = MythicKeystones[keystoneId]

    if info then
        tooltip:ClearLines()
        tooltip:AddLine("|TInterface\\Icons\\" .. info.iconTexture .. ":20:20|t " .. info.name)
        tooltip:AddDoubleLine("秘境ID:", info.mapId)
        tooltip:AddDoubleLine("钥石ID:", info.keystoneId)
        tooltip:AddDoubleLine("秘境难度:", MYTHIC_PLUS_DIFFICULTIES[info.difficulty].text)
        tooltip:AddLine(info.GSR_Des, 1, 1, 1, true)

        -- 动画特效 - 创建或获取纹理
        local texture = tooltip.texture or tooltip:CreateTexture(nil, "OVERLAY")
        tooltip.texture = texture
        texture:SetTexture(string.format("Interface\\AddOns\\TestDaMijing\\AnimFrame\\%05d", currentFrame))
        texture:SetSize(105, 80)
        texture:SetPoint("TOPRIGHT", tooltip, "TOPRIGHT", -25, -2)
        -- 贪吃蛇 - 创建一个纹理并设置其初始位置
        local borderTexture = tooltip.borderTexture or tooltip:CreateTexture("TooltipBorderAnim", "OVERLAY")
        tooltip.borderTexture = borderTexture
        borderTexture:SetTexture("Interface\\AddOns\\TestDaMijing\\img\\Line")
        borderTexture:SetSize(5, 5)
        borderTexture:SetPoint("TOPLEFT", tooltip, "TOPLEFT", 0, 0)

        local direction = "RIGHT" -- 初始方向

        -- 在OnUpdate事件中移动纹理和更新动态纹理
        tooltip:SetScript("OnUpdate", function(self, elapsed)
            elapsedTime = elapsedTime + elapsed

            -- 更新 动画特效 - 动态纹理
            if elapsedTime > animationSpeed then
                elapsedTime = 0
                currentFrame = currentFrame + 1
                if currentFrame > totalFrames then
                    currentFrame = 1
                end
                texture:SetTexture(string.format("Interface\\AddOns\\TestDaMijing\\AnimFrame\\%05d", currentFrame))
            end

            -- 更新 贪吃蛇 移动边框纹理
            local point, relativeTo, relativePoint, currentX, currentY = borderTexture:GetPoint()
            if direction == "RIGHT" then
                if currentX + speed + borderTexture:GetWidth() <= tooltip:GetWidth() then
                    borderTexture:SetPoint("TOPLEFT", tooltip, "TOPLEFT", currentX + speed, currentY)
                else
                    direction = "DOWN"
                    currentY = currentY - speed
                end
            end
            if direction == "DOWN" then
                if currentY - speed >= -tooltip:GetHeight() + borderTexture:GetHeight() then
                    borderTexture:SetPoint("TOPLEFT", tooltip, "TOPLEFT", currentX, currentY - speed)
                else
                    direction = "LEFT"
                    currentX = currentX - speed
                end
            end
            if direction == "LEFT" then
                if currentX - speed >= 0 then
                    borderTexture:SetPoint("TOPLEFT", tooltip, "TOPLEFT", currentX - speed, currentY)
                else
                    direction = "UP"
                    currentY = currentY + speed
                end
            end
            if direction == "UP" then
                if currentY + speed <= 0 then
                    borderTexture:SetPoint("TOPLEFT", tooltip, "TOPLEFT", currentX, currentY + speed)
                else
                    direction = "RIGHT"
                    currentX = currentX + speed
                end
            end

            distanceSinceLastTexture = distanceSinceLastTexture + speed

            if distanceSinceLastTexture >= distanceBetweenTextures then
                -- 将主纹理的当前位置添加到队列的前面
                table.insert(textureQueue, 1, { x = currentX, y = currentY })

                -- 如果队列的长度超过了我们希望的跟随纹理的数量
                if #textureQueue > maxTrail then
                    table.remove(textureQueue) -- 从队列的末尾删除一个位置
                end

                distanceSinceLastTexture = 0 -- 重置距离计数器
            end

            -- 为队列中的每个位置创建或更新纹理
            for i, position in ipairs(textureQueue) do
                local trailTexture = tooltip["trailTexture" .. i] or tooltip:CreateTexture(nil, "OVERLAY")
                tooltip["trailTexture" .. i] = trailTexture
                trailTexture:SetTexture("Interface\\AddOns\\TestDaMijing\\img\\Line")
                trailTexture:SetSize(5, 5)
                trailTexture:SetPoint("TOPLEFT", tooltip, "TOPLEFT", position.x, position.y)
            end
        end)

        tooltip:Show()
    end
end
GameTooltip:HookScript("OnTooltipSetItem", OnDaMiJingKey_TooltipSetItem)