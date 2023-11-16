// GreatDungeonKeyManager.cpp
#include "GreatDungeonKeyManager.h"
#include "DatabaseEnv.h"

// 单例实例
GreatDungeonKeyManager* GreatDungeonKeyManager::instance()
{
    static GreatDungeonKeyManager instance;
    return &instance;
}

// 创建一个新的钥石
VirtualKeystone GreatDungeonKeyManager::CreateKeystone(uint32 dungeonID, uint32 level)
{
    VirtualKeystone newKeystone;

    // 分配一个新的钥石ID
    static uint32 lastKeystoneID = 0; // 为简化起见，使用一个静态变量
    newKeystone.keystoneID = ++lastKeystoneID;

    newKeystone.level = level;
    newKeystone.dungeonID = dungeonID;

    // 在这里，可以向数据库中插入这个新的钥石的信息
    // ...

    return newKeystone;
}

void GreatDungeonKeyManager::LoadKeystoneDefinitions()
{
    // 清空现有的数据
    _keystoneDefinitions.clear();

    QueryResult result = WorldDatabase.Query("SELECT `钥石ID`, `秘境ID`, `秘境难度`, `钥石名称`, `钥石图标`,`秘境描述` FROM `_damijing`.`_大秘境钥石定义表`");
    if (!result)
        return;

    do
    {
        Field* fields = result->Fetch();
        KeystoneDefinition definition;
        definition.keystoneId = fields[0].GetUInt32();
        definition.mapId = fields[1].GetUInt32();
        definition.difficulty = fields[2].GetUInt32();
        definition.name = fields[3].GetString();
        definition.iconTexture = fields[4].GetString();     // 加载图标ID
        definition.GSR_Des = fields[5].GetString();         // 大秘境描述
        _keystoneDefinitions[definition.keystoneId] = definition;
    } while (result->NextRow());
}

void GreatDungeonKeyManager::LoadKeystoneDrops()
{
    // 清空现有的数据
    _keystoneDrops.clear();

    QueryResult result = WorldDatabase.Query("SELECT `生物ID`, `钥石ID` FROM `_damijing`.`_大秘境钥石掉落表`");
    if (!result)
        return;

    do
    {
        Field* fields = result->Fetch();
        uint32 creatureId = fields[0].GetUInt32();
        uint32 keystoneId = fields[1].GetUInt32();

        _keystoneDrops[creatureId].push_back(keystoneId);
    } while (result->NextRow());
}


std::vector<uint32> GreatDungeonKeyManager::GetPossibleKeystonesForCreature(uint32 creatureId)
{
    auto iter = _keystoneDrops.find(creatureId);
    if (iter != _keystoneDrops.end())
    {
        return iter->second;
    }
    return {};  // 返回空列表
}

//返回定义的钥石ID
KeystoneDefinition GreatDungeonKeyManager::GetKeystoneDefinition(uint32 keystoneId)
{
    auto iter = _keystoneDefinitions.find(keystoneId);
    if (iter != _keystoneDefinitions.end())
    {
        return iter->second;
    }
    return {};  // 返回默认构造的定义
}


LootStoreItem GreatDungeonKeyManager::CreateLootStoreItemForKeystone(uint32 keystoneId)
{
    uint32 _itemid = 100800;            // 您之前定义的大秘境钥石的假物品ID
    uint32 _reference = 0;              // 没有使用引用
    float _chance = 100.0f;             // 100%的掉落率，可以按需要进行调整
    bool _needs_quest = false;          // 不需要任务
    uint16 _lootmode = 1;               // 可以根据需要进行调整
    uint8 _groupid = 0;                 // 分组ID，可以根据需要进行调整
    int32 _mincount = 1;                // 最小数量
    uint8 _maxcount = 1;                // 最大数量

    // 创建LootStoreItem对象
    LootStoreItem lootItem(_itemid, _reference, _chance, _needs_quest, _lootmode, _groupid, _mincount, _maxcount);

    return lootItem;
}


//自定义发送插件文本给玩家
void GreatDungeonKeyManager::SendAddonMessageToPlayer(Player* player, const std::string& prefix, const std::string& message)
{
    WorldPacket data(SMSG_MESSAGECHAT, 200);
    data << uint8(CHAT_MSG_WHISPER);
    data << uint32(LANG_ADDON);
    data << player->GetGUID();                              // 发送者的GUID
    data << uint32(0);                                      // 某些字段，可能根据版本而异
    data << player->GetGUID();                              // 接收者的GUID，这里设置为自己，因此会发送给自己
    data << uint32((prefix + " " + message).size() + 1);    // 消息的长度，+1 是因为末尾的'\0'
    data << prefix + " " + message;
    data << uint8(0);                                       // 某些字段，可能根据版本而异

    player->SendDirectMessage(&data);
}


