// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface IERC20{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
}
contract Multicall {
    function info(address _addr) public view returns(string memory name, string memory symbol,uint256 balance){
        name = IERC20(_addr).name();
        symbol = IERC20(_addr).symbol();
        balance = IERC20(_addr).balanceOf(msg.sender);
    }

    // function infos(address[] memory path) public returns(userGroup[]){
    //     mapping(uint => Info[]) infoMap;
    //     for(uint i = 0; i < path.length; i ++ ){
    //         string memory name = IERC20(path[i]).name();
    //         string memory symbol = IERC20(path[i]).symbol();
    //         uint256 balance = IERC20(path[i]).balanceOf(msg.sender);
    //         infoMap[i]push(name, symbol, balance);
    //     }
    // }
}