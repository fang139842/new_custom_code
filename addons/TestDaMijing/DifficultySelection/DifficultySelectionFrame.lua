---@diagnostic disable: deprecated, undefined-field
--DifficultySelectionFrame.lua
MaindifficultyButtons = {};      -- 用于存储主难度按钮的表
SubDifficultyFrames   = {};      -- 用于存储子难度按钮的表
MaindifficultyButtext = {};      -- 主难度按钮上方文本


print("DifficultySelectionFrame")
local mainFrame = CreateFrame("Frame", "MainFrame", UIParent)
mainFrame:SetSize(900, 500)
mainFrame:SetPoint("CENTER")

-- 在原有边框之上创建一个覆盖层纹理
local borderOverlay = mainFrame:CreateTexture(nil, "OVERLAY")
borderOverlay:SetAllPoints(mainFrame)
borderOverlay:SetTexture("Interface\\Buttons\\WHITE8x8") -- 游戏内置的单色纹理
borderOverlay:SetVertexColor(0, 0, 0, 0.5)               -- 设置覆盖层颜色和透明度以产生暗色边缘效果

mainFrame:SetBackdrop({
    bgFile = "Interface\\AddOns\\TestDaMijing\\img\\selection\\MainFrame",
    edgeFile = "Interface\\AddOns\\TestDaMijing\\img\\selection\\MainFrame-Border",
    tileSize = 10,
    edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})

-- 创建一个中间透明，边缘加深的覆盖纹理
local overlayTexture = mainFrame:CreateTexture(nil, "ARTWORK")
overlayTexture:SetSize(897, 497)
overlayTexture:SetPoint("CENTER")
overlayTexture:SetTexture("Interface\\AddOns\\TestDaMijing\\img\\selection\\MainFrame_ARTWORK") -- 这是边缘效果纹理

mainFrame:Hide()
local mainFrameHengXiantexture = mainFrame:CreateTexture(nil, "OVERLAY")
mainFrameHengXiantexture:SetPoint("TOP", 0, -50)
mainFrameHengXiantexture:SetTexture("Interface\\AddOns\\TestDaMijing\\img\\selection\\横线")
mainFrameHengXiantexture:SetSize(640, 3)

-- 添加标题
local titleText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
titleText:SetText("大秘境难度选择")
titleText:SetFont(DifficultyFonts, 16, "OUTLINE")
titleText:SetTextColor(255 / 255, 173 / 255, 105 / 255) --文本颜色
titleText:SetPoint("TOP", 0, -20)

mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)

--关闭按钮
local MainCloseButton = CreateFrame("Button", "MainCloseButton", mainFrame, "DifficultySelection_CloseButton")
MainCloseButton:SetPoint("TOPRIGHT", -5, -5)
function DifficultySelection_CloseButtonClick()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    end
end





local MainDifficultyNum = #MYTHIC_PLUS_DIFFICULTIES --获取主难度数量
local MainDifficultyButtWidth = 220                 --主难度按钮宽度
local MainDifficultyButtHeight = 220                --主难度按钮高度
local Spacing = -50                                 --主难度按钮间隔

