#Reading and Writing to a State Variable
要写入或更新状态变量，您需要发送交易。

另一方面，您可以免费读取状态变量，无需任何交易费用。

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract SimpleStorage {
    // State variable to store a number
    uint public num;

    // You need to send a transaction to write to a state variable.
    function set(uint _num) public {
        num = _num;
    }

    // You can read from a state variable without sending a transaction.
    function get() public view returns (uint) {
        return num;
    }
}
```