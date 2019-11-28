import 'package:flutter/material.dart';
import 'dart:ui';

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
            child: Container(
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
          )
        ],
      ),
    );
  }
}