--创建主难度按钮
for i = 1, MainDifficultyNum do
    local MainDifficultyBut = CreateFrame("Button", nil, mainFrame, nil, i)
    MainDifficultyBut:SetSize(MainDifficultyButtWidth, MainDifficultyButtHeight)

    MainDifficultyBut:SetDisabledTexture(MYTHIC_PLUS_DIFFICULTIES[i].Main_DISABLED) -- 设置禁用纹理

    if MainDifficultyNum % 2 == 0 then
        -- 偶数按钮
        local centerOffset = (MainDifficultyButtWidth + Spacing) * ((i - 1) - MainDifficultyNum / 2 + 0.5)
        MainDifficultyBut:SetPoint("CENTER", centerOffset, 25)
    else
        -- 奇数按钮
        local centerOffset = (MainDifficultyButtWidth + Spacing) * (i - (math.floor(MainDifficultyNum / 2) + 1))
        MainDifficultyBut:SetPoint("CENTER", centerOffset, 25)
    end

    -- 默认选中第一个"普通"难度的按钮
    local isDefaultSelected = (i == 1) -- 假设列表中第一个是"普通"难度

    -- 设置纹理
    local texture = MainDifficultyBut:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints()
    texture:SetTexture(MYTHIC_PLUS_DIFFICULTIES[i].Main_BACKGROUND)
    MainDifficultyBut.texture = texture

    --设置高光纹理
    local highlightTexture = MainDifficultyBut:CreateTexture(nil, "HIGHLIGHT")
    highlightTexture:SetAllPoints()
    highlightTexture:SetTexture(MYTHIC_PLUS_DIFFICULTIES[i].Main_HIGHLIGHT)
    highlightTexture:Hide() -- 初始情况下隐藏高光纹理
    MainDifficultyBut.highlightTexture = highlightTexture

    --设置按下纹理
    local pressedTexture = MainDifficultyBut:CreateTexture(nil, "ARTWORK")
    pressedTexture:SetAllPoints()
    pressedTexture:SetTexture(MYTHIC_PLUS_DIFFICULTIES[i].Main_ARTWORK)
    pressedTexture:Hide() -- 初始情况下隐藏按下纹理
    MainDifficultyBut.pressedTexture = pressedTexture

    --按钮的选中纹理
    local selectedTexture = MainDifficultyBut:CreateTexture(nil, "ARTWORK")
    selectedTexture:SetAllPoints()
    selectedTexture:SetTexture(MYTHIC_PLUS_DIFFICULTIES[i].Main_ARTWORK)
    selectedTexture:Hide() -- 初始时隐藏选中纹理
    MainDifficultyBut.selectedTexture = selectedTexture

    ---------------------------设置默认选中第一个按钮----------------------------
    -- if isDefaultSelected then
    --     MainDifficultyBut.selectedTexture:Show() -- 显示选中纹理
    --     MainDifficultyBut.isSelected = true      -- 标记按钮为已选中
    -- else
    --     MainDifficultyBut.selectedTexture:Hide() -- 隐藏选中纹理
    --     MainDifficultyBut.isSelected = false     -- 标记按钮为未选中
    -- end


    ---------------------------设置默认选中第一个按钮----------------------------

    -- 检查难度，如果不是“普通”，则禁用该按钮
    -- if MYTHIC_PLUS_DIFFICULTIES[i].text ~= "普通" then
    --     MainDifficultyBut:Disable()                                   -- 禁用按钮
    --     texture:SetTexture(MYTHIC_PLUS_DIFFICULTIES[i].Main_DISABLED) -- 设置禁用时的纹理
    -- else
    --     MainDifficultyBut:Enable()                                    -- 启用“普通”难度按钮
    -- end

    --按钮功能事件
    MainDifficultyBut:SetScript("OnClick", function(self)
        for _, otherBtn in pairs(MaindifficultyButtons) do
            otherBtn.selectedTexture:Hide()                                       -- 隐藏其他所有按钮的选中纹理
            otherBtn.isSelected = false                                           -- 标记其他所有按钮为未选中
            otherBtn:SetSize(MainDifficultyButtWidth, MainDifficultyButtHeight)   -- 设置其他按钮为默认大小
        end
        self.selectedTexture:Show()                                               -- 显示当前按钮的选中纹理
        self.isSelected = true                                                    -- 标记当前按钮为已选中
        self:SetSize(MainDifficultyButtWidth + 10, MainDifficultyButtHeight + 10) -- 当前被点击的按钮变大

        ShowSubDifficulties(i)                                                    -- 显示子难度按钮

        -- 获取当前难度的颜色
        local difficultyIndex = self:GetID() -- 假设按钮的 ID 已经设置为它们在 MYTHIC_PLUS_DIFFICULTIES 中的索引
        local difficultyData = MYTHIC_PLUS_DIFFICULTIES[difficultyIndex]

        if difficultyData then
            local color = difficultyData.color
            local BGFile = difficultyData.BGFile
            if color then
                -- 应用颜色到覆盖纹理
                TranslucentFrametex:SetVertexColor(unpack(color)) --  右下角奖励纹理改变颜色

                borderOverlay:SetVertexColor(unpack(color))       --  将覆盖层纹理改变颜色
                -- 重新设置背景和边桜
                mainFrame:SetBackdrop({
                    bgFile = BGFile,
                    edgeFile = "Interface\\AddOns\\TestDaMijing\\img\\selection\\MainFrame-Border", -- 保留之前的边桜定义
                    tileSize = 10,
                    edgeSize = 10,
                    insets = { left = 2, right = 2, top = 2, bottom = 2 }
                })
            else
                print("No color found for difficulty ID:", difficultyIndex)
            end
        else
            print("No difficulty data found for ID:", difficultyIndex)
        end
    end)
    --鼠标移入事件
    MainDifficultyBut:SetScript("OnEnter", function(self)
        self.highlightTexture:Show()
    end)

    --鼠标移出事件
    MainDifficultyBut:SetScript("OnLeave", function(self)
        self.highlightTexture:Hide()
    end)

    --鼠标放开事件
    MainDifficultyBut:SetScript("OnMouseUp", function(self)
        self.pressedTexture:Hide()
    end)

    --上方难度文本
    MainDifficultyBut.BtnTexFrame = CreateFrame("Frame", "BtnTexFrame", MainDifficultyBut)
    MainDifficultyBut.BtnTexFrame:SetPoint("TOP", 0, 20)
    MainDifficultyBut.BtnTexFrame:SetSize(150, 35)
    MainDifficultyBut.BtnTexFrame.tex = MainDifficultyBut.BtnTexFrame:CreateTexture()
    MainDifficultyBut.BtnTexFrame.tex:SetAllPoints(MainDifficultyBut.BtnTexFrame)
    MainDifficultyBut.BtnTexFrame.tex:SetTexture("Interface\\AddOns\\TestDaMijing\\img\\selection\\主难度文本框")

    MainDifficultyBut.BtnTexFrame.text = MainDifficultyBut.BtnTexFrame:CreateFontString("$parent" .. "TitleText", "ARTWORK", "GameFontNormal") -- 创建功能介绍
    MainDifficultyBut.BtnTexFrame.text:SetFont(DifficultyFonts, 10, "OUTLINE")
    --MainDifficultyBut.BtnTexFrame.text:SetText(MYTHIC_PLUS_DIFFICULTIES[i].text)
    MainDifficultyBut.BtnTexFrame.text:SetTextColor(255 / 255, 173 / 255, 105 / 255) --文本颜色
    MainDifficultyBut.BtnTexFrame.text:SetJustifyH("center")                         -- 水平对齐
    MainDifficultyBut.BtnTexFrame.text:SetJustifyV("center")                         -- 垂直对齐
    MainDifficultyBut.BtnTexFrame.text:SetSize(200, 230);
    MainDifficultyBut.BtnTexFrame.text:SetPoint("CENTER", 0, 8)


    table.insert(MaindifficultyButtons, MainDifficultyBut)

