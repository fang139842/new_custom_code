// _Sm_TestDaMiJing.cpp
#include "GreatDungeonKeyManager.h"
#include "MapManager.h"
#include "InstanceScript.h"
#include "GreatDungeon.h"
#include "Player.h"

void GreatDungeonClass::Load()
{
    uint32 oldMSTime = getMSTime();
    // 秘境副本结构体  占时未考虑是否使用
/*    sGreatDungeonClass->MythicPlusDifficultyVec.clear();
    QueryResult result = WorldDatabase.PQuery(sWorld->getBoolConfig(CONFIG_ZHCN_DB) ?
        "SELECT 地图ID,大秘境难度,限时时间,血量倍率,物理攻击倍率,法术攻击倍率,通关奖励模板ID,通关需击杀生物ID FROM _大秘境系统" :
        "SELECT mapId,Difficulty,countDown,HealthMultiplier,Damage,SpellDamage,rewId,killedEntry FROM _MythicPlusDifficulty");
    if (!result)
        return;
    do
    {
        Field* fields = result->Fetch();
        MythicPlusDifficultyTemplate MythicPlusDifficultyTemp;
        uint32 index = 0;
        memset(&MythicPlusDifficultyTemp, 0, sizeof(MythicPlusDifficultyTemp));//用0填充
        MythicPlusDifficultyTemp.mapId = fields[index++].GetUInt32();

        const char* str = fields[index++].GetCString();     //类型 难度类型
        if (stricmp("普通", str) == 0)
            MythicPlusDifficultyTemp.Difficulty = MYTHIC_PLUS_NORMAL;
        else if (stricmp("一般", str) == 0)
            MythicPlusDifficultyTemp.Difficulty = MYTHIC_PLUS_AVERAGE;
        else if (stricmp("困难", str) == 0)
            MythicPlusDifficultyTemp.Difficulty = MYTHIC_PLUS_HARD;
        else if (stricmp("厄运", str) == 0)
            MythicPlusDifficultyTemp.Difficulty = MYTHIC_PLUS_DOOM;
        else
        {
            // 打印一个错误或警告，并跳过这条记录
            sLog->outError("scripts", "Unknown MythicPlus Difficulty: %s", str);
            continue;
        }

        MythicPlusDifficultyTemp.countDown = fields[index++].GetUInt32();
        MythicPlusDifficultyTemp.HealthMultiplier = fields[index++].GetUInt32();
        MythicPlusDifficultyTemp.Damage = fields[index++].GetUInt32();
        MythicPlusDifficultyTemp.SpellDamage = fields[index++].GetUInt32();
        MythicPlusDifficultyTemp.rewId = fields[index++].GetUInt32();
        MythicPlusDifficultyTemp.killedEntry = fields[index++].GetUInt32();

        sGreatDungeonClass->MythicPlusDifficultyVec.push_back(MythicPlusDifficultyTemp);
    } while (result->NextRow());

    */

    // 大秘境主难度设定
    sGreatDungeonClass->GreatDungeonMainDifficultySetVec.clear();
    QueryResult result = WorldDatabase.PQuery("SELECT 难度ID,难度名称,秘境介绍 FROM _damijing._大秘境主难度设定");
    if (!result)
        return;
    do
    {
        Field* fields = result->Fetch();
        GreatDungeonMainDifficultySet GreatDungeonMainDifficultySet;
        uint32 index = 0;
        memset(&GreatDungeonMainDifficultySet, 0, sizeof(GreatDungeonMainDifficultySet));//用0填充

        GreatDungeonMainDifficultySet.Main_DifficultyID   = fields[index++].GetUInt32();      //  主难度ID
        GreatDungeonMainDifficultySet.Main_DifficultyName = fields[index++].GetString();      //  难度名称
        GreatDungeonMainDifficultySet.Main_DifficultyDes  = fields[index++].GetString();      //  难度描述

        sGreatDungeonClass->GreatDungeonMainDifficultySetVec.push_back(GreatDungeonMainDifficultySet);
    } while (result->NextRow());
    if (GreatDungeonMainDifficultySetVec.size() > 0)
        sLog->outString(">> 读取自定义功能数据表【_大秘境主难度设定------】,共%u条数据读取加载，用时%u毫秒", GreatDungeonMainDifficultySetVec.size(), GetMSTimeDiffToNow(oldMSTime));


    // 大秘境子难度设定
    sGreatDungeonClass->SubDiffcultySetVec.clear();
    result = WorldDatabase.PQuery("SELECT 主难度ID,子难度ID,难度名称,生命系数,伤害系数,秘境buff,通关时间要求 FROM _damijing._大秘境子难度设定" );
    if (!result)
        return;
    do
    {
        Field* fields = result->Fetch();
        SubDiffcultySet SubDiffcultySet;
        uint32 index = 0;
        memset(&SubDiffcultySet, 0, sizeof(SubDiffcultySet));//用0填充

        SubDiffcultySet.DifficultyID            = fields[index++].GetUInt32();    // 对应[大秘境主难度设定]的主难度ID
        SubDiffcultySet.SubDiffcultyID          = fields[index++].GetUInt32();    // 子难度ID
        SubDiffcultySet.SubDiffcultyName        = fields[index++].GetString();    // 子难度名称
        SubDiffcultySet.HealthMultiplier        = fields[index++].GetFloat();     // 生命倍率
        SubDiffcultySet.Damage                  = fields[index++].GetFloat();     // 伤害倍率
        SubDiffcultySet.Buff                    = fields[index++].GetString();    // 生物BUFF
        SubDiffcultySet.m_logintime             = fields[index++].GetUInt32();    // 通关需要时间

        sGreatDungeonClass->SubDiffcultySetVec.push_back(SubDiffcultySet);
    } while (result->NextRow());
    if (SubDiffcultySetVec.size() > 0)
        sLog->outString(">> 读取自定义功能数据表【_大秘境子难度设定------】,共%u条数据读取加载，用时%u毫秒", SubDiffcultySetVec.size(), GetMSTimeDiffToNow(oldMSTime));
}

