import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_nimsdk/flutter_nimsdk.dart';

class VideoPage extends StatefulWidget {


  final String timeStamp;
  VideoPage({Key key, @required this.timeStamp}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
          Positioned(
            right: 50,
            top: 50,
            child: Column(
              children: <Widget>[
                Container(
                  width: 60,
                  height: 30,
                  child: RaisedButton(
                    color: Colors.yellow,
                    onPressed: () {
                      Navigator.pop(context,"挂断");
                    },
                    child: Text("挂断"),
                  ),
                ),
                RaisedButton(
                  color: Colors.yellow,
                  onPressed: () {
                    FlutterNimsdk().setCameraDisable(true);
                  },
                  child: Text("摄像头关"),
                ),
                RaisedButton(
                  color: Colors.yellow,
                  onPressed: () {
                    FlutterNimsdk().setCameraDisable(false);
                  },
                  child: Text("摄像头开"),
                ),
                RaisedButton(
                  color: Colors.yellow,
                  onPressed: () {
                    FlutterNimsdk().switchCamera(NIMNetCallCamera.back);
                  },
                  child: Text("后摄"),
                ),
                RaisedButton(
                  color: Colors.yellow,
                  onPressed: () {
                    FlutterNimsdk().switchCamera(NIMNetCallCamera.front);
                  },
                  child: Text("前摄"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}