end

-----------------------------------------子难度滑动框-----------------------------------------
local subDiffCount         --  子难度数量
SubWidth             = 60; --  子难度按钮宽度
SubHeight            = 90; --  子难度按钮高度
Subpacing            = 0;  --  子难度按钮间距
local visibleButtons = 10  --  子难度按钮显示数量

local visibleWidth   = visibleButtons * SubWidth + (visibleButtons - 1) * Subpacing

-- 创建一个滚动框架来容纳子难度按钮
local ScrollFrame    = CreateFrame("ScrollFrame", nil, mainFrame)
ScrollFrame:SetSize(visibleWidth, SubHeight) -- 这个大小需要根据你的UI来调整
ScrollFrame:SetPoint("BOTTOMLEFT", 50, 70)
ScrollFrame:EnableMouseWheel(true)           --响应鼠标滚轮滚动事件

ScrollFrame:SetScript("OnMouseWheel", function(self, delta)
    local currentScroll = self:GetHorizontalScroll()
    local scrollAmount = SubWidth + Subpacing -- 滚动一个完整的按钮宽度

    -- delta > 0 表示向上滚动，delta < 0 表示向下滚动
    if delta > 0 then
        self:SetHorizontalScroll(math.max(0, currentScroll - scrollAmount))
    else
        local maxScroll = (subDiffCount - visibleButtons) * (SubWidth + Subpacing)
        self:SetHorizontalScroll(math.min(maxScroll, currentScroll + scrollAmount))
    end
end)

-- 设置子难度滚动框架的OnUpdate事件处理器
ScrollFrame:SetScript("OnUpdate", function()
    local currentScroll = ScrollFrame:GetHorizontalScroll()
    local remainder = currentScroll % (SubWidth + Subpacing)
    -- 判断滚动位置是否在按钮的中间
    if remainder > 0 and remainder < SubWidth then
        if remainder > SubWidth / 2 then
            -- 如果接近下一个按钮，向前移动滚动位置
            ScrollFrame:SetHorizontalScroll(currentScroll + (SubWidth - remainder))
        else
            -- 否则，向后移动滚动位置
            ScrollFrame:SetHorizontalScroll(currentScroll - remainder)
        end
    end
end)

-- 子难度上的时间框架
local SubDiffTimeFrame = CreateFrame("Frame", nil)
SubDiffTimeFrame:SetSize(40, 28)
SubDiffTimeFrame.tex = SubDiffTimeFrame:CreateTexture()
SubDiffTimeFrame.tex:SetAllPoints(SubDiffTimeFrame)
SubDiffTimeFrame.tex:SetTexture("Interface\\AddOns\\TestDaMijing\\img\\selection\\时间底框纹理")
SubDiffTimeFrame:Hide(); --默认隐藏

