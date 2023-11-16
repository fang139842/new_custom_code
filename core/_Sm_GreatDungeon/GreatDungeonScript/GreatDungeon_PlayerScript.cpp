//MythicPlusPlayerScript.cpp

#include "GreatDungeonKeyManager.h"
#include "MapManager.h"
#include "Item.h"

//玩家脚本 击杀生物、登录、删除物品
class GreatDungeon_PlayerScript : public PlayerScript
{
public:
    GreatDungeon_PlayerScript() : PlayerScript("GreatDungeon_PlayerScript") {}

    void OnCreatureKill(Player* killer, Creature* killed) override
    {
        // 检查这个生物是否在钥石掉落表中
        auto possibleKeystones = sGreatDungeonKeyManager->GetPossibleKeystonesForCreature(killed->GetEntry());
        if (possibleKeystones.empty())
            return;

        // 存储生物掉落的钥石信息，待玩家拾取时使用
        killer->StorePendingKeystoneDrop(possibleKeystones);

        // 随机选择一个钥石掉落
        uint32 keystoneId = acore::Containers::SelectRandomContainerElement(possibleKeystones);
        KeystoneDefinition keystoneDef = sGreatDungeonKeyManager->GetKeystoneDefinition(keystoneId);

        killer->FallingKey = keystoneDef.keystoneId;    //击杀后随机获得了钥石ID
        //sLog->outString("KeyID = %u",killer->FallingKey);
    }

    //玩家登录的时候把自定义钥石数据发给玩家
    void OnLogin(Player* player, bool first) override
    {
        // 查询和发送所有的钥石信息
        QueryResult keystoneResult = CharacterDatabase.PQuery("SELECT 钥石ID,物品GUID,物品ID FROM `_角色大秘境钥石` WHERE 角色GUID = %u", player->GetGUIDLow());
        if (keystoneResult)
        {
            do
            {
                Field* fields = keystoneResult->Fetch();
                uint32 keystoneId = fields[0].GetUInt32();
                uint64 itemGuid = fields[1].GetUInt64();
                uint32 itemId = fields[2].GetUInt32();

                // 查询item_instance表，看是否存在匹配的enchantments
                QueryResult itemInstanceResult = CharacterDatabase.PQuery("SELECT guid FROM `item_instance` WHERE `owner_guid` = %u AND `enchantments` LIKE '%s%%'", player->GetGUIDLow(), std::to_string(itemGuid).c_str());

                if (!itemInstanceResult) // 如果没有匹配数据
                {
                    // 删除该条数据
                    CharacterDatabase.PExecute("DELETE FROM `_角色大秘境钥石` WHERE `物品GUID` = %lu", itemGuid);
                }
                else
                {
                    KeystoneDefinition keystoneDef = sGreatDungeonKeyManager->GetKeystoneDefinition(keystoneId);
                    std::string itemName = sGreatDungeonClass->GetItemNameOnly(itemId);
                    player->GetSession()->SendAreaTriggerMessage("拥有物品：%s", itemName.c_str());
                    ChatHandler(player->GetSession()).PSendSysMessage("拥有物品：%s", itemName.c_str());

                    std::string message =
                        std::to_string(itemGuid) + ":"
                        + std::to_string(keystoneDef.keystoneId) + ":"
                        + std::to_string(keystoneDef.mapId) + ":"
                        + keystoneDef.name + ":"
                        + std::to_string(keystoneDef.difficulty) + ":"
                        + keystoneDef.iconTexture + ":"
                        + keystoneDef.GSR_Des;
                    sGreatDungeonKeyManager->SendAddonMessageToPlayer(player, "SMSG_VIRTUAL_KEYSTONE_INFO_BAG", message);
                }
            } while (keystoneResult->NextRow());
        }


        // 玩家登录时，检索他们的秘境挑战状态
        QueryResult challengeStatusResult = CharacterDatabase.PQuery("SELECT `当前钥石ID`, `当前子难度ID`, `最佳通关时间`, `最后挑战结果` FROM `_角色秘境状态` WHERE `角色GUID` = %u", player->GetGUIDLow());

        if (challengeStatusResult)
        {
            Field* fields = challengeStatusResult->Fetch();
            uint32 currentKeystoneId = fields[0].GetUInt32();           // 当前持有的钥石ID
            uint32 currentSubDifficultyId = fields[1].GetUInt32();      // 当前挑战的子难度ID
            uint32 bestCompletionTime = fields[2].GetUInt32();          // 最佳通关时间
            std::string lastChallengeResult = fields[3].GetCString();   // 最后挑战结果

            // 创建并发送数据包
            // 这个消息应该包含足够的信息以便客户端插件能够据此来启用或禁用UI元素
            std::string challengeStatusMessage =
                std::to_string(currentKeystoneId) + ":"                         // 当前持有的钥石ID
                + std::to_string(currentSubDifficultyId) + ":"                  // 当前挑战的子难度ID
                + std::to_string(bestCompletionTime) + ":"                      // 最佳通关时间
                + lastChallengeResult;                                          // 最后挑战结果

            // 发送自定义消息到客户端
            sGreatDungeonKeyManager->SendAddonMessageToPlayer(player, "MYTHIC_CHALLENGE_UI_UPDATE", challengeStatusMessage);
        }
        else
        {
            // 如果没有找到玩家的挑战状态，发送一个消息到客户端，表明没有钥石和挑战记录
            player->GetSession()->SendAreaTriggerMessage("当前并未有秘境挑战记录");
            sGreatDungeonKeyManager->SendAddonMessageToPlayer(player, "MYTHIC_CHALLENGE_UI_UPDATE", "NO_STATUS");
        }

        //发送大秘境主难度名称
        sGreatDungeonClass->SendGreatDungeonMainDifficultyData(player);
        //发送大秘境子难度数据
        sGreatDungeonClass->SendGreatDungeonSubDifficultyData(player);
        
    }
};


void AddSC_CustomMythicPlusScripts()
{
    new GreatDungeon_PlayerScript();
}
