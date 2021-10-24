pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

contract AlgorithmHelper {

    //方法传参一定要与方法参数类型一致
    //外部调用别的合约 一定需要创建构造方法 然后传递合约地址 才能调用别的合约的方法
    //需要取出的数据范围  _salt 需要加密的盐 至多返回0~255
    function get8Random(uint8 _remainder, string memory _salt)
    public view returns (uint8){
        uint8 randomNumber = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, _salt))) % _remainder);
        uint8 random = uint8(randomNumber);
        return random;
    }

    function get32Random(uint32 _remainder, string memory _salt)
    public view returns (uint32){
        uint32 randomNumber = uint32(uint256(keccak256(abi.encodePacked(block.timestamp, _salt))) % _remainder);
        uint32 random = uint32(randomNumber);
        return random;
    }

    function getRandomStr(
        uint _remainder,
        string memory _salt,
        string[] memory _attr)
    public view returns (string memory){
        uint8 randomNumber = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, _salt))) % _remainder);
        string memory randomStr;
        if (randomNumber <= _attr.length - 1 && _attr.length > 0) {
            randomStr = _attr[randomNumber + 1];
        }
        return randomStr;
    }

    //满足稀有率因此设定稀有等级
    //1星：48%
    //
    //2星：27%
    //
    //3星：16%
    //
    //4星：8%
    //
    //5星：1%
    //
    //6星：1%*1%=0.01%
    function getRarity(uint[] memory _section) public view returns (uint8){
        uint8 rarity;
        uint8 random = get8Random(100, "_rarity") + 1;
        if (_section[0] <= random && _section[1] > random) {
            rarity = 1;
        } else if (_section[1] <= random && _section[2] > random) {
            rarity = 2;
        } else if (_section[2] <= random && _section[3] > random) {
            rarity = 3;
        } else if (_section[3] <= random && _section[4] >= random) {
            rarity = 4;
        } else if (random == _section[4] + 1) {
            rarity = 5;
            if(random==_section[4]+1){
                rarity = 6;
            }
        }
        return rarity;
    }
    //获取成长值
    //1星  （15~20 随机波动）
    //
    //2星  （18~25随机波动）
    //
    //3星  （23~30随机波动）
    //
    //4星   (28~38随机波动)
    //
    //5星  （39~48随机波动）
    //
    //6星   (49~58随机波动)
    function getInitAttr(uint8 _rarity,uint8[] memory _rarityValue) public view returns(uint8){
        uint8 minValue=_rarityValue[_rarity*2-2];
        uint8 maxValue=_rarityValue[_rarity*2-1];
        return minValue+get8Random(maxValue-minValue,"_initAttr");
    }


    function getRoleCombatNumerical(
        uint32 _atk,
        uint32 _def,
        uint32 _hp,
        uint32 _speed,
        uint8 _level,
        uint8 _rarity,
        uint256 _roleTagLength,
        uint16 _initCombatNumericalRadio)
    public view returns (uint32)
    {
        uint32 combatNumerical=0;
        if (_atk > 0) {
            combatNumerical =combatNumerical+ _atk * _initCombatNumericalRadio;
        }
        if (_def > 0) {
            combatNumerical =combatNumerical+ _def * _initCombatNumericalRadio;
        }
        if (_hp > 0) {
            combatNumerical =combatNumerical+ _hp * _initCombatNumericalRadio;
        }
        if (_speed > 0) {
            combatNumerical =combatNumerical+ _speed * _initCombatNumericalRadio;
        }
        if (_rarity > 0) {
            combatNumerical =combatNumerical+ _rarity * _initCombatNumericalRadio;
        }
        if (_level > 0) {
            combatNumerical =combatNumerical+ _level * _initCombatNumericalRadio;
        }
        if (_roleTagLength > 0) {
            combatNumerical =combatNumerical+ _roleTagLength * _initCombatNumericalRadio;
        }
        return combatNumerical;
    }

    function getNeedExp(uint16 _baseVale,uint8 _level) public view returns(uint256){
        return _baseVale*_level;
    }

    //分段去可以保证不会数据重复 便利还得去重相当麻烦
    function getRoleTag(uint8 _rarity,string[] memory _roleTag) public view returns(string[] memory roleTag){
        string[] memory roleTag;
        return roleTag;
    }
}