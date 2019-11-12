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



