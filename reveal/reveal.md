<img src="reveal.png" style="width:90px;">
##Inspect. Modify. Debug.
#####Reveal brings powerful runtime view debugging to iOS developers

**准备材料：**

* 越狱设备 数据线
* Mac Reveal工具
* Xcode

**原理:**

* 手机和设备通过局域网连接通信
* 越狱设备可以加入一个lib还有plist，监听到应用的window，以及上面的所有UI的结构视图

**教程:**

* 越狱设备（自己找越狱教程）越狱后，需要在Cydia工具里，安装openSSH MobileSubstrate
* 先获取应用Bundle ID，记录下来，获取方法：(reveal Loader工具也挺好用，不用自己建立plist)

```
    NSMutableArray *arrayM = [NSMutableArray array];
    NSBundle *b = [NSBundle bundleWithPath:@"/System/Library/Frameworks/MobileCoreServices.framework"];
    Class LSApplicationWorkspace = NSClassFromString(@"LSApplicationWorkspace");
    id si = [LSApplicationWorkspace valueForKey:@"defaultWorkspace"];
    NSArray *appsInfoArr =  [si valueForKey:@"allInstalledApplications"];
    [appsInfoArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [arrayM addObject:[obj performSelector:@selector(applicationIdentifier)]];
    }];
    NSLog(@"%@",arrayM);
```

* 编辑产生libReveal.plist文件
* 移动libReveal.plist 和libReveal.dylib文件到iphone上

```
由于公司的内网配置的问题，这里我不能简单的通过相同相同网段直接局域网连接。
我尝试过mac作为热点，连接都不行，而且就算连接上，其实速度也很慢。
但是，大神很多，竟然还能直接通过usb协议连接。
1.brew install usbmuxd
2.iproxy 4567 22
3.ssh -p 4567 root@127.0.0.1
4.scp Desktop/libReveal.dylib root@192.168.x.x:/Library/MobileSubstrate/DynamicLibraries
5.scp -P 4567 Desktop/libReveal.plist root@127.0.0.1:/Library/MobileSubstrate/DynamicLibraries/
6.killall SpringBoard（重启）
Tips: 默认密码 alpine
```
