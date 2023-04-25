# 84.Uniswap V2 Flash Swap
## Uniswap V2 Flash Swap的例子
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IUniswapV2Callee {
    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;
}

contract UniswapV2FlashSwap is IUniswapV2Callee {
    address private constant UNISWAP_V2_FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IUniswapV2Factory private constant factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);

    IERC20 private constant weth = IERC20(WETH);

    IUniswapV2Pair private immutable pair;

    // 对于这个例子，存储要偿还的金额。
    uint public amountToRepay;

    constructor() {
        pair = IUniswapV2Pair(factory.getPair(DAI, WETH));
    }

    function flashSwap(uint wethAmount) external {
        // 需要传递一些数据以触发uniswapV2Call。
        bytes memory data = abi.encode(WETH, msg.sender);

        // amount0Out 是 DAI，amount1Out 是 WETH。
        pair.swap(0, wethAmount, address(this), data);
    }

    // 这个函数是由DAI/WETH交易对合约调用的。
    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external {
        require(msg.sender == address(pair), "not pair");
        require(sender == address(this), "not sender");

        (address tokenBorrow, address caller) = abi.decode(data, (address, address));

        // 您的自定义代码将放在这里。例如，套利代码。
        require(tokenBorrow == WETH, "token borrow != WETH");

        // 大约0.3%的费用，+1向上取整
        uint fee = (amount1 * 3) / 997 + 1;
        amountToRepay = amount1 + fee;

        // 将闪电交换费从调用者转移
        weth.transferFrom(caller, address(this), fee);

        // 还款
        weth.transfer(address(pair), amountToRepay);
    }
}

interface IUniswapV2Pair {
    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;
}

interface IUniswapV2Factory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint amount) external;
}
```
## 测试与Foundry
1. 将此复制并粘贴到您的铸造项目的测试文件夹中
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/UniswapV2FlashSwap.sol";

address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

contract UniswapV2FlashSwapTest is Test {
    IWETH private weth = IWETH(WETH);

    UniswapV2FlashSwap private uni = new UniswapV2FlashSwap();

    function setUp() public {}

    function testFlashSwap() public {
        weth.deposit{value: 1e18}();
        // 批准闪兑费用
        weth.approve(address(uni), 1e18);

        uint amountToBorrow = 10 * 1e18;
        uni.flashSwap(amountToBorrow);

        assertGt(uni.amountToRepay(), amountToBorrow);
    }
}
```
2. 执行以下命令来运行测试。
```solidity
FORK_URL=https://eth-mainnet.g.alchemy.com/v2/613t3mfjTevdrCwDl28CVvuk6wSIxRPi
forge test -vv --gas-report --fork-url $FORK_URL --match-path test/UniswapV2FlashSwap.test.sol
```