//发送大秘境主难度名称
void GreatDungeonClass::SendGreatDungeonMainDifficultyData(Player* player)
{
    std::string batchMessage;
    for (auto it = GreatDungeonMainDifficultySetVec.begin(); it != GreatDungeonMainDifficultySetVec.end(); ++it) {
        batchMessage
            += std::to_string(  it->Main_DifficultyID) + ":"        //主难度ID
            +                   it->Main_DifficultyName + ":"       //主难度名称
            +                   it->Main_DifficultyDes;             //主难度简介

        if (it != GreatDungeonMainDifficultySetVec.end() - 1) {
            batchMessage += "^";
        }
    }
    sGreatDungeonKeyManager->SendAddonMessageToPlayer(player, "SMSG_GREATDUN_MAIN_DIFF_BATCH", batchMessage);
}

//发送大秘境子难度数据
void GreatDungeonClass::SendGreatDungeonSubDifficultyData(Player* player)
{
    std::string batchMessage;
    for (auto it = SubDiffcultySetVec.begin(); it != SubDiffcultySetVec.end(); ++it)
    {
        batchMessage
            += std::to_string(it->DifficultyID) + ":"           // 对应[大秘境主难度设定]的主难度ID
            + std::to_string(it->DifficultyID) + "-" + std::to_string(it->SubDiffcultyID) + ":"          // 构造主难度和子难度相加的ID
            + it->SubDiffcultyName + ":"                        // 子难度名称
            + it->Buff + ":"                                    // 生物BUFF
            + std::to_string(it->m_logintime);                  // 通关需要时间

        if (it != SubDiffcultySetVec.end() - 1) {
            batchMessage += "^";
        }
    }
    sGreatDungeonKeyManager->SendAddonMessageToPlayer(player, "SMSG_GREATDUN_SUB_DIFF_BATCH", batchMessage);
}


