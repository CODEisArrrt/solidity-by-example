# Interface
您可以通过声明接口与其他合约交互。

## 接口

不能有任何函数实现
可以继承其他接口
所有声明的函数必须是外部的
不能声明构造函数
不能声明状态变量

简单合约
```solidity
contract Counter {
    uint public count;

    function increment() external {
        count += 1;
    }
}
```

### 接口
```solidity
interface ICounter {
    function count() external view returns (uint);

    function increment() external;
}
contract MyContract {
    //接受一个地址参数_counter，调用ICounter接口中的increment函数来增加_counter地址对应的计数器
    function incrementCounter(address _counter) external {
        ICounter(_counter).increment();
    }
    
    //接受一个地址参数_counter，返回ICounter接口中的count函数返回的计数器值
    function getCount(address _counter) external view returns (uint) {
        return ICounter(_counter).count();
    }
}
```

### Uniswap 列子
```solidity
interface UniswapV2Factory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface UniswapV2Pair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract UniswapExample {
    address private factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function getTokenReserves() external view returns (uint, uint) {
        address pair = UniswapV2Factory(factory).getPair(dai, weth);
        (uint reserve0, uint reserve1, ) = UniswapV2Pair(pair).getReserves();
        return (reserve0, reserve1);
    }
}
```


## remix验证
1.部署Counter 合约，调用increment()函数，增加计数器数值
![27-1.jpg](img/27-1.jpg)
2.部署MyContract合约，调用incrementCounter函数，输入Counter合约地址，调用ICounter 接口中的函数来操作计数器。incrementCounter() 函数用于增加计数器的值，getCount() 函数用于获取计数器的值。
![27-2.jpg](img/27-2.jpg)