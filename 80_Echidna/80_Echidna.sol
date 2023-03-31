// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
echidna-test TestEchidna.sol --contract TestCounter
*/
contract Counter {
    uint public count;

    function inc() external {
        count += 1;
    }

    function dec() external {
        count -= 1;
    }
}

contract TestCounter is Counter {
    function echidna_test_true() public view returns (bool) {
        return true;
    }

    function echidna_test_false() public view returns (bool) {
        return false;
    }

    function echidna_test_count() public view returns (bool) {
        // 在这里我们正在测试Counter.count应该始终<= 5。
        // 测试将失败。Echidna足够聪明，可以调用Counter.inc()超过5次。
        return count <= 5;
    }
}

/*
echidna-test TestEchidna.sol --contract TestAssert --check-asserts
*/
contract TestAssert {
    // 0.8版本中未检测到断言。
    // 切换到0.7版本以测试断言。
    function test_assert(uint _i) external {
        assert(_i < 10);
    }

    // 更复杂的例子
    function abs(uint x, uint y) private pure returns (uint) {
        if (x >= y) {
            return x - y;
        }
        return y - x;
    }

    function test_abs(uint x, uint y) external {
        uint z = abs(x, y);
        if (x >= y) {
            assert(z <= x);
        } else {
            assert(z <= y);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/*
docker run -it --rm -v $PWD:/code trailofbits/eth-security-toolbox
echidna-test EchidnaTestTimeAndCaller.sol --contract EchidnaTestTimeAndCaller
*/
contract EchidnaTestTimeAndCaller {
    bool private pass = true;
    uint private createdAt = block.timestamp;

    /*
    test will fail if Echidna can call setFail()
    test will pass otherwise
    */
    function echidna_test_pass() public view returns (bool) {
        return pass;
    }

    function setFail() external {
        /*
        如果延迟小于最大块延迟，Echidna可以调用此函数。
        否则，Echidna将无法调用此函数。
        最大块延迟可以通过在配置文件中指定来扩展。
        */
        uint delay = 7 days;
        require(block.timestamp >= createdAt + delay);
        pass = false;
    }

    // 默认发件人
    // 更改地址以查看测试失败
    address[3] private senders = [
        address(0x10000),
        address(0x20000),
        address(0x00a329C0648769a73afAC7F9381e08fb43DBEA70)
    ];

    address private sender = msg.sender;

    // 将 _sender 作为输入并要求 msg.sender == _sender，
    // 以查看 _sender 的计数示例。
    function setSender(address _sender) external {
        require(_sender == msg.sender);
        sender = msg.sender;
    }

    // 检查默认发件人。发件人应该是三个默认帐户之一。
    function echidna_test_sender() public view returns (bool) {
        for (uint i; i < 3; i++) {
            if (sender == senders[i]) {
                return true;
            }
        }
        return false;
    }
}
