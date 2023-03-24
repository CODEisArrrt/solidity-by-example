abi.encode将数据编码为字节。
```solidity
function encode(
        uint x,
        address addr,
        uint[] calldata arr,
        MyStruct calldata myStruct
    ) external pure returns (bytes memory) {
        return abi.encode(x, addr, arr, myStruct);
    }
```
abi.decode将字节解码回数据。
```solidity
function decode(
    bytes calldata data
)
    external
    pure
    returns (uint x, address addr, uint[] memory arr, MyStruct memory myStruct)
{
    // (uint x, address addr, uint[] memory arr, MyStruct myStruct) = ...
    (x, addr, arr, myStruct) = abi.decode(data, (uint, address, uint[], MyStruct));
}
```