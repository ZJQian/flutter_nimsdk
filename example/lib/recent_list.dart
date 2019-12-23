import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_nimsdk/flutter_nimsdk.dart';
import 'dart:convert';
import 'dart:async';

class RecentListPage extends StatefulWidget {
  @override
  _RecentListPageState createState() => _RecentListPageState();
}

class _RecentListPageState extends State<RecentListPage> {
  StreamSubscription _streamSubscription;
  List items = [];

  //  28       f51d1656315ac021d623f556dd493985
  //  27       ae93a01e9a3f087e1e85a7de731955dc
  //  184600   971ddcaa4573470245d36eecc9d78201

  int zhujiaoID = 184600;
  String zhujiaoToken = "971ddcaa4573470245d36eecc9d78201";
  int beijiaoID = 27;

  // int zhujiaoID = 28;
  // String zhujiaoToken = "f51d1656315ac021d623f556dd493985";
  // int beijiaoID = 184600;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    registerNIMSDK("8c2ed2ed508d1dacea2f0007852605ae");
    _streamSubscription = FlutterNimsdk()
        .eventChannel()
        .receiveBroadcastStream()
        .listen(_onEvent, onError: _onError);
    login();
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
    print(value);

    if (delegateType == 0) {
      int step = result["step"];
      if (step == 8) {
        getData();
      }
    } else if (delegateType == 1) {
    } else if (delegateType == 2) {
    } else if (delegateType == 3) {
    } else if (delegateType == 4) {}
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

  void login() {
    //  28   f51d1656315ac021d623f556dd493985
    //  27   ae93a01e9a3f087e1e85a7de731955dc
    LoginInfo loginInfo =
        LoginInfo(account: zhujiaoID.toString(), token: zhujiaoToken);
    FlutterNimsdk().login(loginInfo).then((result) {
      print(result);
    });
  }

  void getData() async {
    FlutterNimsdk().mostRecentSessions().then((result) {
      print(result);
      Map map = json.decode(result);
      List sessions = map["mostRecentSessions"];
      setState(() {
        items = sessions;
      });
    });
  }

  Widget itemBuilder(item, index) {
    String thumbAvatarUrl = item["thumbAvatarUrl"];
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.black, width: 0.5))),
      child: Row(
        children: <Widget>[
          thumbAvatarUrl == null
              ? Image.network(
                  "http://gss0.baidu.com/7Po3dSag_xI4khGko9WTAnF6hhy/zhidao/pic/item/2e2eb9389b504fc26a5a3b12eddde71190ef6da4.jpg",
                  width: 50,
                  height: 50,
                )
              : Image.network(
                  thumbAvatarUrl,
                  width: 50,
                  height: 50,
                ),
          Container(
            padding: EdgeInsets.only(left: 10),
            child: Column(
              children: <Widget>[Text(item["nickName"])],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("最近会话列表")),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return itemBuilder(items[index], index);
          },
        ),
      ),
    );
  }
}
