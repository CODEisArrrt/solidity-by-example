# Primitive Data Types


在这里，我们介绍 Solidity 中一些可用的原始数据类型。

boolean//布尔型
uint256//256位正整数
int256//256位整数（包括负数
address//地址类型

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Primitives {
    bool public boo = true;

    /*
    uint 代表无符号整数，表示非负整数
    有不同的大小可用
        uint8   范围从 0 到 2 ** 8 - 1
        uint16  范围从 0 到 2 ** 16 - 1
        …
        uint256 范围从 0 到 2 ** 256 - 1
    */
    uint8 public u8 = 1;
    uint public u256 = 456;
    uint public u = 123; // uint is an alias for uint256

    /*
    int 类型允许负数。
    和 uint 类型一样，可以有不同范围，从 int8 到 int256
    
    int256 范围从 -2 ** 255 到 2 ** 255 - 1
    int128 范围从 -2 ** 127 到 2 ** 127 - 1
    */
    int8 public i8 = -1;
    int public i256 = 456;
    int public i = -123; 
    //  int 和 int256 相同

    // int 的最小值和最大值
    int public minInt = type(int).min;
    int public maxInt = type(int).max;

    address public addr = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;

    /*
    在 Solidity 中，数据类型 byte 表示一系列字节。 
    Solidity 提供了两种字节类型：

     - 固定大小的字节数组
     - 动态大小的字节数组。
     
     在 Solidity 中，bytes这个词表示字节的 动态数据。 
     它是 byte[] 的缩写。
    */
    bytes1 a = 0xb5; //  [10110101]
    bytes1 b = 0x56; //  [01010110]

    //默认值
    // 未分配的变量有一个默认值
    bool public defaultBoo; // false错误
    uint public defaultUint; // 0
    int public defaultInt; // 0
    address public defaultAddr; // 0x0000000000000000000000000000000000000000
}
```
## remix验证
编译并部署代码查看数据类型
![1-1.png](png/3-1.png)