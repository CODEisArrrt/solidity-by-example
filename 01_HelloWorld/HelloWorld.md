
#01 Hello World


```solidity
// SPDX-License-Identifier: MIT
// 编译器版本必须大于或等于0.8.17，但小于0.9.0。同时，使用pragma solidity ^0.8.17指令来告诉编译器采用0.8.17及以上的版本进行编译。

pragma solidity ^0.8.17;

contract HelloWorld {
    string public greet = "Hello World!";
}
```
第一行是注释，代码所用的软件许可，这里用的是MIT license.如果不写 编译时会警告 但可以运行
solidity的注释用//开头 不会被运行
```solidity
//SPDX-License-Identifier:MIT
```
声明版本号的范围 0.8.17-0.9.0
```solidity
//compiler version must be greater than or equal to 0.8.17 and less than 0.9.0 pragma solidity ^0.8.17;
```
```solidity
//创建合约 合约名为Hello World
//声明string（字符串）public可被任何人调用 变量_string 赋值“Hello World”

contract HelloWorld {
    string public = "Hello World";

} 
```