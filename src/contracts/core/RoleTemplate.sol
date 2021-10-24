pragma solidity 0.6.12;

import 'github.com/DreamWorksFactory2021/DreamWorks/src/contracts/token/BEP20/ERC721.sol';
import 'github.com/DreamWorksFactory2021/DreamWorks/src/contracts/core/algorithmHelper.sol';

contract RoleTemplate is ERC721 {

    AlgorithmHelper algorithmHelper;
    string public ROLE_SALT = "ROLE"; //加密盐
    string public ROLE_TYPE_SALT = "ROLE_TYPE";//类型盐
    string[] public ROLE_TAG;//角色标签
    uint8  public ROLE_INIT_NUM = 5; //角色初始数值
    uint8[] public INIT_RARITY = [1, 48, 75, 91, 99]; //初始稀有属性度
    uint8[] public INIT_ATTR = [15, 20, 18, 25, 23, 30, 28, 38, 39, 48, 49, 58]; //初始属性值范围
    uint16 public  INIT_RADIO = 1000; //战力初始倍率
    uint16 public EXP_BASE_VALUE = 100; //经验基础值
    uint32 public INITIAL_VALUE = 1;//初始值
    uint32 public INIT_ROLE_TYPE = 255; //角色类型初始值



    mapping(address => Role[]) internal OwnAllRoles;

    event createSuccess(uint32 roleId, address userAdress);

    struct Role {
        uint8 rarity;//稀有度 划分为1星~5星
        uint8 level;//等级
        uint32 atk;//攻击力
        uint32 def;//防御力
        uint32 hp;//生命值
        uint32 speed;//速度
        uint32 combatNumerical;//战力
        uint32 roleType;//角色类型
        uint256 nowExp;//当前经验值
        uint256 needExp;//所需经验值
        string[] additionalTag;//特殊标签
    }

    function create() public returns (uint256){
        //创建随机数提供给角色对象
        uint8 roleRanDom = algorithmHelper.get8Random(ROLE_INIT_NUM, ROLE_SALT);
        //随机产生稀有度
        uint8 rarity = algorithmHelper.getRarity(INIT_RARITY);
        uint8 level = 1;
        //给予初始化的参数
        uint32 atk = algorithmHelper.getInitAttr(rarity, INIT_ATTR);
        uint32 def = algorithmHelper.getInitAttr(rarity, INIT_ATTR);
        uint32 hp = algorithmHelper.getInitAttr(rarity, INIT_ATTR);
        uint32 speed = algorithmHelper.getInitAttr(rarity, INIT_ATTR);
        uint32 combatNumerical = algorithmHelper.getRoleCombatNumerical(atk, def, hp, speed, rarity, level, ROLE_TAG.length, INIT_RADIO);
        uint32 roleType = algorithmHelper.get32Random(INIT_ROLE_TYPE, ROLE_TYPE_SALT);
        uint256 needExp = algorithmHelper.getNeedExp(EXP_BASE_VALUE, level);
        uint256 nowExp = 1;


        Role memory role = Role(rarity, level, atk, def, hp, speed, combatNumerical, roleType, nowExp, needExp, ROLE_TAG);
        uint256 roleId = roles.push(role) - 1;
        OwnAllRoles[msg.sender].push(role);
        return roleId;

    }

    function getUserRole() public returns (Role[] memory){
        return OwnAllRoles[msg.sender];
    }
}