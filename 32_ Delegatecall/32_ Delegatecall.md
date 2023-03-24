# 32.Delegatecall
delegatecall是类似于call的低级函数。
当合约A执行delegatecall到合约B时，B的代码将在合约A的storage、msg.sender和msg.value下执行。
部署合约B，存储布局必须与合约A相同。
```solidity
contract B {
    uint public num;
    address public sender;
    uint public value;

    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}
```
部署合约A
```solidity
contract A {
    uint public num;
    address public sender;
    uint public value;

    function setVars(address _contract, uint _num) public payable {
        // A的存储设置已经完成，B没有被修改。
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }
}
```