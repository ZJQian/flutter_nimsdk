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
      body: Container(
        width: window.physicalSize.width,
        height: window.physicalSize.height,
        child: UiKitView(
          viewType: "LocalDisplayView",
        ),
      ),
    );
  }
}