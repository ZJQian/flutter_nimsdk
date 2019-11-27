import 'package:flutter/material.dart';
import 'dart:ui';

class VideoPage extends StatefulWidget {
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
              viewType: "LocalDisplayView",
            ),
          ),
          Container(
            width: 100,
            height: 150,
            child: UiKitView(
              viewType: "RemoteDisplayView",
            ),
          ),
          Positioned(
            right: 50,
            top: 50,
            child: Container(
              color: Colors.yellow,
              child: RaisedButton(
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