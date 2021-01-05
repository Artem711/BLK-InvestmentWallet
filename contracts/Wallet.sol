
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IYDAI {
    function deposit(uint256 _amount) external;
    function withdraw(uint256 _shares) external;
    function balanceOf(address account) external view returns (uint);
    function getPricePerFullShare() external view returns (uint);
}

contract Wallet {
    address admin;
    IERC20 dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IYDAI yDai = IYDAI(0xC2cB1040220768554cf699b0d863A3cd4324ce32);

    constructor() {
        admin = msg.sender;
    }

    function balance() external view returns(uint) {
        uint price = yDai.getPricePerFullShare();
        uint balanceShares = yDai.balanceOf(address(this));
        return balanceShares * price;
    }

    function save(uint _amount) external {
        dai.transferFrom(msg.sender, address(this), _amount);
        _save(_amount);
    }

    function spend(uint _amount, address _recipient) external {
        require(msg.sender == admin, "Only admin");
        uint balanceShares = yDai.balanceOf(address(this));
        yDai.withdraw(balanceShares);
        dai.transfer(_recipient, _amount);
        uint balanceDai = dai.balanceOf(address(this));
        if (balanceDai > 0) { _save(balanceDai); }
    }

    function _save(uint _amount) private {
        dai.approve(address(yDai), _amount);
        yDai.deposit(_amount);
    }

}