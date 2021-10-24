pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "../access/Ownable.sol";
import "../token/BEP20/ERC721.sol";


contract RoleTemplate is ERC721,Ownable {

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


    Role[] public AllRoles;
    mapping(address => Role[]) internal _ownAllRoles;
    mapping(uint256 => address) internal _tokenOwnInfo; //token和用户对应
    mapping(uint256 => address) internal _tokenApprovals;
    mapping(address => uint256) internal _balances;
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

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
        uint256 roleId;//角色Id;
        string[] additionalTag;//特殊标签
    }

    function create() public returns (uint256){
        //创建随机数提供给角色对象
        uint8 roleRanDom = _get8Random(ROLE_INIT_NUM, ROLE_SALT);
        //随机产生稀有度
        uint8 rarity = _getRarity(INIT_RARITY);
        uint8 level = 1;
        //给予初始化的参数
        uint32 atk = _getInitAttr(rarity, INIT_ATTR);
        uint32 def = _getInitAttr(rarity, INIT_ATTR);
        uint32 hp = _getInitAttr(rarity, INIT_ATTR);
        uint32 speed = _getInitAttr(rarity, INIT_ATTR);
        uint32 combatNumerical = _getRoleCombatNumerical(level,rarity,INIT_RADIO,atk, def, hp, speed,ROLE_TAG.length);
        uint32 roleType = _get32Random(INIT_ROLE_TYPE, ROLE_TYPE_SALT);
        uint256 needExp = _getNeedExp(EXP_BASE_VALUE, level);
        uint256 nowExp = 1;

        Role memory role = Role(rarity, level, atk, def, hp, speed, combatNumerical, roleType, nowExp, needExp,0,ROLE_TAG);
        AllRoles.push(role);
        uint256 _roleId=AllRoles.length-1;
        role.roleId=_roleId;
        _ownAllRoles[msg.sender].push(role);
        _tokenOwnInfo[_roleId]=msg.sender;
        _transfer(address(0),msg.sender,_roleId);
        uint256 count= _balances[msg.sender];
        _balances[msg.sender]=count+1;
        return _roleId;

    }

    function getUserRole() public returns (Role[] memory){
        return _ownAllRoles[msg.sender];
    }

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view override returns (address){
        return _tokenOwnInfo[_tokenId];
    }

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) override external payable{
        require(_from !=_to,"Don't repeat the operation");
        require(_from !=address(0)&&_from !=_tokenOwnInfo[_tokenId],"Can't operate without owning");
        require(_tokenApprovals[_tokenId] !=_to,"Unauthorized address does not allow operation");
        _transfer(_from,_to,_tokenId);
    }

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to ""
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) override external payable{
        require(_from !=_to,"Don't repeat the operation");
        require(_from !=address(0)&&_from !=_tokenOwnInfo[_tokenId],"Can't operate without owning");
        require(_tokenApprovals[_tokenId] !=_to,"Unauthorized address does not allow operation");
        _transfer(_from,_to,_tokenId);
    }

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) override external payable{
        require(_from !=_to,"Don't repeat the operation");
        require(_from !=address(0),"address(0) can't operate");
        require(_from !=_tokenOwnInfo[_tokenId],"Can't operate without owning");
        require(_tokenApprovals[_tokenId] !=_to,"Unauthorized address does not allow operation");
        _transfer(_from, _to, _tokenId);
    }

    /// @notice Set or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    /// @dev Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) override external payable{
         require(_approved==_tokenOwnInfo[_tokenId],"authorized address is not an owner");
         _tokenApprovals[_tokenId]=_approved;
    }

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets.
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) override  external  {
        require(msg.sender != Ownable.owner(), "ERC721: approve to caller");
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) public view virtual override returns (address) {
        require(_exists(_tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[_tokenId];
    }

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) override external view returns (bool){
        return _operatorApprovals[_owner][_operator];
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        // Clear approvals from the previous owner
        _balances[from] -= 1;
        _balances[to] += 1;
        _tokenOwnInfo[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    /**
 * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(_ownerOf(tokenId), to, tokenId);
    }

    /**
 * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _tokenOwnInfo[tokenId] != address(0);
    }

    function _ownerOf(uint256 _tokenId) internal view  returns (address){
        return _tokenOwnInfo[_tokenId];
    }

    //方法传参一定要与方法参数类型一致
    //外部调用别的合约 一定需要创建构造方法 然后传递合约地址 才能调用别的合约的方法
    //需要取出的数据范围  _salt 需要加密的盐 至多返回0~255
    function _get8Random(uint8 _remainder, string memory _salt)
    public view returns (uint8){
        uint8 randomNumber = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, _salt))) % _remainder);
        uint8 random = uint8(randomNumber);
        return random;
    }

    function _get32Random(uint32 _remainder, string memory _salt)
    public view returns (uint32){
        uint32 randomNumber = uint32(uint256(keccak256(abi.encodePacked(block.timestamp, _salt))) % _remainder);
        uint32 random = uint32(randomNumber);
        return random;
    }

    function _getRandomStr(
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
    function _getRarity(uint8[] memory _section) public view returns (uint8){
        uint8 rarity;
        uint8 random = _get8Random(100, "_rarity") + 1;
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
    function _getInitAttr(uint8 _rarity,uint8[] memory _rarityValue) public view returns(uint8){
        uint8 minValue=_rarityValue[_rarity*2-2];
        uint8 maxValue=_rarityValue[_rarity*2-1];
        return minValue+_get8Random(maxValue-minValue,"_initAttr");
    }


    function _getRoleCombatNumerical(
        uint8 _level,
        uint8 _rarity,
        uint16 _initCombatNumericalRadio,
        uint32 _atk,
        uint32 _def,
        uint32 _hp,
        uint32 _speed,
        uint256 _roleTagLength)
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
            combatNumerical =combatNumerical+ uint32(_roleTagLength) * _initCombatNumericalRadio;
        }
        return combatNumerical;
    }

    function _getNeedExp(uint16 _baseVale,uint8 _level) public view returns(uint256){
        return _baseVale*_level;
    }

    //分段去可以保证不会数据重复 便利还得去重相当麻烦
    function _getRoleTag(uint8 _rarity,string[] memory _roleTag) public view returns(string[] memory roleTag){
        string[] memory roleTag;
        return roleTag;
    }
}