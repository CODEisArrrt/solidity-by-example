# 87.Uniswap V3 Flash Loan
## Uniswap V3 闪电贷示例


此合约的核心是flash函数和uniswapV3FlashCallback函数。flash函数允许用户在同一交易中借贷代币并进行交易。它将借入的代币发送到合约地址，并使用Uniswap V3的flash函数进行交易。在交易完成后，uniswapV3FlashCallback函数将被调用，用于还款和交易。如果在交易中产生了任何费用，此函数将还款并将余额发送回Uniswap V3池子。

此合约还使用了PoolAddress库，用于计算Uniswap V3池子地址。

```solidity

address private constant FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

struct FlashCallbackData {
    uint amount0;
    uint amount1;
    address caller;
}

IERC20 private immutable token0;
IERC20 private immutable token1;

IUniswapV3Pool private immutable pool;
```
接受两个ERC20代币地址和一个手续费，然后获取对应的Uniswap V3池子的地址。
```solidity
constructor(address _token0, address _token1, uint24 _fee) {
    token0 = IERC20(_token0);
    token1 = IERC20(_token1);
    pool = IUniswapV3Pool(getPool(_token0, _token1, _fee));
}
```
根据两个ERC20代币地址和手续费计算对应的Uniswap V3池子地址。
```solidity
function getPool(
    address _token0,
    address _token1,
    uint24 _fee
) public pure returns (address) {
    PoolAddress.PoolKey memory poolKey = PoolAddress.getPoolKey(
        _token0,
        _token1,
        _fee
    );
    return PoolAddress.computeAddress(FACTORY, poolKey);
}
```
允许用户借贷一定数量的代币，同时在同一交易中进行交易。
```solidity
function flash(uint amount0, uint amount1) external {
    bytes memory data = abi.encode(
        FlashCallbackData({amount0: amount0, amount1: amount1, caller: msg.sender})
    );
    IUniswapV3Pool(pool).flash(address(this), amount0, amount1, data);
}
```
当flash函数被调用时，Uniswap V3池子将调用此函数，用于还款和交易。
```solidity
function uniswapV3FlashCallback(
    uint fee0,
    uint fee1,
    bytes calldata data
) external {
    require(msg.sender == address(pool), "not authorized");

    FlashCallbackData memory decoded = abi.decode(data, (FlashCallbackData));

    // 偿还借款
    if (fee0 > 0) {
        token0.transferFrom(decoded.caller, address(this), fee0);
        token0.transfer(address(pool), decoded.amount0 + fee0);
    }
    if (fee1 > 0) {
        token1.transferFrom(decoded.caller, address(this), fee1);
        token1.transfer(address(pool), decoded.amount1 + fee1);
    }
}

library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH =
        0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    function computeAddress(
        address factory,
        PoolKey memory key
    ) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint160(
                uint(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encode(key.token0, key.token1, key.fee)),
                            POOL_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }
}

interface IUniswapV3Pool {
    function flash(
        address recipient,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;
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
## 使用Foundry进行测试
请将此复制并粘贴到您 Foundry 项目中的测试文件夹中。

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/UniswapV3Flash.sol";

contract UniswapV3FlashTest is Test {
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    uint24 constant POOL_FEE = 3000;

    IWETH private weth = IWETH(WETH);
    IERC20 private usdc = IERC20(USDC);

    UniswapV3Flash private uni = new UniswapV3Flash(USDC, WETH, POOL_FEE);

    function setUp() public {}

    function testFlash() public {
        // 批准WETH手续费
        weth.deposit{value: 1e18}();
        weth.approve(address(uni), 1e18);

        uint balBefore = weth.balanceOf(address(this));
        uni.flash(0, 100 * 1e18);
        uint balAfter = weth.balanceOf(address(this));

        uint fee = balBefore - balAfter;
        console.log("WETH fee", fee);
    }
}
```
执行以下命令来运行测试
```solidity

FORK_URL=https://eth-mainnet.g.alchemy.com/v2/613t3mfjTevdrCwDl28CVvuk6wSIxRPi
forge test -vv --gas-report --fork-url $FORK_URL --match-path test/UniswapV3FlashTest.test.sol
```
## 链接
[Foundry](https://github.com/foundry-rs/foundry)

[Uniswap V3 Foundry example](https://github.com/t4sk/defi-notes)