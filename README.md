# NSArray：避免越界导致的崩溃

2018-05-20 更新：

添加‘可变数组插入对象’方法替换，当对象是nil时，替换为Null对象。此外可变数组的越界问题没有做处理。

其实APP崩溃也是为防止情况进一步恶化，无论是越界还是插入nil对象，怎么替换方法也无法保证APP按预想运行。相反崩溃能更快发现代码中的逻辑问题。

--

作为开发，时常遇到数组越界导致的崩溃。于是我就想怎么来解决这个问题。

常用方法就是哪处崩溃就在那儿增加限制，比如将

```
array[i]
```

改为

```
array[MIN(i, array.count-1)]
```

但这是亡羊补牢的做法，我们无法预测哪儿会发生崩溃并及时修改。于是我就想用一个新方法来替换原`objectAtIndex:`方法，网上找了些资料用到`runtime`了。

给`NSArray`增加一个类别，然后实现方法切换:

```
+ (void)load {
    Method original = class_getInstanceMethod(self, @selector(objectAtIndex:));
    Method new = class_getInstanceMethod(self, @selector(ABObjectAtIndex:));
    method_exchangeImplementations(original, new);
}

- (id)ABObjectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        return [NSNull null];
    } else {
        return [self ABObjectAtIndex:index];
    }
}
```
测试一下

```
NSArray *arr = [NSArray array];
NSLog(@"%@",arr[2]);

```

结果没有起作用，依然会发生崩溃。后来咨询一番才知道是因为`类簇`导致。其实在崩溃信息里也能初见端倪：

```
*** Terminating app due to uncaught exception 'NSRangeException', reason: '*** -[__NSArray0 objectAtIndex:]: index 10 beyond bounds for empty NSArray'
```
网上有文章介绍到：

>1、当元素为空时，返回的是__NSArray0的单例；

>2、当元素仅有一个时，返回的是__NSSingleObjectArrayI的实例；

>3、当元素大于一个的时候，返回的是__NSArrayI的实例。

文章可能不完全准确，不过意思也能明白。所以我修改了一下获取实例方法：

```
Method original = class_getInstanceMethod(NSClassFromString(@"__NSArray0"), @selector(objectAtIndex:));
Method new = class_getInstanceMethod(NSClassFromString(@"__NSArray0"), @selector(ABObjectAtIndex:));
```
运行不再崩溃，输出信息：

```
2018-05-16 14:09:00.037078+0800 CrashesSolutionDemo[56954:7187640] <null>
```

这只是空数组的情况，还有单个元素和多个元素情况:

```
//单元素数组
    Method original1 = class_getInstanceMethod(NSClassFromString(@"__NSSingleObjectArrayI"), @selector(objectAtIndex:));
    Method new1 = class_getInstanceMethod(NSClassFromString(@"__NSSingleObjectArrayI"), @selector(ABObject1AtIndex:));
    method_exchangeImplementations(original1, new1);

//多元素数组
    Method original2 = class_getInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndex:));
    Method new2 = class_getInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(ABObject2AtIndex:));
    method_exchangeImplementations(original2, new2);
```

运行后还是有崩溃：

```
*** Terminating app due to uncaught exception 'NSRangeException', reason: '*** -[__NSArrayI objectAtIndexedSubscript:]: index 10 beyond bounds [0 .. 1]'
```
因为我测试都是使用的语法糖：

```
    NSArray *array1 = [NSArray array];
    NSArray *array2 = @[@"1"];
    NSArray *array3 = @[@"1",@"2"];
    
    NSLog(@"array1 - %@",array1[10]);
    NSLog(@"array2 - %@",array2[10]);
    NSLog(@"array3 - %@",array3[10]);
```
多元素数组没有直接调用`objectAtIndex:`，而是`objectAtIndexedSubscript: `。如果这样写：

```
NSLog(@"array3 - %@",[array3 objectAtIndex:10]);
```
就没有问题。关于语法糖，苹果还有一套。
看下文档：

```
- (ObjectType)objectAtIndexedSubscript:(NSUInteger)idx;
```
> This method has the same behavior as the objectAtIndex: method.

> If index is beyond the end of the array (that is, if index is greater than or equal to the value returned by count), an NSRangeException is raised.

> You shouldn’t need to call this method directly. Instead, this method is called when accessing an object by index using subscripting.

好吧，都说了通过下表索引就会自动调用这个方法。能怎办？继续加替换方法呗。

###### <mark>这只是解决数组越界问题初步方案,而且类簇问题解决的也不好，需要改进的地方还有很多
demo用Xcode9创建

---

### 参考链接：
[iOS开发之原来Runtime的黑魔法这么厉害](https://www.jianshu.com/p/d26536d39ab0)

[类簇，从NSArray说起](https://www.aopod.com/2017/02/24/class-clusters/)