-- 右下侧奖励框架
local RewFrame = CreateFrame("Frame", nil, mainFrame)
RewFrame:SetSize(200, 30)
RewFrame:SetPoint("BOTTOMRIGHT", -20, 150)
RewFrame.tex = RewFrame:CreateTexture()
RewFrame.tex:SetAllPoints(RewFrame)
RewFrame.tex:SetTexture("Interface\\AddOns\\TestDaMijing\\img\\selection\\奖励抬头纹理")
-- 右下侧奖励框架文本
RewFrame.text = RewFrame:CreateFontString("$parent" .. "TitleText", "ARTWORK", "GameFontNormal") -- 创建功能介绍
RewFrame.text:SetFont(DifficultyFonts, 12, "OUTLINE")
RewFrame.text:SetText("奖   励")
RewFrame.text:SetTextColor(255 / 255, 173 / 255, 105 / 255) --文本颜色
RewFrame.text:SetJustifyH("center")                         -- 水平对齐
RewFrame.text:SetJustifyV("center")                         -- 垂直对齐
RewFrame.text:SetSize(200, 230);
RewFrame.text:SetPoint("CENTER", 0, 0)

-- 奖励半透明框体
local TranslucentFrame = CreateFrame("Frame", nil, RewFrame)
TranslucentFrame:SetSize(180, 130)                         -- 宽度与 RewFrame 相同，高度为100
TranslucentFrame:SetPoint("TOP", RewFrame, "BOTTOM", 0, 0) -- 将新框体定位在 RewFrame 的正下方

-- 为新框体创建纹理并设置为半透明
TranslucentFrametex = TranslucentFrame:CreateTexture(nil, "BACKGROUND")
TranslucentFrametex:SetAllPoints(TranslucentFrame)
TranslucentFrametex:SetTexture(1, 1, 1, 1) -- 设置RGBA(0, 0, 0, 0.5)

-- 计算四个物品按钮及其间隙的总宽度
local RewItemButtonSpacing = -5                                       -- 按钮间隙
local RewItemButtonTotalWidth = (4 * 45) + (3 * RewItemButtonSpacing) -- 4个按钮的宽度加上它们之间的间隙
local RewItemButtonStartX = (180 - RewItemButtonTotalWidth) / 2       -- 计算第一个按钮的起始X坐标

-- 创建第一行的按钮并使其居中
for i = 1, 4 do
    local RewItemButton = CreateFrame("Button", nil, TranslucentFrame)
    RewItemButton:SetSize(42, 42)
    local xOffset = RewItemButtonStartX + (i - 1) * (45 + RewItemButtonSpacing) -- 计算每个按钮的X坐标偏移量
    RewItemButton:SetPoint("TOPLEFT", TranslucentFrame, "TOPLEFT", xOffset, -5)
    local portraitTexture = RewItemButton:CreateTexture(nil, "OVERLAY")
    portraitTexture:SetAllPoints(RewItemButton)
    portraitTexture:SetTexture("Interface\\AddOns\\TestDaMijing\\img\\selection\\RewFrame\\奖励按钮_普通")
end

-- 物品奖励和Buff中间的隔断线条
local RewPartitionBuffFrame = CreateFrame("Frame", nil, TranslucentFrame)
RewPartitionBuffFrame:SetSize(165, 1)
RewPartitionBuffFrame:SetPoint("CENTER", 0, 10)
RewPartitionBuffFrame.tex = RewPartitionBuffFrame:CreateTexture()
RewPartitionBuffFrame.tex:SetAllPoints(RewPartitionBuffFrame)
RewPartitionBuffFrame.tex:SetTexture("Interface\\AddOns\\TestDaMijing\\img\\selection\\奖励横线隔断")
-- 隔断线条下的Buff文本
RewPartitionBuffFrame.text = RewPartitionBuffFrame:CreateFontString("$parent" .. "TitleText", "ARTWORK", "GameFontNormal") -- 创建功能介绍
RewPartitionBuffFrame.text:SetFont(DifficultyFonts, 12, "OUTLINE")
RewPartitionBuffFrame.text:SetText("秘境Buff")
RewPartitionBuffFrame.text:SetTextColor(255 / 255, 173 / 255, 105 / 255) --文本颜色
RewPartitionBuffFrame.text:SetJustifyH("left")                           -- 水平对齐
RewPartitionBuffFrame.text:SetJustifyV("center")                         -- 垂直对齐
RewPartitionBuffFrame.text:SetSize(200, 230);
RewPartitionBuffFrame.text:SetPoint("LEFT", 0, -10)

