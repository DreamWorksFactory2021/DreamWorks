pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;
import "../math/SafeMath.sol";
import "./DreamWorksToken.sol";
contract EpTemplate{

    using SafeMath for math;
    DreamWorksToken _dreamWork;
    uint32  public _epPrice;
    uint256 public _partNum;
    uint256 public _epTotal;
    uint256 public _joinIdoTotal;
    address private _epDevAddress;
    BEP20 _payToken;
    constructor(BEP20 dreamWork, BEP20 payToken, uint256 epTotal, uint256 partNum,
        uint32 epPrice, address epDevAddress) internal {
        _dreamWork = dreamWork;
        _epTotal = epTotal;
        _joinIdoTotal = 0;
        _epDevAddress = epDevAddress;
        _epPrice = epPrice;
        _partNum = partNum;
        _payToken = payToken;
    }

    mapping(address => uint32) joinList;

    function joinEpApprove() external returns (bool){
        _payToken.approve(msg.sender, msg.value);
    }

    function joinEp() external payable returns (bool) {
        require(_joinIdoTotal <= _epTotal, "reached the maximum number of Ido");
        _payToken.transferFrom()(msg.sender, _epDevAddress, msg.value);
        uint256 mintNumber = math.div(msg.value, _epPrice);
        _dreamWork.mint(msg.sender, math.mul(mintNumber, _partNum));
        _joinIdoTotal += number;
        joinList[msg.sender] = math.mul(mintNumber, _partNum);
        return true;
    }

    function payRole(uint8 payNum) external payable returns (uint256[] memory) {
        require(payNum > 0, "The minimum purchase quantity is 1");
        _dreamWork.transferFrom(msg.sender, address(0), math.mul(_basePrice, payNum));
        uint256[] memory roleIds ;
        for (uint i = 0; i <= payNum; i++) {
            roleIds.push(_roleTemplate.create());
        }
        return roleIds;
    }
}