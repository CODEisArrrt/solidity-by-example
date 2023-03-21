// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract A {
    string public name = "Contract A";

    function getName() public view returns (string memory) {
        return name;
    }
}

// Solidity 0.6版本中禁止屏蔽。
// 这样将无法编译。
// contract B is A {
//     string public name = "Contract B";
// }

contract C is A {
    // 这是覆盖继承状态变量的正确方法。
    constructor() {
        name = "Contract C";
    }

    // C.getName returns "Contract C"
}