-- 计算四个BUFF按钮及其间隙的总宽度
local BuffButtonSpacing = 10                                    --  按钮间隙
local BuffButtonTotalWidth = (4 * 30) + (3 * BuffButtonSpacing) --  4个按钮的宽度加上它们之间的间隙
local BuffButtonStartX = (180 - BuffButtonTotalWidth) / 2       --  计算第一个按钮的起始X坐标


-- 创建第二行的圆形按钮
-- 创建带有颜色边框的buff按钮
for i = 1, 4 do
    local BuffButton = CreateFrame("Button", nil, TranslucentFrame)
    BuffButton:SetSize(35, 35)
    local xOffset = BuffButtonStartX + (i - 1) * (30 + BuffButtonSpacing)
    BuffButton:SetPoint("TOPLEFT", TranslucentFrame, "TOPLEFT", xOffset, -85)

    -- 为按钮创建一个边框纹理
    local borderTexture = BuffButton:CreateTexture(nil, "OVERLAY")
    borderTexture:SetAllPoints(BuffButton)
    borderTexture:SetTexture("Interface\\AddOns\\TestDaMijing\\img\\selection\\RewFrame\\BUFF_边框") -- 假设你有一个边框纹理

    -- 根据难度等级设置边框颜色
    local color = DifficultyBuffBorderColors[i]
    borderTexture:SetVertexColor(unpack(color)) -- 应用颜色到边框

    -- 为按钮设置内部的Buff纹理（不变颜色）
    local buffTexture = BuffButton:CreateTexture(nil, "ARTWORK")
    SetPortraitToTexture(buffTexture, "Interface\\AddOns\\TestDaMijing\\img\\selection\\RewFrame\\spell_" .. i) -- 设置纹理路径
    buffTexture:SetPoint("CENTER", BuffButton, "CENTER")
    buffTexture:SetSize(28, 28)                                                                               -- Buff图标稍微小于按钮的大小，以显示边框
end

-- 子难度按钮滚动框架
local ScrollChild = CreateFrame("Frame", nil, ScrollFrame)
ScrollChild:SetSize(visibleWidth, SubHeight) -- 实际宽度应该基于子难度按钮的数量
ScrollFrame:SetScrollChild(ScrollChild)

-- 隐藏所有子难度按钮
local function HideSubDifficulties()
    for _, subBtn in ipairs(SubDifficultyFrames) do
        subBtn:Hide()
        -- print(subBtn:GetName())
    end
end

