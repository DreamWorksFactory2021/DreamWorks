pragma solidity ^0.6.12;

import "./DreamWorksToken.sol";
import "./DreamNFT.sol";
import "./MasterChef.sol";
import "../math/SafeMath.sol";
import "../token/BEP20/BEP20.sol";

contract Core {

    using SafeMath for uint256;

    DreamWorksToken private _dreamWorks;
    DreamNFT        private _dreamNFT;
    MasterChef      private _masterChef;
    BEP20           private _tokenType;
    address         private  dev;

    constructor(
        DreamWorksToken dreamWork,
        DreamNFT dreamNFT,
        MasterChef masterChef,
        address dev
    ) public {
        _dreamWorks = dreamWork;
        _dreamNFT = dreamNFT;
        _masterChef = masterChef;
        _USDT = 0x55d398326f99059ff775485246999027b3197955;
    }

    //---------------------------------------------------common--------------------------------------------------------//

    mapping(address => bool) private  _blackAddress;

    function setBlackAddress(address userAddress, bool isSetBlack) public onlyOwner returns (bool){
        require(userAddress != address(0), 'zero address is not allow set ');
        _blackAddress[userAddress] = isSetBlack;
        return true;
    }

    //---------------------------------------------------Home---------------------------------------------------------//
    bool private _switch = false;
    uint256 private _defaultPrice = 0.01;
    uint256 private _maxARP = 10000;
    uint256 private _defaultTotalTVL = 0;

    function setDefaultPrice(BEP20 LpToken, uint256 price) public onlyOwner returns (uint256){
        if (switch) {
            defaultPrice = LpToken.price0CumulativeLast();
        } else if (price != 0) {
            defaultPrice = price;
        }
        return defaultPrice;
    }


    function queryHomePageInfo(address owner) public view returns (
        uint256 userPending,
        uint256 userBalance,
        uint256 marketMap,
        uint256 circulation,
        uint256 burned,
        uint256 block,
        uint256 maxARP,
        uint256 TVL,
        uint256 tokenPrice){

        uint256 userPending;
        uint256 userBalance;
        uint256 marketMap;
        uint256 circulation;
        uint256 burned;
        uint256 block;
        uint256 maxARP;
        uint256 TVL;
        uint256 tokenPrice;

        if (owner == address(0)) {
            userPending = 0;
            userBalance = 0;
        } else if (poolInfo.length <= 0) {
            userPending = 0;
            userBalance = _dreamWorks.balanceOf(owner);
        } else {
            for (uint256 i = 0; i <= poolInfo.length; i++) {
                userPending = userPending.add(_masterChef.pendingCake(i, user));
            }
        }
        userBalance = _dreamWorks.balanceOf(owner);
        marketMap = _dreamWorks.totalSupply().mul(defaultPrice);
        circulation = _dreamWorks.totalSupply();
        burned = _dreamWorks.balanceOf(address(0));
        block = cakePerBlock;
        maxARP = _maxARP;
        TVL = _defaultTotalTVL;
        tokenPrice =  _defaultPrice;
        return (userPending, userBalance, marketMap, circulation, burned, block, maxARP, TVL, tokenPrice);
    }


    //---------------------------------------------------Share-------------------------------------------------------//

    mapping(address => address[]) inviterAddress;
    mapping(address => mapping(address => bool))  inviterCheck;
    mapping(address => address) invitedPeopleMappingInviter;
    uint256 private _defaultReward = 50;

    function inviteUser(address inviter, address invitedPeople) public returns (bool){
        require(inviter != address(0) || invitedPeople != address(0), 'address(0) is not allow ');
        require(!inviterCheck[inviter][invitedPeople], 'An invitation has been made. Do not repeat the invitation');
        require(!invitedPeopleCheck[invitedPeople][inviter], 'An invitation has been made. Do not repeat the invitation');
        require(!_blackAddress[inviter], 'inviter is black address');
        invitedPeopleMappingInviter[invitedPeople] = inviter;
        inviterCheck[inviter][invitedPeople] = true;
        inviterCheck[invitedPeople][inviter] = true;
        inviterAddress[inviter].push(invitedPeople);
        _dreamWorks._mint(invitedPeople, _defaultReward);
        return true;
    }

    //----------------------------------------------DreamNFT----------------------------------------------------------//
    uint256 private  _defaultTokenPrice = 1000;
    uint256 private  _defaultICOTokenNum = 150000000;
    uint256 private  _quantityNFTSold = 0;
    uint256 private  _quantityDreamToken = 0;

    function queryBlindBoxInfo() public view returns (uint256 boxPrice, uint256 boxTotalNum, uint256 quantitySold){
        uint256 boxTotalNum = _defaultICOTokenNum.div(_defaultTokenPrice);
        return (_defaultTokenPrice, boxTotalNum, _quantityNFTSold);
    }

    function buyApprove(address user, uint amount) public returns (bool){
        _dreamWorks.approve(address(this), amount.mul(_defaultTokenPrice));
        return true;
    }

    function buyDreamNFT(address user, uint256 amount) public payable returns (uint256[] tokenId){
        require(user != address(0), 'address(0) is not allow ');
        require(amount > 0, 'amount must Greater than zero');
        require(_dreamWorks._allowances[user][address(this)] >= amount, 'Licensing is required');
        _dreamWorks.transferFrom(user, address(0), amount.mul(_defaultTokenPrice));
        uint256[] memory tokenId;
        for (uint256 i = 0; i <= amount; i++) {
            tokenId.push(_dreamNFT.create());
        }
        if (invitedPeopleMappingInviter[user] != address(0) && !_blackAddress[invitedPeopleMappingInviter[user]]) {
            _dreamWorks._mint(invitedPeopleMappingInviter[user], amount.mul(_defaultTokenPrice).div(10));
        }
        _quantityNFTSold = _quantityNFTSold.add(tokenId.length);
        return tokenId;
    }


    function queryDreamTokenICOInfo() public view returns (uint256 defaultPrice, uint256 ICOTotal, uint256 quantityDreamToken){
        return (_defaultPrice, _defaultICOTokenNum, _quantityDreamToken);
    }

    function buyDreamTokenApprove(address user, uint256 amount) public returns (bool){
        require(user != address(0), 'address(0) is not allow ');
        require(amount > 0, 'amount must Greater than zero');
        _tokenType.approve(dev, amount.mul(_defaultPrice));
        return ture;
    }

    function buyDreamToken(address user, uint256 amount) public payable returns (bool){
        require(user != address(0), 'address(0) is not allow ');
        require(amount > 0, 'amount must Greater than zero');
        require(_tokenType._allowances[user][dev] >= amount, 'Licensing is required');
        _tokenType.transferFrom(user, dev, amount * _defaultPrice);
        _dreamWorks.mint(user, amount);
        _quantityDreamToken = _quantityDreamToken.add(amount);
        return true;
    }

    //----------------------------------------------Market------------------------------------------------------------/
    mapping(uint256 => uint256) private tokenIdOnSale;
    mapping(uint256 => uint256) private tokenIdOnSalePrice;
    mapping(uint256 => address) private tokenApprove;
    mapping(uint256 => uint256) private tokenIdMappingMarketId;
    uint256[] onSaleToken;


    function tokenInfoById(uint256 tokenId) public view returns (Role memory role){
        require(tokenId >= 0, 'Invalid tokenId');
        return _dreamNFT.AllRoles[tokenId];
    }

    function tokenInfoByIds(uint256[] tokenIds) public view returns (Role[] memory roles){
        require(tokenIds.length > 0, 'Invalid tokenId');
        Role[] memory roles;
        for (uint256 i = 0; i <= tokenIds.length; i++) {
            if (!tokenIds[i] > 0) {
                roles.push(_dreamNFT.AllRoles[tokenIds[i]]);
            }
        }
        return roles;
    }

    function userCollectionTokenId(address user) public view returns (uint256 tokenId){
        require(user != address(0), 'address(0) is not allow ');
        return _dreamNFT._ownAllRoleIds[user];
    }

    function userOnSaleApprove(address user, uint256 tokenId) public returns (bool){
        require(user != address(0), 'address(0) is not allow ');
        require(tokenId > 0, 'Invalid tokenId');
        require(_dreamNFT._tokenOwnInfo[tokenId] == user, 'Must be the owner to operate');

        _dreamNFT.approve(address(this), tokenId);
        tokenApprove[tokenId] = address(this);

        return true;
    }

    function userOnSaleOrShelves(address user, uint256 tokenId, uint256 amount, bool onSale) public returns (bool){
        require(user != address(0), 'address(0) is not allow ');
        require(tokenId > 0, 'Invalid tokenId');
        require(_dreamNFT._tokenOwnInfo[tokenId] == user, 'Must be the owner to operate');
        require(tokenApprove[tokenId] == address(this), 'Not approve');

        if (onSale) {
            require(!tokenIdOnSale[tokenId], 'Token is already on the shelves');
            tokenIdOnSalePrice[tokenId] = amount;
            tokenIdOnSale[tokenId] = true;
            onSaleToken.push(tokenId);
            tokenIdMappingMarketId[tokenId] = onSaleToken.length - 1;
        } else {
            require(tokenIdOnSale[tokenId], 'Token must  on the shelves');
            tokenIdOnSale[tokenId] = false;
        }
        return true;
    }

    function queryAllOnSaleToken() public returns (uint256[]){
        return onSaleToken;
    }

    function buyDreamNFTToken(address user,uint256 tokenId) public payable returns (bool){
        require(user != address(0), 'address(0) is not allow ');
        require(amount > 0, 'Invalid tokenId');

    }


}