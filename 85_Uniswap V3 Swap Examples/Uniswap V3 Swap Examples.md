# 85.Uniswap V3 Swap Examples
## Uniswap V3 交换示例

该合约封装了 Uniswap V3 的交换功能，包括单跳交换和多跳交换。

1. swapExactInputSingleHop(address tokenIn, address tokenOut, uint24 poolFee, uint amountIn) external returns (uint amountOut) 函数：用于进行单跳交换，将 tokenIn 代币的 amountIn 数量进行兑换，以获得尽可能多的 tokenOut 代币。该函数使用 Uniswap V3 的 exactInputSingle 函数进行交换，并需要传入以下参数：
* tokenIn：输入代币地址。
* tokenOut：输出代币地址。
* poolFee：交易所使用的手续费率，取值为 500、3000 或 10000。
* amountIn：输入代币的数量。

```solidity
function swapExactInputSingleHop(
    address tokenIn,
    address tokenOut,
    uint24 poolFee,
    uint amountIn
) external returns (uint amountOut) {
    IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
    IERC20(tokenIn).approve(address(router), amountIn);

    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
        .ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: poolFee,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

    amountOut = router.exactInputSingle(params);
}
```

2. swapExactInputMultiHop(bytes calldata path, address tokenIn, uint amountIn) external returns (uint amountOut) 函数：用于进行多跳交换，将 tokenIn 代币的 amountIn 数量进行兑换，以获得尽可能多的目标代币。该函数使用 Uniswap V3 的 exactInput 函数进行交换，并需要传入以下参数：
* path：交换路径，是一个字节数组，包含了交换所需的所有代币地址。
* tokenIn：输入代币地址。
* amountIn：输入代币的数量。
```solidity
function swapExactInputMultiHop(
    bytes calldata path,
    address tokenIn,
    uint amountIn
) external returns (uint amountOut) {
    IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
    IERC20(tokenIn).approve(address(router), amountIn);

    ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
        path: path,
        recipient: msg.sender,
        deadline: block.timestamp,
        amountIn: amountIn,
        amountOutMinimum: 0
    });
    amountOut = router.exactInput(params);
}
```
该合约还包含了三个接口：

* ISwapRouter 接口：定义了 Uniswap V3 的交换路由器接口，包括单跳交换和多跳交换的函数原型和参数结构体。
* IERC20 接口：定义了 ERC20 标准代币接口，包括代币的余额、转账、授权等函数原型。
* IWETH 接口：定义了 WETH 代币接口，包括将 ETH 转换为 WETH 和将 WETH 转换为 ETH 的函数原型。
```solidity

interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint deadline;
        uint amountIn;
        uint amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice 将一个代币的 amountIn 进行兑换，以获得尽可能多的另一个代币
    /// @param params 兑换所需的参数，以 calldata 中的 ExactInputSingleParams 编码形式提供
    /// @return amountOut 获得代币的数量
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint deadline;
        uint amountIn;
        uint amountOutMinimum;
    }

    /// @notice  在指定路径上将一个代币的 amountIn 尽可能多的交换另一个代币
    /// @param params 多跳交换所需的参数，以 calldata 中的 ExactInputParams 编码
    /// @return amountOut 接收到的代币数量
    function exactInput(
        ExactInputParams calldata params
    ) external payable returns (uint amountOut);
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
## 与 Foundry 进行测试
将其复制并粘贴到 Foundry 项目中的测试文件夹中

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/UniswapV3SwapExamples.sol";

address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

contract UniV3Test is Test {
    IWETH private weth = IWETH(WETH);
    IERC20 private dai = IERC20(DAI);
    IERC20 private usdc = IERC20(USDC);

    UniswapV3SwapExamples private uni = new UniswapV3SwapExamples();

    function setUp() public {}

    function testSingleHop() public {
        weth.deposit{value: 1e18}();
        weth.approve(address(uni), 1e18);

        uint amountOut = uni.swapExactInputSingleHop(WETH, DAI, 3000, 1e18);

        console.log("DAI", amountOut);
    }

    function testMultiHop() public {
        weth.deposit{value: 1e18}();
        weth.approve(address(uni), 1e18);

        bytes memory path = abi.encodePacked(
            WETH,
            uint24(3000),
            USDC,
            uint24(100),
            DAI
        );

        uint amountOut = uni.swapExactInputMultiHop(path, WETH, 1e18);

        console.log("DAI", amountOut);
    }
}
```
执行以下命令以运行测试
```solidity
FORK_URL=https://eth-mainnet.g.alchemy.com/v2/613t3mfjTevdrCwDl28CVvuk6wSIxRPi
forge test -vv --gas-report --fork-url $FORK_URL --match-path test/UniswapV3SwapExamples.test.sol
```
## 链接
[Uniswap V3](https://docs.uniswap.org/protocol/guides/swaps/single-swaps)
[Foundry](https://github.com/foundry-rs/foundry)
[Uniswap V3 Foundry example](https://github.com/t4sk/defi-notes)