# Write to Any Slot
Solidity存储类似于长度为2^256的数组。数组中的每个槽位可以存储32个字节。


声明顺序和状态变量的类型定义了它将使用哪些槽位。

但是，使用汇编语言，您可以写入任何槽位。
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library StorageSlot {
    // 将地址包装在结构体中，以便可以将其作为存储指针传递
    struct AddressSlot {
        address value;
    }

    function getAddressSlot(
        bytes32 slot
    ) internal pure returns (AddressSlot storage pointer) {
        assembly {
            // 获取存储在槽位上的AddressSlot的指针
            pointer.slot := slot
        }
    }
}

//这里使用了StorageSlot库，它提供了对存储槽的访问，通过getAddressSlot函数可以获取一个地址类型的存储槽。
contract TestSlot {
    bytes32 public constant TEST_SLOT = keccak256("TEST_SLOT");

    function write(address _addr) external {
        StorageSlot.AddressSlot storage data = StorageSlot.getAddressSlot(TEST_SLOT);
        data.value = _addr;
    }

    function get() external view returns (address) {
        StorageSlot.AddressSlot storage data = StorageSlot.getAddressSlot(TEST_SLOT);
        return data.value;
    }
}
```