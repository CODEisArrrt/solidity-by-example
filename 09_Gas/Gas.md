Gas
一笔交易需要支付多少以太币?
您支付的是燃气使用量*燃气价格的以太币数量，其中

gas is a unit of computation
gas spent is the total amount of gas used in a transaction
gas price is how much ether you are willing to pay per gas
Transactions with higher gas price have higher priority to be included in a block.

Unspent gas will be refunded.

Gas Limit
There are 2 upper bounds to the amount of gas you can spend

gas limit (max amount of gas you're willing to use for your transaction, set by you)
block gas limit (max amount of gas allowed in a block, set by the network)

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Gas {
    uint public i = 0;

    // Using up all of the gas that you send causes your transaction to fail.
    // State changes are undone.
    // Gas spent are not refunded.
    function forever() public {
        // Here we run a loop until all of the gas are spent
        // and the transaction fails
        while (true) {
            i += 1;
        }
    }
}