-- 显示指定主难度的子难度按钮
function ShowSubDifficulties(mainDifficultyIndex)
    -- 重置滚动位置到起始点
    ScrollFrame:SetHorizontalScroll(0)
    
    -- 首先隐藏所有子难度按钮
    HideSubDifficulties()

    SubDiffTimeFrame:Hide()

    -- 获取指定的主难度数据
    local diffData = MYTHIC_PLUS_DIFFICULTIES[mainDifficultyIndex]
    if not diffData then
        --print("Invalid mainDifficultyIndex: " .. mainDifficultyIndex)
        return
    end


    subDiffCount = diffData.SubDiffCount -- 从主难度数据中获取子难度数量

    local totalSubWidth = subDiffCount * SubWidth + (subDiffCount - 1) * Subpacing
    ScrollChild:SetWidth(totalSubWidth)


    --创建子难度按钮
    -- 为每个子难度创建或更新按钮
    for i = 1, subDiffCount do
        local subBtn = SubDifficultyFrames[i] or CreateFrame("Button", "SubBtn" .. i, ScrollChild)
        -- 设置子难度按钮大小和位置
        subBtn:SetSize(SubWidth, SubHeight)
        --subBtn:SetPoint("LEFT", (i - 1) * (SubWidth + Subpacing), -MainDifficultyButtHeight - 20) -- 根据需要调整位置
        subBtn:SetPoint("LEFT", (i - 1) * (SubWidth + Subpacing), 0)
        -- 为子难度按钮设置纹理序列  暂时不需要
        -- local texturePath = basePath .. i
        -- subBtn:SetNormalTexture(texturePath)
        --subBtn:SetNormalTexture(diffData.Sub_BACKGROUND) --单独设置单纹理
        -- subBtn:SetDisabledTexture(MYTHIC_PLUS_DIFFICULTIES[i].Sub_DISABLED) -- 设置禁用纹理

        -- subBtn:Disable()     -- 禁用按钮


        -- 设置纹理
        local texture = subBtn.texture or subBtn:CreateTexture(nil, "BACKGROUND")
        texture:SetAllPoints()
        texture:SetTexture(diffData.Sub_BACKGROUND)
        subBtn.texture = texture

        --设置高光纹理
        local highlightTexture = subBtn.highlightTexture or subBtn:CreateTexture(nil, "OVERLAY")
        highlightTexture:SetAllPoints()
        highlightTexture:SetTexture(diffData.Sub_OVERLAY)
        highlightTexture:Hide() -- 初始情况下隐藏高光纹理
        subBtn.highlightTexture = highlightTexture

        --设置按下纹理
        local pressedTexture = subBtn.pressedTexture or subBtn:CreateTexture(nil, "ARTWORK")
        pressedTexture:SetAllPoints()
        pressedTexture:SetTexture(diffData.Sub_ARTWORK)
        pressedTexture:Hide() -- 初始情况下隐藏按下纹理
        subBtn.pressedTexture = pressedTexture

        --按钮的选中纹理
        local selectedTexture = subBtn.selectedTexture or subBtn:CreateTexture(nil, "ARTWORK")
        selectedTexture:SetAllPoints()
        selectedTexture:SetTexture(diffData.Sub_ARTWORK)
        selectedTexture:Hide() -- 初始时隐藏选中纹理
        subBtn.selectedTexture = selectedTexture

        local SubBtnText = subBtn:CreateFontString("SubBtnText" .. i, "ARTWORK", "GameFontNormal");
        SubBtnText:SetFont(DifficultyFonts, 10, "OUTLINE")
        SubBtnText:SetVertexColor(255 / 255, 173 / 255, 105 / 255);
        SubBtnText:SetText(i);
        SubBtnText:SetPoint("TOP", 0, -20); -- 文本位置
        SubBtnText:SetJustifyH("center")    -- 水平对齐
        SubBtnText:SetJustifyV("center")    -- 垂直对齐
        SubBtnText:SetPoint("CENTER", 0, 8)

        -- 是否在拖动
        local isDragging = false

        -- 鼠标拖动滚动功能
        subBtn:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                isDragging = true -- 正在左键按住拖动
                self.pressedTexture:Show()
                local startPosX, _ = GetCursorPosition()
                local startHScroll = ScrollFrame:GetHorizontalScroll()

                subBtn:SetScript("OnMouseUp", function()
                    self.pressedTexture:Hide()
                    subBtn:SetScript("OnMouseUp", nil)
                    subBtn:SetScript("OnUpdate", nil)

                    -- 添加这一部分来在鼠标放开时自动调整滚动位置，仅当实际拖动时进行
                    if isDragging then
                        local currentScroll = ScrollFrame:GetHorizontalScroll()
                        local remainder = currentScroll % (SubWidth + Subpacing)

                        if remainder > 0 and remainder < SubWidth then
                            local alignmentPosition = (SubWidth + Subpacing) *
                                math.floor(currentScroll / (SubWidth + Subpacing))
                            if currentScroll - alignmentPosition < alignmentPosition + SubWidth + Subpacing - currentScroll then
                                -- 如果更接近前一个按钮，向后滚动
                                ScrollFrame:SetHorizontalScroll(alignmentPosition)
                            else
                                -- 否则，向前滚动
                                ScrollFrame:SetHorizontalScroll(alignmentPosition + SubWidth + Subpacing)
                            end
                        end
                        isDragging = false
                    end
                end)

                subBtn:SetScript("OnUpdate", function()
                    local curPosX, _ = GetCursorPosition()
                    local delta = (startPosX - curPosX) / ScrollFrame:GetScale()

                    local newHScroll = startHScroll + delta

                    local maxHScroll = (subDiffCount - 1) * (SubWidth + Subpacing) - ScrollFrame:GetWidth() +
                        SubWidth

                    -- 限制滚动范围
                    if newHScroll < 0 then
                        newHScroll = 0
                    elseif newHScroll > maxHScroll then
                        newHScroll = maxHScroll
                    end

                    ScrollFrame:SetHorizontalScroll(newHScroll)
                end)
            end
        end)

        -- 将子难度按钮添加到列表中
        if not SubDifficultyFrames[i] then
            table.insert(SubDifficultyFrames, subBtn)
        end

        -- 显示子难度按钮
        subBtn:Show()

        --鼠标移入事件
        subBtn:SetScript("OnEnter", function(self)
            self.highlightTexture:Show()
        end)

        --鼠标移出事件
        subBtn:SetScript("OnLeave", function(self)
            self.highlightTexture:Hide()
        end)

        --鼠标按下事件
        subBtn:HookScript("OnClick", function(self)
            print("按钮ID ="..self:GetID())
            for _, otherBtn in pairs(SubDifficultyFrames) do
                otherBtn:SetSize(SubWidth, SubHeight) -- 设置其他按钮为默认大小
            end
            subBtn:SetSize(SubWidth, SubHeight + 10)  -- 当前被点击的按钮变大
            local offsetX = (i - 1) * (SubWidth + Subpacing) - 2
            subBtn:SetPoint("CENTER", offsetX, 0)

            if subBtn.isSelected then -- 如果按钮已经被选中
                subBtn.isSelected = false
                subBtn.pressedTexture:Hide()
            else
                subBtn.isSelected = true
                subBtn.pressedTexture:Show()
            end

            for _, otherBtn in pairs(SubDifficultyFrames) do
                otherBtn.pressedTexture:Hide()
                otherBtn.isSelected = false
            end

            subBtn.pressedTexture:Show()
            SubDiffTimeFrame:SetParent(subBtn)
            SubDiffTimeFrame:SetPoint("CENTER", 0, -20)
            SubDiffTimeFrame:Show();
            subBtn.isSelected = true
        end)
    end
