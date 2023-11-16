-- DifficultyData.lua
--难度选择界面纹理路径
print("DifficultyData")

Main_DifficultyID = 0 ;                         --大秘境主难度数量
PlayerCurrentSubDifficultyID = 0;               --当前挑战的子难度ID

DifficultyFonts = 'Interface\\AddOns\\TestDaMijing\\Fonts\\TankuinEG.ttf'
local MainDiffBGFilePath = "Interface\\AddOns\\TestDaMijing\\img\\selection\\"
local MainDiffSelestionPath = "Interface\\AddOns\\TestDaMijing\\img\\selection\\MainDifficultiesButTexture\\"
local SubDiffSelestionPath = "Interface\\AddOns\\TestDaMijing\\img\\selection\\SubDifficultiesButTexture\\"


MYTHIC_PLUS_DIFFICULTIES = {
    {
        text            = "",
        BGFile          = MainDiffBGFilePath .. "MainFrame_1",
        color           = { 0, 1, 1, 0.05 }, -- 青色
        checked         = false,
        Main_BACKGROUND = MainDiffSelestionPath .. "普通_正常",
        Main_ARTWORK    = MainDiffSelestionPath .. "普通_高光",
        Main_HIGHLIGHT  = MainDiffSelestionPath .. "普通_描边",
        Main_DISABLED   = MainDiffSelestionPath .. "普通_禁用",
        SubDiffCount    = 50,
        Sub_BACKGROUND  = SubDiffSelestionPath .. "普通_正常",
        Sub_ARTWORK     = SubDiffSelestionPath .. "普通_高光",
        Sub_OVERLAY     = SubDiffSelestionPath .. "普通_描边",
        Sub_DISABLED    = SubDiffSelestionPath .. "子难度禁用",
        Main_DifficultyDes  ="" --难度简介
    },
    {
        text            = "",
        BGFile          = MainDiffBGFilePath .. "MainFrame_2",
        color           = { 0, 1, 0, 0.05 }, -- 绿色
        checked         = false,
        Main_BACKGROUND = MainDiffSelestionPath .. "一般_正常",
        Main_ARTWORK    = MainDiffSelestionPath .. "一般_高光",
        Main_HIGHLIGHT  = MainDiffSelestionPath .. "一般_描边",
        Main_DISABLED   = MainDiffSelestionPath .. "一般_禁用",
        SubDiffCount    = 50,
        Sub_BACKGROUND  = SubDiffSelestionPath .. "一般_正常",
        Sub_ARTWORK     = SubDiffSelestionPath .. "一般_高光",
        Sub_OVERLAY     = SubDiffSelestionPath .. "一般_描边",
        Sub_DISABLED    = SubDiffSelestionPath .. "子难度禁用",
        Main_DifficultyDes  ="" --难度简介
    },
    {
        text            = "困难",
        BGFile          = MainDiffBGFilePath .. "MainFrame_3",
        color           = { 0.8, 0, 0.8, 0.05 }, -- 紫色
        checked         = false,
        Main_BACKGROUND = MainDiffSelestionPath .. "困难_正常",
        Main_ARTWORK    = MainDiffSelestionPath .. "困难_高光",
        Main_HIGHLIGHT  = MainDiffSelestionPath .. "困难_描边",
        Main_DISABLED   = MainDiffSelestionPath .. "困难_禁用",
        SubDiffCount    = 50,
        Sub_BACKGROUND  = SubDiffSelestionPath .. "困难_正常",
        Sub_ARTWORK     = SubDiffSelestionPath .. "困难_高光",
        Sub_OVERLAY     = SubDiffSelestionPath .. "困难_描边",
        Sub_DISABLED    = SubDiffSelestionPath .. "子难度禁用",
        Main_DifficultyDes  ="" --难度简介
    },
    {
        text            = "厄运",
        BGFile          = MainDiffBGFilePath .. "MainFrame_4",
        color           = { 1, 0, 0, 0.05 }, -- 红色
        checked         = false,
        Main_BACKGROUND = MainDiffSelestionPath .. "厄运_正常",
        Main_ARTWORK    = MainDiffSelestionPath .. "厄运_高光",
        Main_HIGHLIGHT  = MainDiffSelestionPath .. "厄运_描边",
        Main_DISABLED   = MainDiffSelestionPath .. "厄运_禁用",
        SubDiffCount    = 50,
        Sub_BACKGROUND  = SubDiffSelestionPath .. "厄运_正常",
        Sub_ARTWORK     = SubDiffSelestionPath .. "厄运_高光",
        Sub_OVERLAY     = SubDiffSelestionPath .. "厄运_描边",
        Sub_DISABLED    = SubDiffSelestionPath .. "子难度禁用",
        Main_DifficultyDes  ="" --难度简介
    }
}



-- 定义不同等级秘境Buff的颜色边框
DifficultyBuffBorderColors = {
    { 0,   1, 1 },   -- 青色
    { 0,   1, 0 },   -- 绿色
    { 0.5, 0, 0.5 }, -- 紫色
    { 1,   0, 0 },   -- 红色
}