void InstanceScript::CreateMythicPlusInstance(Player* player, MythicPlusDifficulty difficulty)
{
    // 遍历大秘境模板列表，查找是否玩家已经在一个大秘境副本中
    for (MythicPlusDifficultyTemplate& templateData : sGreatDungeonClass->MythicPlusDifficultyVec)
    {
        if (player->GetMapId() == templateData.mapId)
        {
            ChatHandler(player->GetSession()).PSendSysMessage("你已经在一个大秘境副本中。");
            return;
        }
    }

    // 从模板中获取对应难度的大秘境数据
    MythicPlusDifficultyTemplate* selectedTemplate = nullptr;
    for (MythicPlusDifficultyTemplate& templateData : sGreatDungeonClass->MythicPlusDifficultyVec)
    {
        if (templateData.Difficulty == difficulty)
        {
            selectedTemplate = &templateData;
            break;
        }
    }

    if (!selectedTemplate)
    {
        // 未找到对应的大秘境模板，错误处理
        return;
    }

    // 设置玩家地图的大秘境属性（这些函数需要你自行实现或添加）
    //player->GetMap()->SetCountdown(selectedTemplate->countDown);
    //player->GetMap()->AdjustCreatureStats(selectedTemplate->HealthMultiplier, selectedTemplate->Damage, selectedTemplate->SpellDamage);
    // ... 其他的设置，例如奖励、必须击败的生物等

    // 为玩家进入副本做准备，例如传送玩家
    //player->TeleportTo(selectedTemplate->mapId, /*x*/, /*y*/, /*z*/, /*orientation*/);
}


static MythicPlusDifficulty StringToMythicPlusDifficulty(const std::string& difficulty)
{
    if (difficulty == "MYTHIC_PLUS1")
        return MYTHIC_PLUS_NORMAL;
    else if (difficulty == "MYTHIC_PLUS2")
        return MYTHIC_PLUS_AVERAGE;
    else if (difficulty == "MYTHIC_PLUS3")
        return MYTHIC_PLUS_HARD;
    else if (difficulty == "MYTHIC_PLUS4")
        return MYTHIC_PLUS_DOOM;
    else
        return MYTHIC_PLUS_NORMAL; // 默认情况，你可以选择返回一个错误或异常
}

// 获取物品名称
std::string GreatDungeonClass::GetItemNameOnly(uint32 entry)
{
    const ItemTemplate* temp = sObjectMgr->GetItemTemplate(entry);
    if (temp) {
        return std::string(temp->Name1); // 如果找到物品模板，返回物品名称
    } else {
        return "Unknown Item"; // 否则返回一个占位符或错误消息
    }
}


class GreatDungeonClassCommandScript : public CommandScript
{
public:
    GreatDungeonClassCommandScript() : CommandScript("GreatDungeonClassCommandScript") { }

    std::vector<ChatCommand> GetCommands() const override
    {
        static std::vector<ChatCommand> MythicPlusSetCommandTable =
        {
            { "set mythicplus", SEC_PLAYER, true, &HandleSetMythicPlusCommand, "" },
        { "addkeystone", SEC_PLAYER, true, &HandleAddkeystoneCommand, "" }


        };

        return MythicPlusSetCommandTable;
    }

    //选择大秘境难度
    static bool HandleSetMythicPlusCommand(ChatHandler* pChat, const char* msg)
    {
        Player* player = pChat->GetSession()->GetPlayer();

        if (!player || !*msg)
            return true;

        std::string command(msg);
        std::string prefix = "mythicplus";
        size_t pos = command.find(prefix);

        // 检查是否找到"mythicplus"前缀
        if (pos != std::string::npos)
        {
            std::string difficulty = command.substr(pos + prefix.length());

            // 删除前导和尾随的空格
            difficulty.erase(0, difficulty.find_first_not_of(' '));
            difficulty.erase(difficulty.find_last_not_of(' ') + 1);

            sLog->outString("difficulty = ：%s", difficulty.c_str());

            if (difficulty == "MYTHIC_PLUS1" || difficulty == "MYTHIC_PLUS2" || difficulty == "MYTHIC_PLUS3" || difficulty == "MYTHIC_PLUS4")
            {
                // 在这里，你可以存储玩家选择的难度或进行其他操作。
                MythicPlusDifficulty enumDifficulty = StringToMythicPlusDifficulty(difficulty);
                Map* playerMap = player->GetMap();
                playerMap->SetMythicPlusDifficulty(enumDifficulty);

                pChat->PSendSysMessage("大秘境难度已设置为：%s", difficulty.c_str());
            }
            else
            {
                pChat->PSendSysMessage("无效的大秘境难度选择。");
            }
        }
        else
        {
            pChat->PSendSysMessage("命令格式不正确。");
        }

        return true;
    }

