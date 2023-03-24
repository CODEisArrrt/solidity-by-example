# 42.Verifying Signature
消息可以在链外进行签名，然后使用智能合约在链上进行验证。
[Example using ethers.js](https://github.com/t4sk/hello-erc20-permit/blob/main/test/verify-signature.js)

如何签名和验证
## Signing
1. 创建要签名的消息。
2. 对消息进行哈希处理。
3. 对哈希值进行签名（离线进行，保持私钥机密）。
## Verify
1. 从原始消息重新创建哈希值。
2. 从签名和哈希值中恢复签名者。
3. 将恢复的签名者与声明的签名者进行比较。