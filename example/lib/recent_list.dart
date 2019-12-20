import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_nimsdk/flutter_nimsdk.dart';
import 'dart:convert';

class RecentListPage extends StatefulWidget {
  @override
  _RecentListPageState createState() => _RecentListPageState();
}

class _RecentListPageState extends State<RecentListPage> {
  List items = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
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

  Widget backItem(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text("返回"),
    );
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
          Text(item["nickName"])
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("最近会话列表"),
        leading: backItem(context),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return itemBuilder(items[index], index);
        },
      ),
    );
  }
}