    // _Sm_TestDaMiJing.cpp
    //拾取大秘境钥石
    static bool HandleAddkeystoneCommand(ChatHandler* pChat, const char* msg)
    {
        uint32 itemId = atoi(msg);                              // 将msg转换为整数
        Player* player = pChat->GetSession()->GetPlayer();

        if (!player)
            return true;

        KeystoneDefinition keystoneDef = sGreatDungeonKeyManager->GetKeystoneDefinition(itemId);
        const uint32 intermediaryItemId = 100800;               // 中介物品ID
        ItemPosCountVec dest;
        uint8 bagResult = player->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, intermediaryItemId, 1);

        //if (!player->HasItemCount(intermediaryItemId, 1, true) && bagResult == EQUIP_ERR_OK)
       // {

        std::optional<uint32> pendingKeystone = player->GetPendingKeystoneDrop();
       
        if (pendingKeystone)
        {
            Item* newItem = player->StoreNewItem(dest, intermediaryItemId, true, 0);
            player->SendNewItem(newItem, 1, true, false);

            pChat->PSendSysMessage("你已成功拾取大秘境钥石！");

            // 在附魔槽中存储itemGUID 将存储为改造后的itemGuid 加 钥石ID
            uint64 itemGuid = newItem->GetGUID(); // 获取整个itemGUID
            uint64 NewKeyToneID = intermediaryItemId + itemGuid + keystoneDef.keystoneId;
            newItem->SetEnchantment(EnchantmentSlot(PERM_ENCHANTMENT_SLOT), NewKeyToneID, 0, 0);

            // 保存钥石信息到数据库
            PreparedStatement* stmt = CharacterDatabase.GetPreparedStatement(CHAR_INS_KEYSTONE_INFO);
            stmt->setUInt32(0, player->GetGUID());          // 角色GUID
            stmt->setUInt32(1, keystoneDef.keystoneId);     // 钥石ID
            stmt->setUInt32(2, intermediaryItemId);         // 物品ID
            stmt->setUInt32(3, NewKeyToneID);               // 物品GUID
            // 执行 SQL 语句
            CharacterDatabase.Execute(stmt);

            std::string message =
                std::to_string(static_cast<uint32_t>(NewKeyToneID)) + ":"       // 添加由物品ID+物品GUID+钥石ID 组合而成的ID
                + std::to_string(keystoneDef.keystoneId) + ":"                  // 钥石物品ID
                + std::to_string(keystoneDef.mapId) + ":"                       // 钥石对应的秘境地图ID
                + keystoneDef.name + ":"                                        // 钥石名称
                + std::to_string(keystoneDef.difficulty) + ":"                  // 秘境难度
                + keystoneDef.iconTexture + ":"                                 // 钥石图标
                + keystoneDef.GSR_Des;                                          // 大秘境描述信息

            sGreatDungeonKeyManager->SendAddonMessageToPlayer(player, "SMSG_VIRTUAL_KEYSTONE_INFO_BAG", message);
            sLog->outString("newItem->GetGUID() = %u", newItem->GetGUID());
            player->RemovePendingKeystoneDrop(*pendingKeystone);
        }
        else
        {
            pChat->PSendSysMessage("拾取钥石时出错！");
            return false;
        }
        /* }
         else
         {
             pChat->PSendSysMessage("你的背包已满或已经拥有这个钥石！");
             return false;
         }*/
        return true;
    }
};

void AddSC_GreatDungeonClassCommandScript()
{
    new GreatDungeonClassCommandScript();
}
