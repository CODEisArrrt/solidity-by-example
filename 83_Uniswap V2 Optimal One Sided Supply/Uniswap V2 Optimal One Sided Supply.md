# 83.Uniswap V2 Optimal One Sided Supply
Optimal One Sided Supply


这是一个用于Uniswap交易的智能合约，实现了一种名为"Optimal One-Sided Supply"的策略，即优化单边提供流动性。

具体来说，该合约实现了以下功能：

1. 从一个ERC20代币（WETH除外）转账给合约一定数量的代币；
2. 计算出最优的交换数量，用于在Uniswap上将该代币交换成另一个代币；
3. 将计算出的最优交换数量的代币进行交换，并获得相应数量的另一个代币；
4. 将两种代币以最优比例添加到Uniswap的流动性池中。
该合约的目的是在提供流动性时，最大化用户的收益。

```solidity
address private constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
address private constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

function sqrt(uint y) private pure returns (uint z) {
    if (y > 3) {
        z = y;
        uint x = y / 2 + 1;
        while (x < z) {
            z = x;
            x = (y / x + x) / 2;
        }
    } else if (y != 0) {
        z = 1;
    }
}
```

s = 最佳交换金额 
r = 代币a的储备量
a = 用户当前持有的代币a数量（尚未添加到储备中）
f = 交易手续费百分比
s = (sqrt(((2 - f)r)^2 + 4(1 - f)ar) - (2 - f)r) / (2(1 - f))

```solidity
function getSwapAmount(uint r, uint a) public pure returns (uint) {
    return (sqrt(r * (r * 3988009 + a * 3988000)) - r * 1997) / 1994;
}
```

最佳单边供应
1. 从代币 A 到代币 B 进行最佳兑换
2. 添加流动性
```solidity
function zap(address _tokenA, address _tokenB, uint _amountA) external {
    require(_tokenA == WETH || _tokenB == WETH, "!weth");

    IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);

    address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);
    (uint reserve0, uint reserve1, ) = IUniswapV2Pair(pair).getReserves();

    uint swapAmount;
    if (IUniswapV2Pair(pair).token0() == _tokenA) {
        //从代币0兑换到代币1
        swapAmount = getSwapAmount(reserve0, _amountA);
    } else {
        // 从代币1兑换到代币0
        swapAmount = getSwapAmount(reserve1, _amountA);
    }

    _swap(_tokenA, _tokenB, swapAmount);
    _addLiquidity(_tokenA, _tokenB);
}

function _swap(address _from, address _to, uint _amount) internal {
    IERC20(_from).approve(ROUTER, _amount);

    address[] memory path = new address[](2);
    path = new address[](2);
    path[0] = _from;
    path[1] = _to;

    IUniswapV2Router(ROUTER).swapExactTokensForTokens(
        _amount,
        1,
        path,
        address(this),
        block.timestamp
    );
}

function _addLiquidity(address _tokenA, address _tokenB) internal {
    uint balA = IERC20(_tokenA).balanceOf(address(this));
    uint balB = IERC20(_tokenB).balanceOf(address(this));
    IERC20(_tokenA).approve(ROUTER, balA);
    IERC20(_tokenB).approve(ROUTER, balB);

    IUniswapV2Router(ROUTER).addLiquidity(
        _tokenA,
        _tokenB,
        balA,
        balB,
        0,
        0,
        address(this),
        block.timestamp
    );
}
```
Uniswap v2 的接口
swapExactTokensForTokens 用于交换代币，即以一种代币换取另一种代币，并返回交换后的代币数量。
```solidity
interface IUniswapV2Router {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IUniswapV2Factory {
    function getPair(address token0, address token1) external view returns (address);
}

interface IUniswapV2Pair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
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
}
```