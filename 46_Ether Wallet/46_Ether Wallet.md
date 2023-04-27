# 46.Ether Wallet
举一个基本钱包的例子。

* 任何人都可以发送ETH。
* 只有所有者才能提取。
```solidity

contract EtherWallet {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {}

    function withdraw(uint _amount) external {
        require(msg.sender == owner, "caller is not owner");
        payable(msg.sender).transfer(_amount);
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}
```

## remix验证

1. 部署合约，账号为0x5B...eedC4.
![46-1.jpg](img/46-1.jpg)
2. 通过CALLDATA调用receive（）转入1ETH,查看合约金额和所有者
![46-2.jpg](img/46-2.jpg)
3. 调用withdraw（）函数，调用者为owner时，调用成功。
![46-3.jpg](img/46-3.jpg)
4. 切换账号为0xAb8...35cb2
![46-4.jpg](img/46-4.jpg)
5. 再次尝试调用withdraw（），调用失败。调用者不为owner
![46-5.jpg](img/46-5.jpg)

