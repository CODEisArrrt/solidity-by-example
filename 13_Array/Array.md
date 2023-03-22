#Array
数组可以在编译时具有固定长度，也可以具有动态长度

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Array {
    // 初始化数组的几种方式
    uint[] public arr;
    uint[] public arr2 = [1, 2, 3];
    // 固定长度的数组，所有元素都初始化为0
    uint[10] public myFixedSizeArr;

    function get(uint i) public view returns (uint) {
        return arr[i];
    }

    // Solidity 可以返回整个数组.
    // 但是对于长度可以无限增长的数组，应该避免使用此类函数.
    function getArr() public view returns (uint[] memory) {
        return arr;
    }

    function push(uint i) public {
        // 在数组末尾添加元素
        // 这将使数组长度增加1.
        arr.push(i);
    }

    function pop() public {
        // 删除数组中的最后一个元素
        // 这将使数组长度减少1
        arr.pop();
    }

    function getLength() public view returns (uint) {
        return arr.length;
    }

    function remove(uint index) public {
        // delete 不会改变数组长度
        // 它将索引处的值重置为其默认值，这里为0 value,
        delete arr[index];
    }

    function examples() external {
        // 在内存中创建数组，只能创建固定大小的数组
        uint[] memory a = new uint[](5);
    }
}
```
###删除数组元素的示例
通过将元素从右到左移动来删除数组元素

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ArrayRemoveByShifting {
    // [1, 2, 3] -- remove(1) --> [1, 3, 3] --> [1, 3]
    // [1, 2, 3, 4, 5, 6] -- remove(2) --> [1, 2, 4, 5, 6, 6] --> [1, 2, 4, 5, 6]
    // [1, 2, 3, 4, 5, 6] -- remove(0) --> [2, 3, 4, 5, 6, 6] --> [2, 3, 4, 5, 6]
    // [1] -- remove(0) --> [1] --> []

    uint[] public arr;

    function remove(uint _index) public {
        require(_index < arr.length, "index out of bound");

        for (uint i = _index; i < arr.length - 1; i++) {
            arr[i] = arr[i + 1];
        }
        arr.pop();
    }

    function test() external {
        arr = [1, 2, 3, 4, 5];
        remove(2);
        // [1, 2, 4, 5]
        assert(arr[0] == 1);
        assert(arr[1] == 2);
        assert(arr[2] == 4);
        assert(arr[3] == 5);
        assert(arr.length == 4);

        arr = [1];
        remove(0);
        // []
        assert(arr.length == 0);
    }
}
```
通过将最后一个元素复制到要删除的位置来删除数组元素


```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ArrayReplaceFromEnd {
    uint[] public arr;

    // 删除一个元素会在数组中创建一个间隙.
    // 保持数组紧凑的一个技巧是将最后一个元素移动到要删除的位置.
    function remove(uint index) public {
        // Move the last element into the place to delete
        arr[index] = arr[arr.length - 1];
        // Remove the last element
        arr.pop();
    }

    function test() public {
        arr = [1, 2, 3, 4];

        remove(1);
        // [1, 4, 3]
        assert(arr.length == 3);
        assert(arr[0] == 1);
        assert(arr[1] == 4);
        assert(arr[2] == 3);

        remove(2);
        // [1, 4]
        assert(arr.length == 2);
        assert(arr[0] == 1);
        assert(arr[1] == 4);
    }
}
```