end

-----------------------------------------  进入秘境按钮  ----------------------------------------
--进入秘境按钮底图框架
local EnterDifficultyButtonFrame = CreateFrame("Frame", nil, mainFrame)
EnterDifficultyButtonFrame:SetSize(455, 50)
EnterDifficultyButtonFrame:SetPoint("BOTTOM", 0, 5)
EnterDifficultyButtonFrame:SetBackdrop({ bgFile = "Interface\\AddOns\\TestDaMijing\\img\\selection\\进入秘境按钮底图" })
--进入秘境按钮
local EnterDifficultyButton = CreateFrame("Button", nil, EnterDifficultyButtonFrame, "EnterDifficultyButtonFrame")
EnterDifficultyButton:SetPoint("TOP", 0, 0)

EnterDifficultyButton.text = EnterDifficultyButton:CreateFontString("$parent" .. "TitleText", "ARTWORK", "GameFontNormal") -- 创建功能介绍
EnterDifficultyButton.text:SetFont(DifficultyFonts, 12, "OUTLINE")
EnterDifficultyButton.text:SetText("进入秘境")
EnterDifficultyButton.text:SetTextColor(255 / 255, 173 / 255, 105 / 255) --文本颜色
EnterDifficultyButton.text:SetJustifyH("center")                         -- 水平对齐
EnterDifficultyButton.text:SetJustifyV("center")                         -- 垂直对齐
EnterDifficultyButton.text:SetSize(200, 230);
EnterDifficultyButton.text:SetPoint("CENTER", 0, 2)

-- 当按下按钮时
EnterDifficultyButton:HookScript("OnMouseDown", function()
    EnterDifficultyButton.text:SetPoint("CENTER", 1, 1) --将文本移动1像素到右边和1像素向下
end)

-- 当释放按钮时
EnterDifficultyButton:HookScript("OnMouseUp", function()
    EnterDifficultyButton.text:SetPoint("CENTER", 0, 2) --将文本恢复到原始位置
end)

-- 当按下按钮时
EnterDifficultyButton:HookScript("OnClick", function()
    print("进入了秘境")
end)

----------------...命令显示窗体
SLASH_MYADDON1 = "/myaddon"
SlashCmdList["MYADDON"] = function()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end


-- 手动调用"普通"难度按钮的OnClick脚本
MaindifficultyButtons[1]:GetScript("OnClick")(MaindifficultyButtons[1])

