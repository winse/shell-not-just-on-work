## Debug with Eclipse

#### 查找控制窗口的标准输出

1. 用Find查找System.out。
2. 在System类的out变量处打断点。这样再次输出的时刻，就会进到断点就知道输出的位置了。

#### 不修改代码在指定位置添加调试输出信息

通过条件断点增加输出：`System.out.println(your-variable);false`

![](https://user-images.githubusercontent.com/667902/36820578-8040c4ea-1d29-11e8-9540-65527b7a9437.png)

