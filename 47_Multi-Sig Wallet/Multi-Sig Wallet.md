# Multi-Sig Wallet
让我们创建一个多签钱包。以下是规格说明。

钱包所有者可以：

提交交易
批准和撤销待处理交易的批准
只要足够的所有者已经批准了交易，任何人就可以执行交易。

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public numConfirmationsRequired;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    // 从交易索引 => 拥有者 => 布尔值的映射
    mapping(uint => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsRequired > 0 &&
                _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
    }
//当合约收到以太币时会被自动调用。在该合约中，收到以太币时会触发 Deposit 事件。
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }
//该函数用于提交一笔交易，需要传入目标地址、转账金额、交易数据。只有合约的所有者才有权限调用该函数。该函数会将交易信息存储在 transactions 数组中，并触发 SubmitTransaction 事件。
    function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwner {
        uint txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }
//该函数用于确认一笔交易，需要传入交易在 transactions 数组中的索引。只有合约的所有者才有权限调用该函数。
//该函数会将该交易的确认数加一，并将该交易在 isConfirmed 数组中对应的值设为 true，同时触发 ConfirmTransaction 事件。
    function confirmTransaction(
        uint _txIndex
    ) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }
//该函数用于执行一笔交易，需要传入交易在 transactions 数组中的索引。只有合约的所有者才有权限调用该函数。
//该函数会检查该交易的确认数是否达到要求，如果达到要求则执行该交易，否则会抛出异常。执行完毕后会将该交易的 executed 属性设为 true，并触发 ExecuteTransaction 事件。
    function executeTransaction(
        uint _txIndex
    ) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }
//该函数用于撤销对一笔交易的确认，需要传入交易在 transactions 数组中的索引。只有合约的所有者才有权限调用该函数。
//该函数会将该交易的确认数减一，并将该交易在 isConfirmed 数组中对应的值设为 false，同时触发 RevokeConfirmation 事件。
    function revokeConfirmation(
        uint _txIndex
    ) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }
//该函数用于获取合约的所有者列表，返回一个地址数组。
    function getOwners() public view returns (address[] memory) {
        return owners;
    }
//该函数用于获取当前交易的数量，返回一个整数。
    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }
//该函数用于获取指定索引的交易信息，返回一个元组，包含目标地址、转账金额、交易数据、是否执行、确认数等信息。
    function getTransaction(
        uint _txIndex
    )
        public
        view
        returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
}
```
以下是一个测试从多签钱包发送交易的合约


```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TestContract {
    uint public i;

    function callMe(uint j) public {
        i += j;
    }

    function getData() public pure returns (bytes memory) {
        return abi.encodeWithSignature("callMe(uint256)", 123);
    }
}
```

# remix验证
1.传入所有人地址数组和确认数，部署合约。
![47-1.png](img/47-1.png)
2.调用submitTransaction函数，提交一笔交易
![47-2.png](img/47-2.png)
3.调用confirmTransaction函数确认交易，输入交易交易在 transactions 数组中的索引
![47-3.png](img/47-3.png)
4.调用getOwners函数查看所有者地址，调用getTransactionCount()函数查看当前交易数，并使用getTransaction函数索引交易信息
![47-4.png](img/47-4.png)