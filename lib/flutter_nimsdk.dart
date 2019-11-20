import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'src/config.dart';
export 'src/config.dart';
import 'src/enum.dart';
export 'src/enum.dart';
import 'src/nim_session_model.dart';
export 'src/nim_session_model.dart';
import 'src/nim_message_model.dart';
export 'src/nim_message_model.dart';
import 'src/nim_history_message_search_option.dart';
export 'src/nim_history_message_search_option.dart';

class FlutterNimsdk {

  // static const MethodChannel _channel = const MethodChannel('flutter_nimsdk');

  // EventChannel eventChannel = EventChannel("flutter_nimsdk/Event/Channel", const StandardMethodCodec());
    // 初始化一个广播流从channel中接收数据，返回的Stream调用listen方法完成注册，需要在页面销毁时调用Stream的cancel方法取消监听
    StreamSubscription _streamSubscription;
    //创建 “ MethodChannel”这个名字要与原生创建时的传入值保持一致
    static const MethodChannel _methodChannelPlugin = const MethodChannel('flutter_nimsdk/Method/Channel');
  
  factory FlutterNimsdk() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel("flutter_nimsdk");
      final EventChannel eventChannel = const EventChannel('flutter_nimsdk/Event/Channel');
      _instance = FlutterNimsdk._private(methodChannel, eventChannel);
    }
    return _instance;
  }

  FlutterNimsdk._private(this._channel, this._eventChannel) {
    // _streamSubscription = _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  static FlutterNimsdk _instance;

  final MethodChannel _channel;
  final EventChannel _eventChannel;


  MethodChannel methodChannelPlugin() {
    return _methodChannelPlugin;
  }

  StreamSubscription streamSubscription() {
    return _streamSubscription;
  }

  EventChannel eventChannel() {
    return _eventChannel;
  }

  /// 初始化
  Future<void> initSDK(SDKOptions options) async {

    return await _channel.invokeMethod("initSDK", {"options": options.toJson()});
  }

  /// 移除代理
  Future<void> removeDelegate() async {
    return await _channel.invokeMethod("removeDelegate");
  }

  /// 登录
  Future<String> login(LoginInfo loginInfo) async {    
    return await  _channel.invokeMethod("login",loginInfo.toJson());
  }
  
  /// 自动登录
  Future<void> autoLogin(LoginInfo loginInfo) async {
    return await _channel.invokeMethod("autoLogin",loginInfo.toJson());
  }

  /// 登出
  Future<void> logout() async {
    return await _channel.invokeMethod("logout");
  }

  /// 主叫发起通话请求
  Future<String> start(String callees,NIMNetCallMediaType type,NIMNetCallOption option) async {
    return await _channel.invokeMethod("start",{"callees":callees, "type": type.index, "options": option.toJson()});
  }

  /// 挂断
  Future<void> hangup(String callID) async {
    return await _channel.invokeMethod("hangup",{"callID": callID.toString()});
  }

  /// 获取话单
  Future<String> records() async {
    return await _channel.invokeMethod("records");
  }

  /// 清空本地话单
  Future<void> deleteAllRecords() async {
    return await _channel.invokeMethod("deleteAllRecords");
  }

  /// 动态设置摄像头开关
  Future<void> setCameraDisable(bool disable) async {

    return await _channel.invokeMethod("setCameraDisable",{"disable": disable});
  }

   /// 动态设置摄像头开关
  Future<void> switchCamera(NIMNetCallCamera callCamera) async {

    String camera = "front";
    if (callCamera == NIMNetCallCamera.front) {
      camera = "front";
    } else {
      camera = "back";
    }
    return await _channel.invokeMethod("switchCamera",{"camera": camera});
  }

  /// 设置静音
  Future<void> setMute(bool mute) async {

    return await _channel.invokeMethod("setMute",{"mute": mute});
  }

  /// 设置网络通话扬声器模式
  Future<void> setSpeaker(bool useSpeaker) async {

    return await _channel.invokeMethod("setSpeaker",{"speaker": useSpeaker});
  }

  /// 设置视频通话对方的窗口的大小
  Future<void> setRemoteViewLayout(double originX,double originY, double width, double height) async {
    return await _channel.invokeMethod("setRemoteViewLayout",{"originX": originX,"originY":originY,"width":width,"height":height});
  }

  /// IM 
  /// 最近会话列表
  Future<String> mostRecentSessions() async {

    return await _channel.invokeMethod("mostRecentSessions");
  }
  /// 获取所有最近会话
  Future<String> allRecentSessions() async {

    return await _channel.invokeMethod("allRecentSessions");
  }

  /// 删除某个最近会话
  Future<void> deleteRecentSession(String sessionID) async {
    return await _channel.invokeMethod("deleteRecentSession",{"sessionID": sessionID});
  }

  /// 删除所有最近会话
  Future<void> deleteAllRecentSession() async {
    return await _channel.invokeMethod("deleteAllRecentSession");
  }

  /// 获取所有未读数
  Future<String> allUnreadCount() async {
    return await _channel.invokeMethod("allUnreadCount");
  }

  ///发送文本消息
  Future<void> sendMessageText(String text,NIMSession nimSession) async {
    return await _channel.invokeMethod("sendTextMessage",{"message":text,"nimSession":nimSession.toJson()});
  }

  ///发送提示消息
  Future<void> sendMessageTip(String text,NIMSession nimSession) async {
    return await _channel.invokeMethod("sendTipMessage",{"message":text,"nimSession":nimSession.toJson()});
  }

  ///发送图片消息
  Future<void> sendMessageImage(String imagePath,NIMSession nimSession) async {
    return await _channel.invokeMethod("sendImageMessage",{"imagePath":imagePath,"nimSession":nimSession.toJson()});
  }

  ///发送视频消息
  Future<void> sendMessageVideo(String videoPath,NIMSession nimSession) async {
    return await _channel.invokeMethod("sendVideoMessage",{"videoPath":videoPath,"nimSession":nimSession.toJson()});
  }

  ///发送音频消息
  Future<void> sendMessageAudio(String audioPath,NIMSession nimSession) async {
    return await _channel.invokeMethod("sendAudioMessage",{"audioPath":audioPath,"nimSession":nimSession.toJson()});
  }

  ///发送文件消息
  Future<void> sendMessageFile(String filePath,NIMSession nimSession) async {
    return await _channel.invokeMethod("sendFileMessage",{"filePath":filePath,"nimSession":nimSession.toJson()});
  }

  ///发送位置消息
  Future<void> sendMessageLocation(NIMSession nimSession, NIMLocationObject locationObject) async {
    return await _channel.invokeMethod("sendLocationMessage",{"nimSession":nimSession.toJson(),"locationObject": locationObject.toJson()});
  }

  /// 会话内发送自定义消息
  Future<void> sendMessageCustom(NIMSession nimSession,Map customObject, {String apnsContent}) async {
    final String customEncodeString = json.encode(customObject);

    Map<String, dynamic> map = {
      "nimSession": nimSession.toJson(),
      "customEncodeString": customEncodeString,
      "apnsContent": apnsContent ?? "[自定义消息]",
    };

    return await _channel.invokeMethod("sendCustomMessage", map);
  }

  // 开始录音
  Future<void> onStartRecording(String sessionId) async {
    return await _channel.invokeMethod("onStartRecording",{"sessionId": sessionId});
  }

  // 结束录音
  Future<void> onStopRecording(String sessionId) async {
    return await _channel.invokeMethod("onStopRecording",{"sessionId": sessionId});
  }

  // 取消录音
  Future<void> onCancelRecording(String sessionId) async {
    return await _channel.invokeMethod("onCancelRecording",{"sessionId": sessionId});
  }

  /// 发送消息已读回执
  Future<void> sendMessageReceipt(NIMMessage message) async {
    return await _channel.invokeMethod("sendMessageReceipt",message.toJson());
  }

  /// 设置所有会话消息为已读
  Future<void> markAllMessagesRead() async {
    return await _channel.invokeMethod("markAllMessagesRead");
  }

  /// 删除某条消息
  Future<void> deleteMessage(NIMMessage message) async {
    return await _channel.invokeMethod("deleteMessage",message.toJson());
  }

  /// 删除某个会话的所有消息
  Future<void> deleteAllmessagesInSession(NIMSession session, NIMDeleteMessagesOption option) async {
    return await _channel.invokeMethod("deleteAllmessagesInSession",{"session": session.toJson(),"option": option.toJson()});
  }

  /// 删除所有会话消息
  Future<void> deleteAllMessages(NIMDeleteMessagesOption option) async {
    return await _channel.invokeMethod("deleteAllMessages",option.toJson());
  }

  ///从服务器上获取一个会话里某条消息之前的若干条的消息
  Future<String> fetchMessageHistory(NIMSession session,NIMHistoryMessageSearchOption option) async {
    return await _channel.invokeMethod("fetchMessageHistory",{"session":session.toJson(),"option": option.toJson()});
  }



  /// 美颜
  /// 初始化
  Future<void> initFaceunity() async {
    return await _channel.invokeMethod("initFaceunity");
  }

  /// 设置滤镜
  Future<void> setFilterName(FilterNameType filterNameType) async {
    return await _channel.invokeMethod("filter_name",{"filter_name": filterNameType.index});
  }

  /// 设置滤镜的 level
  Future<void> setFilterLevel(double filterLevel) async {
    return await _channel.invokeMethod("filter_level",{"filter_level": filterLevel});
  }

  /// 美白level
  Future<void> setColorLevel(double colorLevel) async {
    return await _channel.invokeMethod("color_level",{"color_level": colorLevel});
  }

  /// 红润level
  Future<void> setRedLevel(double redLevel) async {
    return await _channel.invokeMethod("red_level",{"red_level": redLevel});
  }

  /// 指定磨皮类型,取值为1,2,3;  磨皮程度,推荐取值范围为0.0~6.0
  Future<void> setBlur(int blurType, double blurLevel) async {
    return await _channel.invokeMethod("blur",{"blur_type": blurType, "blur_level": blurLevel});
  }

  /// 指定是否开启皮肤检测,该参数的推荐取值为0-1，0为无效果，1为开启皮肤检测，
  Future<void> setSkinDetect(bool skinDetect) async {
    return await _channel.invokeMethod("skin_detect",{"skin_detect": skinDetect});
  }

  /// 指定开启皮肤检测后，非皮肤区域减轻磨皮导致模糊的程度。该参数范围是[0.0,1.0]
  Future<void> setNonshinBlurScale(double nonshinBlurScale) async {
    return await _channel.invokeMethod("nonshin_blur_scale",{"nonshin_blur_scale": nonshinBlurScale});
  }

  /// 指定是否开启朦胧美肤功能。大于1开启朦胧美肤功能。
  Future<void> setHeavyBlur(double heavyBlur) async {
    return await _channel.invokeMethod("heavy_blur",{"heavy_blur": heavyBlur});
  }

  /// 指定磨皮结果和原图融合率。该参数的推荐取值范围为0-1。
  Future<void> setBlurBlendRatio(double blurBlendRatio) async {
    return await _channel.invokeMethod("blur_blend_ratio",{"blur_blend_ratio": blurBlendRatio});
  }

  /// 亮眼
  Future<void> setEyeBright(double eyeBright) async {
    return await _channel.invokeMethod("eye_bright",{"eye_bright": eyeBright});
  }

  /// 美牙
  Future<void> setToothWhiten(double toothWhiten) async {
    return await _channel.invokeMethod("tooth_whiten",{"tooth_whiten": toothWhiten});
  }

  /// 美型支持四种基本美型：女神、网红、自然、默认   一种高级美型：自定义。
  Future<void> setFaceShap(int faceShap) async {
    return await _channel.invokeMethod("face_shape",{"face_shape": faceShap});
  }

  /// 用以控制变化到指定基础脸型的程度。
  Future<void> setFaceShapLevel(double faceShapLevel) async {
    return await _channel.invokeMethod("face_shape_level",{"face_shape_level": faceShapLevel});
  }

  /// 用以控制眼睛大小。此参数受参数 face_shape_level 影响。
  Future<void> setEyeEnlarging(double eyeEnlarging) async {
    return await _channel.invokeMethod("eye_enlarging",{"eye_enlarging": eyeEnlarging});
  }

  /// 用以控制脸大小。此参数受参数 face_shape_level 影响。
  Future<void> setCheekThinning(double cheekThinning) async {
    return await _channel.invokeMethod("cheek_thinning",{"cheek_thinning": cheekThinning});
  }

  /// 额头调整。
  Future<void> setIntensityForehead(double intensityForehead) async {
    return await _channel.invokeMethod("intensity_forehead",{"intensity_forehead": intensityForehead});
  }

  /// 下巴调整。
  Future<void> setIntensityChin(double intensityChin) async {
    return await _channel.invokeMethod("intensity_chin",{"intensity_chin": intensityChin});
  }

  /// 鼻子调整。
  Future<void> setIntensityNose(double intensityNose) async {
    return await _channel.invokeMethod("intensity_nose",{"intensity_nose": intensityNose});
  }

  /// 嘴型
  Future<void> setIntensityMouth(double intensityMouth) async {
    return await _channel.invokeMethod("intensity_mouth",{"intensity_mouth": intensityMouth});
  }

  /// 销毁道具
  Future<void> destoryItems() async {
    return await _channel.invokeMethod("destoryItems");
  }
}
