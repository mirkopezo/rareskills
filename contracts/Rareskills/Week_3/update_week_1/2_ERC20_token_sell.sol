// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./1_ERC20_with_sanctions.sol";

contract ERC20TokenSell is ERC20withSanction {
    uint public avaiableTokensToSell;
    uint private constant TOKEN_SALE_SIZE = 22_000_000 * 10**18;
    uint private constant CONVERSION_RATE = 10_000;

    //mint all tokens at once, token sale happens through owner account with approval.
    constructor() ERC20withSanction("TokenSell", "TKS") {
        avaiableTokensToSell = TOKEN_SALE_SIZE;
    }

    //Simple tokens sale. Build an ERC20 with the above features that sells tokens at a conversion rate of 10,000 tokens to 1 ethereum.
    //The total supply should be 22 million tokens.
    function buyTokens() external payable override {
        //value is in wei
        uint neededTokens = msg.value * CONVERSION_RATE;

        require(avaiableTokensToSell > neededTokens, "Not enough tokens");

        _mint(msg.sender, neededTokens);
        avaiableTokensToSell -= neededTokens;
    }

    function sellTokens(uint amount) external payable override {
        require(balanceOf(msg.sender) >= amount, "not enough tokens");

        uint etherToSendBack = amount / CONVERSION_RATE;
        require(etherToSendBack > address(this).balance, "Not enough ether for payout");

        _burn(msg.sender, amount);

        //Conversion 1:10000
        payable(msg.sender).transfer(etherToSendBack);
    }
}
