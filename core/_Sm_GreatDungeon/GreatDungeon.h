// _Sm_TestDaMiJing.h

#ifndef MYTHIC_PLUS_H
#define MYTHIC_PLUS_H

// 大秘境主难度设定
struct GreatDungeonMainDifficultySet
{
    uint32  Main_DifficultyID;               //  主难度ID
    std::string  Main_DifficultyName;        //  难度名称
    std::string  Main_DifficultyDes;         //  难度描述
};

//子难度等级定义
struct SubDiffcultySet
{
    uint32 DifficultyID;                // 对应[大秘境主难度设定]的主难度ID
    uint32 SubDiffcultyID;              // 子难度ID
    std::string  SubDiffcultyName;            // 子难度名称
    float HealthMultiplier;            // 生命倍率
    float Damage;                      // 物理攻击倍率
    std::string Buff;                   // 新增的图标ID
    uint32 m_logintime;                 // 通关需要时间
};


//定义大秘境结构体
struct MythicPlusDifficultyTemplate
{
    uint32  mapId;              //  地图ID
    uint32  Difficulty;         //  大秘境难度
    uint32  countDown;          //  限时时间
    uint32  HealthMultiplier;   //  大秘境生物血量倍率
    uint32  Damage;             //  大秘境生物物理攻击倍率
    uint32  SpellDamage;        //  大秘境生物法术攻击倍率
    uint32  rewId;              //  通关奖励模板ID
    uint32  killedEntry;        //  通关需击杀生物ID   
};

//定义大秘境枚举变量
enum MythicPlusDifficulty
{
    MYTHIC_PLUS_NORMAL   = 0,       // 普通大秘境
    MYTHIC_PLUS_AVERAGE  = 1,       // 一般大秘境
    MYTHIC_PLUS_HARD     = 2,       // 困难大秘境
    MYTHIC_PLUS_DOOM     = 3        // 厄运大秘境
};

//  定义钥石结构体
struct VirtualKeystone
{
    uint32 keystoneID;    // 钥石的ID
    uint32 level;         // 钥石的等级
    uint32 dungeonID;     // 关联的副本ID
};

// _大秘境钥石定义表  结构
struct KeystoneDefinition
{
    uint32 keystoneId;          // 钥石ID
    uint32 mapId;               // 秘境ID (关联的副本ID)
    uint32 difficulty;          // 秘境难度
    std::string name;           // 钥石名称
    std::string iconTexture;    // 新增的图标ID
    std::string GSR_Des;        // 大秘境描述信息
};



class GreatDungeonClass
{
public:
    static GreatDungeonClass* instance()
    {
        static GreatDungeonClass instance;
        return &instance;
    }
    void Load();
    void SendGreatDungeonMainDifficultyData(Player* player);                // 发送大秘境主难度数据
    void SendGreatDungeonSubDifficultyData(Player* player);                 // 发送大秘境子难度数据
    vector<MythicPlusDifficultyTemplate> MythicPlusDifficultyVec;           // 秘境副本结构体  占时未考虑是否使用


    vector<GreatDungeonMainDifficultySet> GreatDungeonMainDifficultySetVec; // 大秘境主难度设定
    vector<SubDiffcultySet> SubDiffcultySetVec; // 大秘境子难度设定


    std::string GetItemNameOnly(uint32 entry);

private:

};
#define sGreatDungeonClass GreatDungeonClass::instance()

#endif // MYTHIC_PLUS_H
