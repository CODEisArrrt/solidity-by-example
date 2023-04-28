# 58.Uni-Directional Payment Channel

Uni-Directional Payment Channel（单向支付通道）是一种基于区块链技术的支付协议，允许两个参与者在不必等待区块链确认的情况下进行多次交易。
该协议允许参与者在通道内进行任意次数的交易，只有最终结算会被写入区块链。
这种支付通道可以提高交易速度和降低交易费用，同时保持区块链的安全性和去中心化特性。

以下是该合同的使用方式：

* Alice部署合同，并用一些ETH进行资金投入。
* Alice通过签署消息（链下）授权支付，并将签名发送给Bob。
* Bob通过向智能合约呈现签名的方式领取付款。
* 如果Bob不领取付款，则合同过期后Alice可以收回她的ETH。
这被称为单向支付通道，因为支付只能从Alice向Bob单向进行。
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/cryptography/ECDSA.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/security/ReentrancyGuard.sol";

contract UniDirectionalPaymentChannel is ReentrancyGuard {
    using ECDSA for bytes32;

    address payable public sender;
    address payable public receiver;

    uint private constant DURATION = 7 * 24 * 60 * 60;
    uint public expiresAt;

    constructor(address payable _receiver) payable {
        require(_receiver != address(0), "receiver = zero address");
        sender = payable(msg.sender);
        receiver = _receiver;
        expiresAt = block.timestamp + DURATION;
    }

    function _getHash(uint _amount) private view returns (bytes32) {
        // 注释: 在此合同上签名并附上地址，以防止对其他合同进行重放攻击。
        return keccak256(abi.encodePacked(address(this), _amount));
    }

    function getHash(uint _amount) external view returns (bytes32) {
        return _getHash(_amount);
    }

    function _getEthSignedHash(uint _amount) private view returns (bytes32) {
        return _getHash(_amount).toEthSignedMessageHash();
    }

    function getEthSignedHash(uint _amount) external view returns (bytes32) {
        return _getEthSignedHash(_amount);
    }

    function _verify(uint _amount, bytes memory _sig) private view returns (bool) {
        return _getEthSignedHash(_amount).recover(_sig) == sender;
    }

    function verify(uint _amount, bytes memory _sig) external view returns (bool) {
        return _verify(_amount, _sig);
    }

    function close(uint _amount, bytes memory _sig) external nonReentrant {
        require(msg.sender == receiver, "!receiver");
        require(_verify(_amount, _sig), "invalid sig");

        (bool sent, ) = receiver.call{value: _amount}("");
        require(sent, "Failed to send Ether");
        selfdestruct(sender);
    }

    function cancel() external {
        require(msg.sender == sender, "!sender");
        require(block.timestamp >= expiresAt, "!expired");
        selfdestruct(sender);
    }
}
```