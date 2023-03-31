# Gas
一笔交易需要支付多少以太币?
您支付的是gas使用量*gas价格的以太币数量，其中

gas是计算单位
gas使用量是交易中使用的总gas量
gas价格是指你愿意支付多少gas
gas价格越高的交易，优先级越高

未使用的gas将被退还.

Gas 限制
可以使用的gas量有两个限制

gas 限制 (您愿意为您的交易使用的最大gas量，由您设定)
区块gas限制 (一个区块允许的最大gas量，由网络设定)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Gas {
    uint public i = 0;

    // 使用完所有的gas会使交易失败.
    // 状态更改被撤消.
    // 消耗的gas不会退回.
    function forever() public {
        // 这里是个while循环，直到所有gas消耗完
        // 并导致交易失败
        while (true) {
            i += 1;
        }
    }
}
```