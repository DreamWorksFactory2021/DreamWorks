pragma solidity 0.6.12;

import "github.com/DreamWorksFactory2021/DreamWorks/src/contracts/token/BEP20/ERC721.sol";

contract RoleTemplate is ERC721{

    struct Role {
        uint8 rarity;//稀有度 划分为1星~5星
        uint8 level;//等级
        uint32 atk;//攻击力
        uint32 def;//防御力
        uint32 hp;//生命值
        uint32 speed;//速度
        uint32 combatNumerical;//战力
        uint256 nowExp;//当前经验值
        uint256 needExp;//所需经验值
        string[] additionalTag;//特殊标签
        uint32  RoleType;//角色类型
    }
}