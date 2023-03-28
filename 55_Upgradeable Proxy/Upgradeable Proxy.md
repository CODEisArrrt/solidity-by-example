#Upgradeable Proxy
这是一个可升级代理合约的示例。请勿在生产环境中使用。
本示例展示了：

如何使用delegatecall和在fallback被调用时返回数据。
如何将管理员和实现的地址存储在特定的槽中。



```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// 透明可升级代理模式


contract CounterV1 {
    uint public count;

    function inc() external {
        count += 1;
    }
}

contract CounterV2 {
    uint public count;

    function inc() external {
        count += 1;
    }

    function dec() external {
        count -= 1;
    }
}

contract BuggyProxy {
    address public implementation;
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    function _delegate() private {
        (bool ok, bytes memory res) = implementation.delegatecall(msg.data);
        require(ok, "delegatecall failed");
    }

    fallback() external payable {
        _delegate();
    }

    receive() external payable {
        _delegate();
    }

    function upgradeTo(address _implementation) external {
        require(msg.sender == admin, "not authorized");
        implementation = _implementation;
    }
}

contract Dev {
    function selectors() external view returns (bytes4, bytes4, bytes4) {
        return (
            Proxy.admin.selector,
            Proxy.implementation.selector,
            Proxy.upgradeTo.selector
        );
    }
}

contract Proxy {
    // 所有函数/变量应为私有的，将所有调用转发到fallback

    // -1表示未知的preimage

    // 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
    bytes32 private constant IMPLEMENTATION_SLOT =
        bytes32(uint(keccak256("eip1967.proxy.implementation")) - 1);
    // 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103
    bytes32 private constant ADMIN_SLOT =
        bytes32(uint(keccak256("eip1967.proxy.admin")) - 1);

    constructor() {
        _setAdmin(msg.sender);
    }

    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    function _getAdmin() private view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    function _setAdmin(address _admin) private {
        require(_admin != address(0), "admin = zero address");
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
    }

    function _getImplementation() private view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address _implementation) private {
        require(_implementation.code.length > 0, "implementation is not contract");
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
    }

    // 管理员接口 //
    function changeAdmin(address _admin) external ifAdmin {
        _setAdmin(_admin);
    }

    // 0x3659cfe6
    function upgradeTo(address _implementation) external ifAdmin {
        _setImplementation(_implementation);
    }

    // 0xf851a440
    function admin() external ifAdmin returns (address) {
        return _getAdmin();
    }

    // 0x5c60da1b
    function implementation() external ifAdmin returns (address) {
        return _getImplementation();
    }

    // 用户接口  //
    function _delegate(address _implementation) internal virtual {
        assembly {
            // 复制msg.data。我们在这个内联汇编块中完全控制内存，因为它将不会返回Solidity代码。我们将Solidity的划痕垫覆盖在内存位置0上。
           

            // calldatacopy(t, f, s) - 将大小为s的calldata从位置f复制到位置t的mem中
            // calldatasize() - call data的大小（以字节为单位）calldatacopy(0, 0, calldatasize())

            // 调用实现。
            // out和outsize都为0，因为我们还不知道大小。

            // delegatecall(g, a, in, insize, out, outsize) -
            // - 调用地址为a的合约
            // - 使用输入mem[in…(in+insize))
            // - 提供g gas
            // - 并将输出区域mem[out…(out+outsize))中的数据返回
            // - 在发生错误（例如gas用尽）时返回0，在成功时返回1
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            // 复制返回的数据
            // returndatacopy(t, f, s) - 将大小为s的returndata从位置f复制到mem中的位置t
            // returndatasize() - 上一次returndata的大小
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall在发生错误时返回0。
            case 0 {
                // revert(p, s) - 结束执行，撤销状态更改，返回数据mem[p…(p+s))
            }
            default {
                // return(p, s) - 结束执行，返回数据mem[p…(p+s))
                return(0, returndatasize())
            }
        }
    }

    function _fallback() private {
        _delegate(_getImplementation());
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }
}

contract ProxyAdmin {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function getProxyAdmin(address proxy) external view returns (address) {
        (bool ok, bytes memory res) = proxy.staticcall(abi.encodeCall(Proxy.admin, ()));
        require(ok, "call failed");
        return abi.decode(res, (address));
    }

    function getProxyImplementation(address proxy) external view returns (address) {
        (bool ok, bytes memory res) = proxy.staticcall(
            abi.encodeCall(Proxy.implementation, ())
        );
        require(ok, "call failed");
        return abi.decode(res, (address));
    }

    function changeProxyAdmin(address payable proxy, address admin) external onlyOwner {
        Proxy(proxy).changeAdmin(admin);
    }

    function upgrade(address payable proxy, address implementation) external onlyOwner {
        Proxy(proxy).upgradeTo(implementation);
    }
}

library StorageSlot {
    struct AddressSlot {
        address value;
    }

    function getAddressSlot(
        bytes32 slot
    ) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}
//使用 StorageSlot.getAddressSlot 函数来获取一个地址类型的槽位，并通过 value 属性来读写该槽位的值。
contract TestSlot {
    bytes32 public constant slot = keccak256("TEST_SLOT");

    function getSlot() external view returns (address) {
        return StorageSlot.getAddressSlot(slot).value;
    }

    function writeSlot(address _addr) external {
        StorageSlot.getAddressSlot(slot).value = _addr;
    }
}
```