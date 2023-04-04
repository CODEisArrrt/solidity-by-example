# 14.Enum
Solidity支持枚举类型，它们非常有用，可以模拟选择并跟踪状态。
枚举类型可以在合约外声明。
## 枚举 enum
枚举（enum）是solidity中用户定义的数据类型。它主要用于为uint分配名称，使程序易于阅读和维护。它与C语言中的enum类似，使用名称来代替从0开始的uint。
枚举表示运输状态。
```solidity
enum Status {
    Pending,
    Shipped,
    Accepted,
    Rejected,
    Canceled
}
```
默认数值是列出的第一个元素,在这种情况下，“Pending”的定义是“待处理的”。
```solidity
Status public status;

    // 返回值为无符号整数uint
    // 待处理 - 0
    // 已发货 - 1
    // 已接受 - 2
    // 已拒绝 - 3
    // 已取消 - 4
function get() public view returns (Status) {
    return status;
}
```
通过将uint传入输入来更新状态
```solidity
function set(Status _status) public {
    status = _status;
}
```
你可以通过以下方式更新到特定的枚举
```solidity
function cancel() public {
    status = Status.Canceled;
}
```
删除会将枚举重置为其第一个值，即0。
```solidity
function reset() public {
    delete status;
}
```
## remix验证
1. 部署合约Enum，调用cancel（）函数，get（）函数显示为4.
![14-1.png](./img/14-1.png)
2. 调用reset（）函数，get（）函数显示为0.
![14-2.png](./img/14-2.png)
3. 调用set（）函数，输入1，get（）函数显示为1.
![14-3.png](./img/14-3.png)