-- 基于服务器数据动态创建难度按钮的功能
function UpdateDifficultyUI(mainDifficulties, subDifficulties)
    
    print("PlayerCurrentSubDifficultyID = ",PlayerCurrentSubDifficultyID)
    -- 清除现有的主难度按钮
    -- for _, btn in pairs(MaindifficultyButtons) do
    --     btn:Hide()
    --     btn = nil
    -- end
    --MaindifficultyButtons = {}

    -- 计算主难度按钮数量
    local UpdateMainDifficultyNum = #mainDifficulties
    for i, difficulty in ipairs(mainDifficulties) do
        MaindifficultyButtons[i].BtnTexFrame.text:SetText(difficulty.name)  --初始设置主难度文本

    end
    -- 动态创建主难度按钮
    -- for i, difficulty in ipairs(mainDifficulties) do
    --     local MainDifficultyBut = CreateFrame("Button", nil, mainFrame, nil, i)
    --     MainDifficultyBut:SetSize(MainDifficultyButtWidth, MainDifficultyButtHeight)

    --     -- 设置按钮位置
    --     if UpdateMainDifficultyNum % 2 == 0 then
    --         local centerOffset = (MainDifficultyButtWidth + Spacing) * ((i - 1) - UpdateMainDifficultyNum / 2 + 0.5)
    --         MainDifficultyBut:SetPoint("CENTER", centerOffset, 25)
    --     else
    --         local centerOffset = (MainDifficultyButtWidth + Spacing) *
    --         (i - (math.floor(UpdateMainDifficultyNum / 2) + 1))
    --         MainDifficultyBut:SetPoint("CENTER", centerOffset, 25)
    --     end

    --     local style = MYTHIC_PLUS_DIFFICULTIES[tonumber(difficulty.id)]

    --     -- 设置纹理和其他属性
    --     MainDifficultyBut:SetDisabledTexture(style.Main_DISABLED)
    --     local texture = MainDifficultyBut:CreateTexture(nil, "BACKGROUND")
    --     texture:SetAllPoints()
    --     texture:SetTexture()



    --     local highlightTexture = MainDifficultyBut:CreateTexture(nil, "HIGHLIGHT")
    --     highlightTexture:SetAllPoints()
    --     highlightTexture:SetTexture(style.Main_HIGHLIGHT)

    --     local pressedTexture = MainDifficultyBut:CreateTexture(nil, "ARTWORK")
    --     pressedTexture:SetAllPoints()
    --     pressedTexture:SetTexture(style.Main_ARTWORK)

    --     -- 设置选中纹理
    --     local selectedTexture = MainDifficultyBut:CreateTexture(nil, "ARTWORK")
    --     selectedTexture:SetAllPoints()
    --     selectedTexture:SetTexture(style.Main_ARTWORK)
    --     selectedTexture:Hide()
    --     MainDifficultyBut.selectedTexture = selectedTexture

    --     -- 添加点击事件处理逻辑
    --     MainDifficultyBut:SetScript("OnClick", function(self)
    --         for _, otherBtn in pairs(MaindifficultyButtons) do
    --             otherBtn.selectedTexture:Hide()
    --             otherBtn.isSelected = false
    --             otherBtn:SetSize(MainDifficultyButtWidth, MainDifficultyButtHeight)
    --         end
    --         self.selectedTexture:Show()
    --         self.isSelected = true
    --         self:SetSize(MainDifficultyButtWidth + 10, MainDifficultyButtHeight + 10)

    --         ShowSubDifficulties(i) -- 显示子难度按钮

    --         -- 其他点击事件的处理逻辑
    --         -- ...
    --     end)

    --     -- 鼠标事件
    --     MainDifficultyBut:SetScript("OnEnter", function(self)
    --         self.highlightTexture:Show()
    --     end)
    --     MainDifficultyBut:SetScript("OnLeave", function(self)
    --         if not self.isSelected then
    --             self.highlightTexture:Hide()
    --         end
    --     end)

    --     -- 添加上方难度文本
    --     MainDifficultyBut.UpdateBtnTexFrame = CreateFrame("Frame", "UpdateBtnTexFrame", MainDifficultyBut)
    --     MainDifficultyBut.UpdateBtnTexFrame:SetPoint("TOP", 0, 20)
    --     MainDifficultyBut.UpdateBtnTexFrame:SetSize(150, 35)
    --     MainDifficultyBut.UpdateBtnTexFrame.tex = MainDifficultyBut.UpdateBtnTexFrame:CreateTexture()
    --     MainDifficultyBut.UpdateBtnTexFrame.tex:SetAllPoints(MainDifficultyBut.UpdateBtnTexFrame)
    --     MainDifficultyBut.UpdateBtnTexFrame.tex:SetTexture("Interface\\AddOns\\TestDaMijing\\img\\selection\\主难度文本框")

    --     MainDifficultyBut.UpdateBtnTexFrame.text = MainDifficultyBut.UpdateBtnTexFrame:CreateFontString(
    --     "$parent" .. "TitleText", "ARTWORK", "GameFontNormal")
    --     MainDifficultyBut.UpdateBtnTexFrame.text:SetFont(DifficultyFonts, 10, "OUTLINE")
    --     MainDifficultyBut.UpdateBtnTexFrame.text:SetText(difficulty.name)
    --     print(style.Main_BACKGROUND)
    --     MainDifficultyBut.UpdateBtnTexFrame.text:SetTextColor(255 / 255, 173 / 255, 105 / 255)
    --     MainDifficultyBut.UpdateBtnTexFrame.text:SetJustifyH("CENTER")
    --     MainDifficultyBut.UpdateBtnTexFrame.text:SetJustifyV("MIDDLE")
    --     MainDifficultyBut.UpdateBtnTexFrame.text:SetSize(150, 35)
    --     MainDifficultyBut.UpdateBtnTexFrame.text:SetPoint("CENTER", MainDifficultyBut.UpdateBtnTexFrame, "CENTER")

    --     -- 将创建的按钮添加到主难度按钮数组中
    --     table.insert(MaindifficultyButtons, MainDifficultyBut)
    -- end

    -- 在此处处理子难度按钮的更新（如果需要）
    -- ...
end
