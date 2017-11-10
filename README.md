# LongDispatch

Grand Central Dispatch (GCD) 是Apple开发的一个多核编程的较新的解决方法。它主要用于优化应用程序以支持多核处理器以及其他对称多处理系统。它是一个在线程池模式的基础上执行的并行任务。在Mac OS X 10.6雪豹中首次推出，也可在IOS 4及以上版本使用。

GCD平时使用最多的场景是:

```
dispatch_async(dispatch_get_global_queue(0,0),^{

});
```

如果里面执行的代码是一个比较耗时的操作，例如网络请求，对应的线程就不会立即释放。如果代码没有对上述代码做限制，很有可能会造成设备无法开启新线程。一般最多可以开70-80个线程。为了避免这种场景的出现，基于GCD简单实现了一个LongDispatch，可以设置最大的并发数，限制开启过多的线程。

## 集成LongDispatch

通过cocoapods集成

```
pod 'LongDispatch'
```

集成

```
初始化LongDispatch实例
LongDispatch *dispatch = [LongDispatch new];

//添加任务
[dispatch addTask:^{
	//do something
}];

//取消所有任务
[dispatch cancelAllTask];
```

## Relase Note

### v1.0.3
* 修复任务处理问题

### v1.0.2
* 优化任务处理判断逻辑

### v1.0.1
* 修复LongDispatch偶尔crash的问题

### v1.0.0
* 实现线程管理，可以限制提交任务的最大并发数
