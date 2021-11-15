pragma solidity ^0.6.12;
import "https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";


contract getPrice{

    AggregatorV3Interface internal priceFeed;



function getLatestPrice() public view returns (int) {
        (
        uint80 roundID,
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }

    constructor(address LpToken){
        priceFeed = AggregatorV3Interface(LpToken);
    }
}