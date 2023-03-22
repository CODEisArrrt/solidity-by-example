# 26.Visibility
函数和状态变量必须声明它们是否可以被其他合约访问。
函数可以声明为：

* public - 任何合约和账户都可以调用。
* private - 仅限于定义该函数的合约内部。
* internal- 仅限于继承内部函数的合约内部。
* external - 仅其他合约和账户可以调用。
状态变量可以声明为public、private或internal，但不能声明为external。
