-- --DifficultySelection.lua
print("DifficultySelection")

local SMSG_GREATDUN_MAIN_DIFF_BATCH = "SMSG_GREATDUN_MAIN_DIFF_BATCH" -- 初始化主难度数据
local SMSG_GREATDUN_SUB_DIFF_BATCH  = "SMSG_GREATDUN_SUB_DIFF_BATCH"  -- 初始化子难度数据
local MYTHIC_CHALLENGE_UI_UPDATE    = "MYTHIC_CHALLENGE_UI_UPDATE"    -- 更新_角色秘境状态
function Main_DifficultyEventReloadEvent(self, event, addonName)
    if event == "CHAT_MSG_ADDON" then
        print(" CHAT_MSG_ADDON ")
        if addonName then
            local opcode, message = strsplit(" ", addonName)

            ---------------------------------主难度数据------------------------
            -- 解析并处理主难度数据
            if opcode == SMSG_GREATDUN_MAIN_DIFF_BATCH then
                local mainDifficulties = {}
                local difficulties = { strsplit("^", message) }
                for i, difficultyData in ipairs(difficulties) do
                    --  主难度ID            主难度名称          主难度简介
                    local Main_DifficultyID, Main_DifficultyName, Main_DifficultyDes = strsplit(":", difficultyData)
                    print("主难度ID = ", Main_DifficultyID)
                    print("主难度名称  = ", Main_DifficultyName)
                    print("主难度简介 = ", Main_DifficultyDes)
                    table.insert(mainDifficulties, {
                        id = Main_DifficultyID,
                        name = Main_DifficultyName,
                        description = Main_DifficultyDes,
                    })
                    MYTHIC_PLUS_DIFFICULTIES[i].text = Main_DifficultyName;
                    MYTHIC_PLUS_DIFFICULTIES[i].Main_DifficultyDes = Main_DifficultyDes;
                end
                UpdateDifficultyUI(mainDifficulties, nil) -- 更新UI，暂时只传递主难度数据
                print("主难度数量 = ", #difficulties)
            end

            ---------------------------------子难度数据------------------------
            -- 解析并处理子难度数据
            if opcode == SMSG_GREATDUN_SUB_DIFF_BATCH then
                local subDifficulties = {}
                local difficulties = { strsplit("^", message) }
                for i, difficultyData in ipairs(difficulties) do
        --对应[大秘境主难度设定]的主难度ID      子难度ID        子难度名称    生物BUFF  通关需要时间
                    local DifficultyID, SubDifficultyID, SubDifficultyName, Buff, LoginTime = strsplit(":", difficultyData)
                    print("子难度ID = ", SubDifficultyID)
                    table.insert(subDifficulties, {
                        mainId = DifficultyID,
                        subId = SubDifficultyID,
                        name = SubDifficultyName,
                        buff = Buff,
                        loginTime = LoginTime
                    })
                end
                --UpdateDifficultyUI(nil, subDifficulties) -- 更新UI，暂时只传递子难度数据
                print("子难度数量 = ", #difficulties)
            end


            --------------------------------更新_角色秘境状态------------------------
            if opcode == MYTHIC_CHALLENGE_UI_UPDATE then
                --1、当前持有的钥石ID    2、当前挑战的子难度ID      3、最佳通关时间      4、最后挑战结果
                local currentKeystoneId, currentSubDifficultyId, bestCompletionTime, lastChallengeResult = strsplit(":",
                    message)
                    print(" 当前挑战的子难度ID =  ",currentSubDifficultyId)
                PlayerCurrentSubDifficultyID = currentSubDifficultyId;
            end
        end
    end

    if event == "ADDON_LOADED" then
        if addonName == "TestDaMijing" then
            print(" ADDON_LOADED ")
            --print(" data.text =  ",data.text)
            if MYTHIC_PLUS_DIFFICULTIES then
                -- 更新按钮的文本
                for i, data in ipairs(MYTHIC_PLUS_DIFFICULTIES) do
                    MaindifficultyButtons[i].BtnTexFrame.text:SetText(data.text)
                    print(" data.text =  ", MaindifficultyButtons[i].BtnTexFrame.text:GetText())
                end
            end
        end
    end
    if event == "PLAYER_LOGIN" then
        print(" PLAYER_LOGIN ")
    end
end

local Main_DifficultyEventReloadframe = CreateFrame("frame")
Main_DifficultyEventReloadframe:RegisterEvent("CHAT_MSG_ADDON");
Main_DifficultyEventReloadframe:RegisterEvent("ADDON_LOADED")
Main_DifficultyEventReloadframe:RegisterEvent("PLAYER_LOGIN");
Main_DifficultyEventReloadframe:SetScript("OnEvent", Main_DifficultyEventReloadEvent);
