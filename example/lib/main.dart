import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_nimsdk/flutter_nimsdk.dart';
import 'dart:convert';
import 'package:flutter_alert/flutter_alert.dart';
import 'video.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: HomeWidget()
      ),
    );
  }
}

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget>{

   StreamSubscription _streamSubscription;
  ScrollController controller = ScrollController();

  //  28   f51d1656315ac021d623f556dd493985
  //  27   ae93a01e9a3f087e1e85a7de731955dc
  // int zhujiaoID = 27;
  // String zhujiaoToken = "ae93a01e9a3f087e1e85a7de731955dc";
  // int beijiaoID = 28;

  int zhujiaoID = 28;
  String zhujiaoToken = "f51d1656315ac021d623f556dd493985";
  int beijiaoID = 137604;
  
  String callID = "";


  @override
  void initState() {
    super.initState();
    registerNIMSDK("8c2ed2ed508d1dacea2f0007852605ae");
    _streamSubscription = FlutterNimsdk().eventChannel().receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  @override
  void dispose() {
    if (_streamSubscription != null) {
      _streamSubscription.cancel();
      _streamSubscription = null;
    }
    super.dispose();
  }

  //数据接收
  void _onEvent(Object value) {

    //  /**
    //  * delegateType 的值对应的回调
    //  * 
    //  * 
    //  * NIMDelegateTypeOnLogin = 0,
    //  * NIMDelegateTypeOnReceive = 1,
    //  * NIMDelegateTypeOnResponse = 2,
    //  * NIMDelegateTypeOnCallEstablished = 3,
    //  * NIMDelegateTypeOnHangup = 4,
    //  * NIMDelegateTypeOnCallDisconnected = 5,
    //  * NIMDelegateTypeDidAddRecentSession = 6,
    //  * NIMDelegateTypeDidUpdateRecentSession = 7,
    //  * NIMDelegateTypeDidRemoveRecentSession = 8,
    //  * NIMDelegateTypeRecordAudioComplete = 9,
    //  */
    Map<String,dynamic> result = json.decode(value);
    int delegateType = result["delegateType"];
    print(value);

    if (delegateType == 1) {

      callID = result["callID"];
    } else if (delegateType == 2) {
      
    }


  }
  // 错误处理
  void _onError(dynamic) {
    print("on error");
  }

// 注册
  void registerNIMSDK(String appkey) async {
        SDKOptions sdkOptions = SDKOptions(appKey: appkey);
        await FlutterNimsdk().initSDK(sdkOptions);   
  }
// 登录
  void login() {
    //  28   f51d1656315ac021d623f556dd493985
    //  27   ae93a01e9a3f087e1e85a7de731955dc
    LoginInfo loginInfo = LoginInfo(account: zhujiaoID.toString(),token: zhujiaoToken);
    FlutterNimsdk().login(loginInfo).then((result) {
      print(result);
    });
  }

  // 自动登陆
  void autoLogin() async {

      LoginInfo loginInfo = LoginInfo(account: zhujiaoID.toString(),token: zhujiaoToken);
      await FlutterNimsdk().autoLogin(loginInfo);
  }

  ///登出
  void logout() async {
    await FlutterNimsdk().logout();
  }

  /// 主叫发起通话请求
  void start() {
    NIMNetCallOption callOption = NIMNetCallOption(extendMessage: "extendMessage",apnsContent: "apnsContent",apnsSound: "apnsSound");
    FlutterNimsdk().start(beijiaoID.toString(), NIMNetCallMediaType.Video, callOption).then((result) {
        print(result);
        callID = jsonDecode(result)["callID"].toString();
    });
  }

  ///被叫响应通话请求
  void response(BuildContext context,bool accept) {
    NIMResponse nimResponse = NIMResponse(callID: callID,accept: accept);
    FlutterNimsdk().methodChannelPlugin().invokeMethod('response', {"response":nimResponse.toJson(),"mediaType": NIMNetCallMediaType.Video.index}).then((result) {
        
        Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPage()));
    });
  }

  /// 挂断
  void hangup() async {
    await FlutterNimsdk().hangup(callID);
  }

  /// 获取话单
  void records() {
    FlutterNimsdk().records().then((result){
      print(result);
    });
  }

  /// 清空本地话单
  void deleteRecords() async {
    await FlutterNimsdk().deleteAllRecords();
  }

  /// 动态设置摄像头开关
  void setCameraDisable() async {
    await FlutterNimsdk().setCameraDisable(false);
  }

  /// 动态切换摄像头
  void switchCamera() async {
    await FlutterNimsdk().switchCamera(NIMNetCallCamera.front);
  }

  /// 设置静音
  void setMute() async {
    await FlutterNimsdk().setMute(false);
  }

  /// 获取最近会话列表
  void getRecentList() async {

    FlutterNimsdk().mostRecentSessions().then((result) {
      print(result);
    });
  }

  /// 发送文本消息
  void sendText() async {

    NIMSession nimSession = NIMSession(sessionId: "0",sessionType: NIMSessionType.P2P.index);
    await FlutterNimsdk().sendMessageText("发送文本消息", nimSession);
  }

  ///发送已读消息回执
  void sendMessageReceipt() async {
    NIMMessage message = NIMMessage(from: "",messageId: "");
    FlutterNimsdk().sendMessageReceipt(message);
  }

  /// 设置全部已读
  void markAllMessagesRead() async {
    FlutterNimsdk().markAllMessagesRead();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Flutter Text"),
      ),
      body: new SafeArea(
          child: Center(
            child: SingleChildScrollView(
              controller: controller,
              child: Column(
                children: <Widget>[
                  Text(zhujiaoID.toString()),
                  RaisedButton(
                    onPressed: (){
                      this.login();
                      },
                    child: Text("登陆"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      this.autoLogin();
                    },
                    child: Text("自动登陆"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      this.logout();
                    },
                    child: Text("登出"),
                  ),
                  Container(
                    color: Colors.orange,
                    child: Column(
                      children: <Widget>[
                        Text("主叫"),
                        Row(
                          children: <Widget>[
                            RaisedButton(
                              onPressed: () {
                                this.start();
                              },
                              child: Text("发起通话"),
                            ),
                            RaisedButton(
                              onPressed: (){
                                this.hangup();
                              },
                              child: Text("挂断"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    color: Colors.red,
                    child: Column(
                      children: <Widget>[
                        Text("被叫"),
                        Row(
                          children: <Widget>[
                            RaisedButton(
                              onPressed: () {
                                this.response(context,true);
                              },
                              child: Text("接听"),
                            ),
                            RaisedButton(
                              onPressed: (){
                                this.response(context,false);
                              },
                              child: Text("拒绝接听"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  RaisedButton(
                    onPressed: (){
                      this.records();
                    },
                    child: Text("获取话单"),
                  ),
                  RaisedButton(
                    onPressed: (){
                      this.deleteRecords();
                    },
                    child: Text("清空话单"),
                  ),
                  RaisedButton(
                    onPressed: (){
                      this.setCameraDisable();
                    },
                    child: Text("动态设置摄像头"),
                  ),
                  RaisedButton(
                    onPressed: (){
                      this.switchCamera();
                    },
                    child: Text("动态切换摄像头"),
                  ),
                  RaisedButton(
                    onPressed: (){
                      this.setMute();
                    },
                    child: Text("设置静音"),
                  ),
                  RaisedButton(
                    onPressed: (){
                      this.getRecentList();
                    },
                    child: Text("获取最近消息列表"),
                  ),
                  RaisedButton(
                    onPressed: (){
                      this.sendText();
                    },
                    child: Text("发送文本消息"),
                  ),
                  RaisedButton(
                    onPressed: (){
                      this.sendMessageReceipt();
                    },
                    child: Text("发送消息回执"),
                  ),
                  RaisedButton(
                    onPressed: (){
                      this.markAllMessagesRead();
                    },
                    child: Text("设置全部已读"),
                  )
                ],
              ),
            ),
          ),
        ),
    );
  }
}

