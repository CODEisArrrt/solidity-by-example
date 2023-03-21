# 6.不变量
不可变变量就像常量一样。不可变变量的值可以在构造函数中设置，但之后不能修改。
immutable变量可以在声明时或构造函数中初始化，因此更加灵活。
```solidity
// 将编码规范转换为大写的常量变量
address public immutable MY_ADDRESS;
uint public immutable MY_UINT;

constructor(uint _myUint) {
    MY_ADDRESS = msg.sender;
    MY_UINT = _myUint;
}
```