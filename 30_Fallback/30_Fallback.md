# 30.Fallback
fallback是一种特殊的函数，当以下情况发生时执行：
1.调用不存在的函数时；
2.将以太币直接发送到合约但receive( )不存在或msg.data不为空时。
当通过transfer或send调用时，fallback的gas限制为2300。