/*
// GreatDungeonKeyManager.cpp

当玩家试图拾取生物时：
根据生物的guid确定它是否有可能掉落钥石。您可以使用之前创建的GetPossibleKeystonesForCreature函数。
如果有可能掉落钥石，随机选择一个并将其添加到待拾取的钥石列表中（这可以使用StorePendingKeystoneDrop函数）。

*/
void GreatDungeonKeyManager::OnPlayerAttemptLoot(Player* player,uint64 guid)
{
    // 从GUID中提取生物ID
    uint32 creatureId = GUID_ENPART(guid); // 替换为实际的函数或操作

    std::optional<uint32> pendingKeystone = player->GetPendingKeystoneDrop();

    // 获取该生物的钥石掉落
    std::vector<uint32> possibleKeystones = GetPossibleKeystonesForCreature(creatureId);
    if(pendingKeystone && !possibleKeystones.empty())
    {
        // 获取LootStoreItem表示的钥石
        LootStoreItem keystoneLootItem = CreateLootStoreItemForKeystone(possibleKeystones[0]);

        //根据生物GUID创建生物
        Creature* creature = player->GetMap()->GetCreature(guid);

        if (creature)
        {
            // 获取与生物关联的Loot对象
            Loot& loot = creature->loot;
            //loot.AddItem(keystoneLootItem);  //将会添加到原始掉落背包中
            player->StorePendingKeystoneDrop(possibleKeystones);
        }

        // 获取钥石的定义
        KeystoneDefinition keystoneDef = GetKeystoneDefinition(player->FallingKey);

        // 创建并发送数据包
        std::string message =
              std::to_string(true) + ":"                                    // 有掉落
            + std::to_string(keystoneDef.keystoneId) + ":"                  // 钥石物品ID
            + std::to_string(keystoneDef.mapId) + ":"                       // 钥石对应的秘境地图ID
            + keystoneDef.name + ":"                                        // 钥石名称
            + std::to_string(keystoneDef.difficulty) + ":"                  // 秘境难度
            + keystoneDef.iconTexture+ ":"                                  // 钥石图标
            + keystoneDef.GSR_Des;                                          // 大秘境描述信息

        SendAddonMessageToPlayer(player, "SMSG_VIRTUAL_KEYSTONE_INFO_LOOT", message);

    }
    else
        SendAddonMessageToPlayer(player, "SMSG_VIRTUAL_KEYSTONE_INFO_LOOT", std::to_string(false));// 无掉落
}

void GreatDungeonKeyManager::OnPlayerDestroyKeystone(Item* item)
{
    ////////////////////////删除 角色大秘境钥石/////////////////////////
    const uint32 intermediaryItemId = 100800; //中介物品ID

                                              // 检查物品是否是中介物品
    if (item->GetEntry() != intermediaryItemId)
        return; // 不是中介物品，所以不需要进一步处理

                // 获取物品的附魔 ID
    uint64 enchantmentId = item->GetEnchantmentId((PERM_ENCHANTMENT_SLOT));

    // 使用附魔 ID 查询“_角色大秘境钥石"表
    PreparedStatement* stmt = CharacterDatabase.GetPreparedStatement(CHAR_SEL_KEYSTONE_BY_ENCHANT_ID);
    stmt->setUInt64(0, enchantmentId);
    PreparedQueryResult result = CharacterDatabase.Query(stmt);

    if (!result)
        return; // 没有找到匹配项

                // 找到匹配的附魔ID，删除该条数据            
    stmt = CharacterDatabase.GetPreparedStatement(CHAR_DEL_KEYSTONE_BY_ITEM_GUID);
    stmt->setUInt64(0, enchantmentId);
    CharacterDatabase.Execute(stmt);
    ////////////////////////删除 角色大秘境钥石/////////////////////////
}



/*

当玩家拾取某个物品时：
检查玩家是否有待拾取的钥石（使用GetPendingKeystoneDrop）。
如果玩家有待拾取的钥石，并且该物品ID与待拾取的钥石匹配，执行以下操作：
将钥石添加到玩家背包中。
如果背包有空间，存储钥石到数据库中的_角色大秘境钥石表。

*/

//OnPlayerPickItem拾取物品已在_Sm_TestDaMiJing.cpp的HandleAddkeystoneCommand函数中已插件发送命令方式反馈实现
//void VirtualKeystoneManager::OnPlayerPickItem(Player* player, uint32 itemID)
//{
//    std::optional<uint32> pendingKeystone = player->GetPendingKeystoneDrop();
//
//    if(pendingKeystone && *pendingKeystone == itemID)
//    {
//        // 将钥石添加到玩家背包（如果有空间的话）
//        // ...
//
//        // 存储钥石到数据库中的`_角色大秘境钥石`表
//        // ...
//    }
//
//    // TODO: 在此处添加处理玩家选择某个拾取项时的逻辑
//    player->GetSession()->SendAreaTriggerMessage("拾取了物品：%u",itemID);
//
//}
