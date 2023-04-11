# Constants

常量是不可修改的变量。

它们的值是硬编码的，使用常数可以节省gas成本。

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Constants {
    // 编码约定将常量变量大写
    address public constant MY_ADDRESS = 0x777788889999AaAAbBbbCcccddDdeeeEfFFfCcCc;
    uint public constant MY_UINT = 123;
}
```

## remix验证
1.编译并部署代码
![5-1.png](png/5-1.png)
2.调用MY_ADDRESS显示地址，调用MY_UINT显示整数
![5-2.png](png/5-2.png)