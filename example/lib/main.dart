import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_nimsdk/flutter_nimsdk.dart';
import 'dart:convert';
import 'video.dart';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'recent_list.dart';
import 'package:fluttertoast/fluttertoast.dart';

// void main() => runApp(RecentListPage());
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: HomeWidget()),
    );
  }
}

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  StreamSubscription _streamSubscription;
  ScrollController controller = ScrollController();

  //  28       f51d1656315ac021d623f556dd493985
  //  27       ae93a01e9a3f087e1e85a7de731955dc
  //  184600   971ddcaa4573470245d36eecc9d78201

  int zhujiaoID = 28;
  String zhujiaoToken = "f51d1656315ac021d623f556dd493985";
  int beijiaoID = 27;

  // int zhujiaoID = 27;
  // String zhujiaoToken = "ae93a01e9a3f087e1e85a7de731955dc";
  // int beijiaoID = 28;

  String callID = "";
  bool isConnectSuccess = false;
  bool showCallPage = false;
  String currentTimeStamp = "";
  String beijiaoTimeStamp = "";

  @override
  void initState() {
    super.initState();
    registerNIMSDK("8c2ed2ed508d1dacea2f0007852605ae");
    _streamSubscription = FlutterNimsdk()
        .eventChannel()
        .receiveBroadcastStream()
        .listen(_onEvent, onError: _onError);
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
    Map<String, dynamic> result = json.decode(value);
    int delegateType = result["delegateType"];
    bool accepted = false;
    print(value);

    if (delegateType == 1) {
      setState(() {
        callID = result["callID"];
        showCallPage = true;
        beijiaoTimeStamp = result["currentTimeStamp"];
      });

      print("******************************************");
      print("beijiaoTimeStamp是:   " + beijiaoTimeStamp);
      print("******************************************");
    } else if (delegateType == 2) {
      accepted = result["accepted"];
    } else if (delegateType == 3) {
      setState(() {
        isConnectSuccess = true;
      });

      String time = (currentTimeStamp == null || currentTimeStamp.length == 0)
          ? beijiaoTimeStamp
          : currentTimeStamp;
      var route =
          MaterialPageRoute(builder: (context) => VideoPage(timeStamp: time));
      Navigator.push(context, route).then((res) {
        this.hangup();
      });
    } else if (delegateType == 4) {
      if (Navigator.of(context).canPop()) {
        this.hangup();
        Navigator.of(context).pop();
      }
    }
  }

  // 错误处理
  void _onError(dynamic) {
    print("on error");
  }

  static String currentTimeMillis() {
    return new DateTime.now().millisecondsSinceEpoch.toString();
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
    LoginInfo loginInfo =
        LoginInfo(account: zhujiaoID.toString(), token: zhujiaoToken);
    FlutterNimsdk().login(loginInfo).then((result) {
      print(result);
    });
  }

  // 自动登陆
  void autoLogin() async {
    LoginInfo loginInfo =
        LoginInfo(account: zhujiaoID.toString(), token: zhujiaoToken);
    await FlutterNimsdk().autoLogin(loginInfo);
  }

  ///登出
  void logout() async {
    await FlutterNimsdk().logout();
  }

  /// 主叫发起通话请求
  void start() {
    String time = currentTimeMillis();
    String extendMessage =
        '{"currentTimeStamp":"${time}","type":"1","price":"15"}';
    NIMNetCallOption callOption = NIMNetCallOption(
        extendMessage: extendMessage,
        apnsContent: "apnsContent",
        apnsSound: "apnsSound");

    FlutterNimsdk()
        .start(
            beijiaoID.toString(), NIMNetCallMediaType.Video, callOption, time)
        .then((result) {
      print(result);
      setState(() {
        callID = jsonDecode(result)["callID"].toString();
        currentTimeStamp = time;
      });
    });
  }

  ///被叫响应通话请求
  void response(BuildContext context, bool accept) {
    if (callID != null) {
      NIMResponse nimResponse = NIMResponse(callID: callID, accept: accept);

      FlutterNimsdk().methodChannelPlugin().invokeMethod('response', {
        "response": nimResponse.toJson(),
        "mediaType": NIMNetCallMediaType.Video.index
      }).then((result) {
        setState(() {
          showCallPage = false;
        });
        print("this.beijiaoTimeStamp 是:    " + this.beijiaoTimeStamp);
      });
    } else {
      Fluttertoast.showToast(
          msg: "callID为空，请检查参数是否完整",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  /// 挂断
  void hangup() async {
    await FlutterNimsdk().hangup(zhujiaoToken);
  }

  /// 获取话单
  void records() {
    FlutterNimsdk().records().then((result) {
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
    // FlutterNimsdk().mostRecentSessions().then((result) {
    //   print(result);
    // });

    var route = MaterialPageRoute(builder: (context) => RecentListPage());
    Navigator.push(context, route);
  }

  /// 发送文本消息
  void sendText() async {
    NIMSession nimSession = NIMSession(
        sessionId: beijiaoID.toString(), sessionType: NIMSessionType.P2P.index);
    await FlutterNimsdk().sendMessageText("发送文本消息", nimSession);
  }

  /// 发送image消息
  void sendImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    NIMSession nimSession = NIMSession(
        sessionId: beijiaoID.toString(), sessionType: NIMSessionType.P2P.index);
    FlutterNimsdk().sendMessageImage(image.path, nimSession);
  }

  /// 发送阅后即焚消息
  void sendSnapChat() async {
    NIMSession session = NIMSession(
        sessionId: beijiaoID.toString(), sessionType: NIMSessionType.P2P.index);
    // Map map = {
    //   "type": "13",
    //   "data": {
    //     "displayName": "10",
    //     "md5": "30f02608aa27b23b6fc7e254e189daaa",
    //     "size": "1642",
    //     "duration": "5",
    //     "width": "375",
    //     "height": "500",
    //     "extension": "extension",
    //     "path": "videoPath",
    //     "url":
    //         "http://b-ssl.duitang.com/uploads/item/201607/22/20160722180244_4QYLN.jpeg"
    //   }
    // };
    // Map map = {
    //   "type": "2",
    //   "data": {
    //     "displayName": "8",
    //     "md5": "30f02608aa27b23b6fc7e254e189daaa",
    //     "size": "1642",
    //     "path": "videoPath",
    //     "url":
    //         "http://b-ssl.duitang.com/uploads/item/201607/22/20160722180244_4QYLN.jpeg"
    //   }
    // };
    Map map = {
      "type": "7",
      "data": {
        "gift_id": "10",
        "gift_name": "小黄瓜",
        "gift_img":
            "http://downhdlogo.yy.com/hdlogo/640640/610/610/71/0067714824/u67714824VYCjn-CF7.png?20170426145912",
        "price": "10"
      }
    };
    await FlutterNimsdk()
        .sendMessageCustom(session, map, apnsContent: "123456");
  }

  ///发送视频消息
  void sendVideo() async {
    await showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
          title: new Text('选择'),
          children: <Widget>[
            new SimpleDialogOption(
              child: new Text('相机拍摄'),
              onPressed: () {
                selectedVideo(0);
                Navigator.of(context).pop();
              },
            ),
            new SimpleDialogOption(
              child: new Text('从相册选取'),
              onPressed: () {
                selectedVideo(1);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((val) {
      print(val);
    });
  }

  void selectedVideo(int type) async {
    var video = await ImagePicker.pickVideo(
        source: type == 0 ? ImageSource.camera : ImageSource.gallery);
    NIMSession nimSession = NIMSession(
        sessionId: beijiaoID.toString(), sessionType: NIMSessionType.P2P.index);
    FlutterNimsdk().sendMessageVideo(video.path, nimSession);
  }

  void uploadVideo() async {
    var video = await ImagePicker.pickVideo(source: ImageSource.gallery);
    print(video.length());
    FlutterNimsdk().uploadVideo(video.path).then((result) {
      print(result);
    });
  }

  ///发送已读消息回执
  void sendMessageReceipt() async {
    NIMMessage message = NIMMessage(from: "", messageId: "");
    FlutterNimsdk().sendMessageReceipt(message);
  }

  /// 设置全部已读
  void markAllMessagesRead() async {
    FlutterNimsdk().markAllMessagesRead();
  }

  void fetchMessageHistory() async {
    NIMSession session = NIMSession(sessionId: "27", sessionType: 0);
    NIMHistoryMessageSearchOption option =
        NIMHistoryMessageSearchOption(startTime: 0, limit: 0, endTime: 0);
    FlutterNimsdk().fetchMessageHistory(session, option);
  }

  void messagesInSessionMessage() async {
    NIMSession session = NIMSession(
        sessionId: beijiaoID.toString(), sessionType: NIMSessionType.P2P.index);
    NIMMessage message = NIMMessage();
    FlutterNimsdk()
        .messagesInSessionMessage(session, message, 10)
        .then((result) {
      print(result);
    });
  }

  void deleteRecentSession() async {
    FlutterNimsdk().deleteRecentSession(beijiaoID.toString());
  }

  void sendCustomMessage() async {
    NIMSession session = NIMSession(
        sessionId: beijiaoID.toString(), sessionType: NIMSessionType.P2P.index);
    await FlutterNimsdk().sendMessageCustom(session, {"custom": "自定义消息"});
  }

  void sendViewed() async {
    NIMSession session = NIMSession(
        sessionId: beijiaoID.toString(), sessionType: NIMSessionType.P2P.index);
    NIMMessageObject messageObject = NIMMessageObject(
        url:
            "https://vdse.bdstatic.com//d719a00ef3e9242e4f15d09eb3a56885?authorization=bce-auth-v1%2F40f207e648424f47b2e3dfbb1014b1a5%2F2017-05-11T09%3A02%3A31Z%2F-1%2F%2Fa995633866dcbad98a024d34995d8307e8bd7db308387283e725884842c7561e");
    NIMMessage message = NIMMessage(
        messageId: "", messageType: 100, messageObject: messageObject);
    FlutterNimsdk().sendViewed(session, message, "21").then((result) {
      print(result);
    });
  }

  Widget handleCall(BuildContext context) {
    if (showCallPage) {
      return Opacity(
        opacity: 1,
        child: Container(
          width: window.physicalSize.width,
          height: window.physicalSize.height,
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                child: RaisedButton(
                  color: Colors.blue,
                  onPressed: () {
                    this.response(context, true);
                  },
                  child: Text("接听"),
                ),
              ),
              Container(
                width: 100,
                height: 100,
                child: RaisedButton(
                  color: Colors.red,
                  onPressed: () {
                    this.response(context, false);
                  },
                  child: Text("挂断"),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Flutter Plugin"),
        ),
        body: Stack(
          children: <Widget>[
            new SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    children: <Widget>[
                      Text(zhujiaoID.toString()),
                      RaisedButton(
                        onPressed: () {
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
                                  onPressed: () {
                                    this.hangup();
                                  },
                                  child: Text("挂断"),
                                ),
                              ],
                            ),
                            Text("${this.currentTimeStamp}")
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
                                    this.response(context, true);
                                  },
                                  child: Text("接听"),
                                ),
                                RaisedButton(
                                  onPressed: () {
                                    this.response(context, false);
                                  },
                                  child: Text("拒绝接听"),
                                ),
                              ],
                            ),
                            Text("${this.beijiaoTimeStamp}")
                          ],
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.records();
                        },
                        child: Text("获取话单"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.deleteRecords();
                        },
                        child: Text("清空话单"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.setCameraDisable();
                        },
                        child: Text("动态设置摄像头"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.switchCamera();
                        },
                        child: Text("动态切换摄像头"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.setMute();
                        },
                        child: Text("设置静音"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.getRecentList();
                        },
                        child: Text("获取最近消息列表"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.sendText();
                        },
                        child: Text("发送文本消息"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.sendImage();
                        },
                        child: Text("发送图片消息"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.sendVideo();
                        },
                        child: Text("发送视频消息"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.sendMessageReceipt();
                        },
                        child: Text("发送消息回执"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.markAllMessagesRead();
                        },
                        child: Text("设置全部已读"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.messagesInSessionMessage();
                        },
                        child: Text("获取消息记���"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.deleteRecentSession();
                        },
                        child: Text("删除最近通话"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.sendCustomMessage();
                        },
                        child: Text("发送自定义消息"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.sendSnapChat();
                        },
                        child: Text("发送阅后即焚"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.uploadVideo();
                        },
                        child: Text("上传视频"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          this.sendViewed();
                        },
                        child: Text("视频自定义通知"),
                      )
                    ],
                  ),
                ),
              ),
            ),
            handleCall(context)
          ],
        ));
  }
}
