pragma solidity ^0.6.12;

import "./DreamWorksToken.sol";
import "./DreamNFT.sol";
import "./MasterChef.sol";
import "../math/SafeMath.sol";
import "../token/BEP20/BEP20.sol";

contract Core {

    using SafeMath for uint256;

    DreamWorksToken private _dreamWork;
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
        _dreamWork = dreamWork;
        _dreamNFT = dreamNFT;
        _masterChef = masterChef;
        _USDT = 0x55d398326f99059ff775485246999027b3197955;
    }



    //---------------------------------Home--------------------------------------------------//
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
            userBalance = _dreamWork.balanceOf(owner);
        } else {
            for (uint256 i = 0; i <= poolInfo.length; i++) {
                userPending = userPending.add(_masterChef.pendingCake(i, user));
            }
        }
        userBalance = _dreamWork.balanceOf(owner);
        marketMap = _dreamWork.totalSupply().mul(defaultPrice);
        circulation = _dreamWork.totalSupply();
        burned = _dreamWork.balanceOf(address(0));
        block = cakePerBlock;
        maxARP = _maxARP;
        TVL = _defaultTotalTVL;
        tokenPrice = _defaultPrice;
        return (userPending, userBalance, marketMap, circulation, burned, block, maxARP, TVL, tokenPrice);
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
        _dreamWork.approve(address(this), amount.mul(_defaultTokenPrice));
        return true;
    }

    function buyDreamNFT(address user, uint256 amount) public payable returns (uint256[] tokenId){
        require(user != address(0), 'address(0) is not allow ');
        require(amount > 0, 'amount must Greater than zero');
        require(_dreamWork._allowances[user][address(this)] >= amount, 'Licensing is required');
        _dreamWork.transferFrom(user, address(0), amount.mul(_defaultTokenPrice));
        uint256[] memory tokenId;
        for (uint256 i = 0; i <= amount; i++) {
            tokenId.push(_dreamNFT.create());
        }
        _quantityNFTSold = _quantityNFTSold.add(tokenId.length);
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
        _dreamWork.mint(user, amount);
        _quantityDreamToken = _quantityDreamToken.add(amount);
        return true;
    }
}