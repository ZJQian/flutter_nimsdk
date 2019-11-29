## flutter_nimsdk

[![pub package](https://img.shields.io/pub/v/flutter_nimsdk.svg)](https://pub.dev/packages/flutter_nimsdk)

用于`Flutter`的网易云信SDK
    
    
## 已完成功能

### 音视频

* 初始化  
* 登录
* 自动登录
* 登陆状态回调
* 登出
* 主动发起通话请求
* 接收到通话请求
* 被叫响应通话请求
* 主叫收到被叫响应回调
* 通话建立结果回调
* 挂断
* 收到对方结束通话回调
* 通话断开
* 获取话单
* 清空本地话单
* 动态设置摄像头开关
* 动态切换前后摄像头
* 设置静音

### IM
* 最近会话列表
* 所有最近会话
* 文本消息
* 提示消息
* 图片消息
* 视频消息
* 音频消息
* 文件消息
* 位置消息
* 开始录音
* 结束录音
* 取消录音
 

## 部分示例

### 初始化

使用前，先进行初始化：
      
```dart 

SDKOptions sdkOptions = SDKOptions(appKey: appkey);
await FlutterNimsdk().initSDK(sdkOptions);

```


### 登录

```dart
LoginInfo loginInfo = LoginInfo(account: "",token: "");
FlutterNimsdk().login(loginInfo).then((result) {
   print(result);
});

```

### 退出登录

```dart
await FlutterNimsdk().logout();
```

### 发起通话

```dart

String time = currentTimeMillis();
String extendMessage = '{"currentTimeStamp":"${time}"}';
NIMNetCallOption callOption = NIMNetCallOption(extendMessage: extendMessage,apnsContent: "apnsContent",apnsSound: "apnsSound");

FlutterNimsdk().start(beijiaoID.toString(), NIMNetCallMediaType.Video, callOption,time).then((result) {
        
      print(result);
        
  });
}
  

```
**注意: 扩展消息`extendMessage`这里加上了一个当前时间的时间戳, 是为了避免挂断视频通话后再次发起通话出现的闪退问题. **

### 回调

```dart

//数据接收
  void _onEvent(Object value) {
    print(value);

    /**
     * delegateType 的值对应的回调
     * 
     * 
     * NIMDelegateTypeOnLogin = 0,
     * NIMDelegateTypeOnReceive = 1,
     * NIMDelegateTypeOnResponse = 2,
     * NIMDelegateTypeOnCallEstablished = 3,
     * NIMDelegateTypeOnHangup = 4,
     * NIMDelegateTypeOnCallDisconnected = 5,
     * NIMDelegateTypeDidAddRecentSession = 6,
     * NIMDelegateTypeDidUpdateRecentSession = 7,
     * NIMDelegateTypeDidRemoveRecentSession = 8,
     * NIMDelegateTypeRecordAudioComplete = 9,
     */

  }
  
```

以上是插件中用到的回调，具体请参照网易云信文档回调接口名称一一对应。例如：

```Objective-C
NIMDelegateTypeOnLogin表示的是登陆状态回调：

- (void)onLogin:(NIMLoginStep)step{

}

```

根据delegateType来区分各种回调。


### 视频窗口
通过`UIKitView`组件,根据`viewType`区分原生`view`.

例如:

```dart

// LocalDisplayView是当前用户视频窗口. 即对主叫来说,代表的是主叫视频窗口; 对被叫来说,代表的是被叫视频窗口
// RemoteDisplayView表示的就是对方视频窗口. 对主叫来说,被叫是对方;对被叫来说,主叫是对方.
	Stack(
        children: <Widget>[
          Container(
            width: window.physicalSize.width,
            height: window.physicalSize.height,
            child: UiKitView(
              viewType: "LocalDisplayView-${widget.timeStamp}",
            ),
          ),
          Container(
            width: 100,
            height: 150,
            child: UiKitView(
              viewType: "RemoteDisplayView-${widget.timeStamp}",
            ),
          ),
        ],
      ),

```

**注意: 只有当接受视频请求后并且本次通话成功建立后, 才可以进行向视频页面跳转的操作**

