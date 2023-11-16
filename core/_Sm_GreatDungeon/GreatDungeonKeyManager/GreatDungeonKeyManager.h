//GreatDungeonKeyManager.h
#include "LootMgr.h"

#ifndef VIRTUAL_KEYSTONE_MANAGER_H
#define VIRTUAL_KEYSTONE_MANAGER_H

#include "GreatDungeon.h"

class GreatDungeonKeyManager
{
public:
    // 获取单例
    static GreatDungeonKeyManager* instance();

    // 创建一个新的钥石
    VirtualKeystone CreateKeystone(uint32 dungeonID, uint32 level);

    // ... 其他相关函数，如删除钥石、获取玩家的钥石等
    void LoadKeystoneDefinitions();
    void LoadKeystoneDrops();

    std::vector<uint32> GetPossibleKeystonesForCreature(uint32 creatureId);
    KeystoneDefinition GetKeystoneDefinition(uint32 keystoneId);

    // 当玩家试图拾取某个生物或物品时被调用
    void OnPlayerAttemptLoot(Player* player, uint64 guid);

    //自定义发送插件文本给玩家
    void SendAddonMessageToPlayer(Player* player, const std::string& prefix, const std::string& message);

    // 当玩家选择某个拾取项时被调用
    void OnPlayerPickItem(Player* player, uint32 itemID);

    // 玩家删除大秘境钥石
    void OnPlayerDestroyKeystone(Item* item);

    LootStoreItem CreateLootStoreItemForKeystone(uint32 keystoneId);

private:
    GreatDungeonKeyManager() {}

private:
    std::unordered_map<uint32, KeystoneDefinition> _keystoneDefinitions;
    std::unordered_map<uint32, std::vector<uint32>> _keystoneDrops;
};

#define sGreatDungeonKeyManager GreatDungeonKeyManager::instance()

#endif // VIRTUAL_KEYSTONE_MANAGER_H
