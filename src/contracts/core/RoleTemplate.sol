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


    Role[] public AllRoles;
    mapping(address => Role[]) internal _ownAllRoles;
    mapping(uint256 => address) internal _tokenOwnInfo; //token和用户对应
    mapping(uint256 => address) internal _roleApprove;
    mapping(address => uint256) internal _OwnCount;


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

        Role memory role = Role(rarity, level, atk, def, hp, speed, combatNumerical, roleType, nowExp, needExp,0,ROLE_TAG);
        uint256 roleId = AllRoles.push(role) - 1;
        role.roleId=roleId;
        _ownAllRoles[msg.sender].push(role);
        _tokenOwnInfo[roleId]=msg.sender;
        _transfer(address(0),msg.sender,roleId);
        return roleId;

    }

    function getUserRole() public returns (Role[] memory){
        return _ownAllRoles[msg.sender];
    }

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _tokenOwnInfo[owner];
    }

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address){
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
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable{
        require(_from !=_to,"Don't repeat the operation");
        require(_from !=address(0)&&_from !=_tokenOwnInfo[_tokenId],"Can't operate without owning");
        require(_roleApprove[_tokenId] !=_to,"Unauthorized address does not allow operation");
        _transfer(_from,_to,_tokenId);
    }

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to ""
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable{
        require(_from !=_to,"Don't repeat the operation");
        require(_from !=address(0)&&_from !=_tokenOwnInfo[_tokenId],"Can't operate without owning");
        require(_roleApprove[_tokenId] !=_to,"Unauthorized address does not allow operation");
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
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable{
        require(_from !=_to,"Don't repeat the operation");
        require(_from !=address(0)&&_from !=_tokenOwnInfo[_tokenId],"Can't operate without owning");
        require(_roleApprove[_tokenId] !=_to,"Unauthorized address does not allow operation");
        _transfer(_from, _to, tokenId);
    }

    /// @notice Set or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    /// @dev Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable{
         require(_approved==OwnInfo[_tokenId],"authorized address is not an owner");
         _roleApprove[_tokenId]=_approved;
    }

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets.
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external {
        if(_approved){
         Role[] roles= _ownAllRoles[msg.sender];
            if(roles.length>0){
                 for(i==0;i<=roles.length;i++){
                   _roleApprove[roles[i].roleId]=_operator;
                 }
            }
        }
    }

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved (uint256 _tokenId) external view returns (address){
        return _roleApprove[_tokenId];
    }

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool){
        require(_ownAllRoles[_owner].length>0,"Owning an address does not have an NFT");
        Role[] roles= _ownAllRoles[_owner];
        if(roles.length>0){
            for(i==0;i<=roles.length;i++){
                _roleApprove[roles[i].roleId]=_operator;
            }
        }
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        // Clear approvals from the previous owner
        _OwnCount[from] -= 1;
        _OwnCount[to] += 1;
        _tokenOwnInfo[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }
}