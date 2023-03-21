# 20.Function Modifier

修饰器是可以在函数调用之前 and/or 之后运行的代码。
修饰器可以用于：
1、限制访问权限
2、验证输入
3、防止重入攻击

修饰器可用于检查调用者是否是合约的所有者。

```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "Not owner");
    // 下划线是一种特殊字符，仅在函数修饰器中使用，
    // 它告诉Solidity继续执行代码的其余部分。
    _;
}
```

修饰器可以接受输入参数。该修饰器检查传入的地址是否为零地址。

```solidity
modifier validAddress(address _addr) {
    require(_addr != address(0), "Not valid address");
    _;
}

function changeOwner(address _newOwner) public onlyOwner validAddress(_newOwner) {
    owner = _newOwner;
}
```
修饰器可以在函数之前and/or之后被调用；这个修饰器防止在函数执行时调用它。
```solidity
modifier noReentrancy() {
    require(!locked, "No reentrancy");

    locked = true;
    _;
    locked = false;
}

function decrement(uint i) public noReentrancy {
    x -= i;

    if (i > 1) {
        decrement(i - 1);
    }
}
```
