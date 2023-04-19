# 10.if/else
Solidity支持条件语句if、else if和else。
### 1.if/else
```solidity
function foo(uint x) public pure returns (uint) {
    if (x < 10) {
        return 0;
    } else if (x < 20) {
        return 1;
    } else {
        return 2;
    }
}
```
### 2.三元运算符 
三元运算符是solidity中唯一一个接受三个操作数的运算符，规则条件? 条件为真的表达式:条件为假的表达式。 此运算符经常用作 if 语句的快捷方式。
```solidity
function ternary(uint _x) public pure returns (uint) {
    // if (_x < 10) {
    //     return 1;
    // }
    // return 2;

    // if/else语句的速记写法
    // "?" 运算符被称为三元运算符。
    return _x < 10 ? 1 : 2;
}
```