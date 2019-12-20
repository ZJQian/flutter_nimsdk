import 'package:json_annotation/json_annotation.dart';
part 'config.g.dart';

///可自定义的SDK选项设置
@JsonSerializable()
class SDKOptions {
  ///设置云信SDK的appKey。appKey还可以通过在AndroidManifest文件中，通过meta-data的方式设置。 如果两处都设置了，取此处的值。
  final String appKey;

  ///是否检查并使用Asset目录下的私有化服务器配置文件server.conf(固定命名） 默认是false 一般只有私有化项目中，在私有化测试期间需要开启此选项，并将配置文件放在Assets/server.conf 注意：如果在SDKOptions.serverConfig已经配置了，那么该本地配置文件将失效！
  final bool useAssetServerAddressConfig;

  ///状态提醒设置。
  ///默认为null，SDK不提供状态栏提醒功能，由客户APP自行实现
  final StatusBarNotificationConfig statusBarNotificationConfig;

  ///通知栏显示用户昵称和头像
  final UserInfoProvider userInfoProvider;

  ///通知栏提醒文案定制
  final MessageNotifierCustomization messageNotifierCustomization;

  ///外置存储根目录,用于存放多媒体消息文件。
  ///若不设置或设置的路径不可用，将使用"external storage root/packageName/nim/"作为根目录 注意，4.4.0 之后版本，如果开发者配置在 Context#getExternalCacheDir 及 Context.getExternalFilesDir 等应用扩展存储缓存目录下，SDK 内部将不再检查写权限。但这里的文件会随着App卸载而被删除，也可以由用户手动在设置界面里面清除。
  final String sdkStorageRootPath;

  ///是否需要SDK自动预加载多媒体消息的附件。
  ///如果打开，SDK收到多媒体消息后，图片和视频会自动下载缩略图，音频会自动下载文件。
  ///如果关闭，第三方APP可以只有决定要不要下载以及何时下载附件内容，典型时机为消息列表第一次滑动到 这条消息时，才触发下载，以节省用户流量。
  ///该开关默认打开。
  final bool preloadAttach;

  ///消息缩略图的尺寸。
  ///该值为最长边的大小。下载的缩略图最长边不会超过该值。
  final int thumbnailSize;

  ///是否开启会话已读多端同步，支持多端同步会话未读数
  final bool sessionReadAck;

  ///是否提高SDK进程优先级（默认提高，可以降低SDK核心进程被系统回收的概率）；如果部分机型有意外的情况，可以根据机型决定是否开启。 4.6.0版本起，弱 IM 模式下，强制不提高SDK进程优先级
  final bool improveSDKProcessPriority;

  ///配置专属服务器的地址
  final ServerAddresses serverConfig;

  ///预加载服务，默认true，不建议设置为false，预加载连接可以优化登陆流程，提升用户体验
  final bool preLoadServers;

  ///群通知消息是否计入未读数，默认不计入未读
  final bool teamNotificationMessageMarkUnread;

  ///使用性能更好的SDK日志模式。默认使用普通日志模式。
  final bool useXLog;

  ///开启对动图缩略图的支持
  final bool animatedImageThumbnailEnabled;

  ///是否检查 Manifest 配置 最好在调试阶段打开，调试通过之后请关掉
  final bool checkManifestConfig;

  ///第三方推送配置
  final MixPushConfig mixPushConfig;

  ///是否使用随机退避重连策略，默认true，强烈建议打开。如需关闭，请咨询云信技术支持。
  final bool enableBackOffReconnectStrategy;

  ///是否启用网络连接优化策略，默认开启。
  final bool enableLBSOptimize;

  ///是否启用群消息已读功能，默认关闭
  final bool enableTeamMsgAck;

  ///是否需要将被撤回的消息计入未读数 默认是false，即撤回消息不影响未读数，客户端通常直接写入一条Tip消息，用于提醒"对方撤回了一条消息"，该消息也不计入未读数，不影响当前会话的未读数。 如果设置为true，撤回消息后未读数将减1.
  final bool shouldConsiderRevokedMessageUnreadCount;

  ///nos token 场景配置
  final NosTokenSceneConfig mNosTokenSceneConfig;

  ///登录时的自定义字段 ， 登陆成功后会同步给其他端 ，获取可参考 AuthServiceObserver#observeOtherClients()
  final String loginCustomTag;

  ///禁止后台进程唤醒ui进程
  final bool disableAwake;

  SDKOptions(
      {this.appKey,
      this.statusBarNotificationConfig,
      this.userInfoProvider,
      this.messageNotifierCustomization,
      this.sdkStorageRootPath,
      this.serverConfig,
      this.mixPushConfig,
      this.shouldConsiderRevokedMessageUnreadCount,
      this.mNosTokenSceneConfig,
      this.loginCustomTag,
      this.disableAwake = false,
      this.enableTeamMsgAck = false,
      this.enableLBSOptimize = true,
      this.enableBackOffReconnectStrategy = true,
      this.checkManifestConfig = false,
      this.animatedImageThumbnailEnabled = false,
      this.useXLog = false,
      this.teamNotificationMessageMarkUnread = false,
      this.preLoadServers = true,
      this.improveSDKProcessPriority = true,
      this.sessionReadAck = false,
      this.thumbnailSize = 350,
      this.preloadAttach = true,
      this.useAssetServerAddressConfig = false});

  //不同的类使用不同的mixin即可
  factory SDKOptions.fromJson(Map<String, dynamic> json) =>
      _$SDKOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$SDKOptionsToJson(this);
}

///SDK提供状态栏提醒的配置
@JsonSerializable()
class StatusBarNotificationConfig {
  ///状态栏提醒的小图标的资源ID。
  ///如果不提供，使用app的icon
  final int notificationSmallIconId;

  ///是否需要响铃提醒。
  ///默认为true
  final bool ring;

  ///响铃提醒的声音资源，如果不提供，使用系统默认提示音。
  final String notificationSound;

  ///是否需要振动提醒。
  ///默认为true
  final bool vibrate;

  ///呼吸灯的颜色 The color of the led.
  final int ledARGB;

  ///呼吸灯亮时的持续时间（毫秒） The number of milliseconds for the LED to be on while it's flashing.
  final int ledOnMs;

  ///呼吸灯熄灭时的持续时间（毫秒） The number of milliseconds for the LED to be off while it's flashing.
  final int ledOffMs;

  ///不显示消息详情开关, 同时也不再显示消息发送者昵称
  ///默认为false
  final bool hideContent;

  ///免打扰设置开关。默认为关闭。
  final bool downTimeToggle;

  ///免打扰的开始时间, 格式为HH:mm(24小时制)。
  final String downTimeBegin;

  ///免打扰的结束时间, 格式为HH:mm(24小时制)。
  ///如果结束时间小于开始时间，免打扰时间为开始时间-24:00-结束时间。
  final String downTimeEnd;
  final bool downTimeEnableNotification;

  ///通知栏提醒的响应intent的activity类型。
  ///可以为null。如果未提供，将使用包的launcher的入口intent的activity。
  final String notificationEntrance;

  ///通知栏提醒的标题是否只显示应用名。默认是 false，当有一个会话发来消息时，显示会话名；当有多个会话发来时，显示应用名。
  ///修改为true，那么无论一个还是多个会话发来消息，标题均显示应用名。 应用名称请在AndroidManifest的application节点下设置android:label。
  final bool titleOnlyShowAppName;

  ///消息通知栏展示样式是否折叠。默认是true，这样云信消息端内消息提醒最多之占一栏。 由于端外推送消息为展开模式，可以设置为false达到端内、端外表现一致。
  final bool notificationFolded;

  ///消息通知栏颜色，将应用到 NotificationCompat.Builder 的 setColor 方法 对Android 5.0 以后机型会影响到smallIcon
  final int notificationColor;

  ///是否APP图标显示未读数(红点) 仅针对Android 8.0+有效
  final bool showBadge;

  ///如果群名称为null 或者空串，则使用customTitleWhenTeamNameEmpty 作为通知栏title
  final String customTitleWhenTeamNameEmpty;

  StatusBarNotificationConfig({
    this.notificationSmallIconId,
    this.notificationSound,
    this.downTimeBegin,
    this.downTimeEnd,
    this.notificationEntrance,
    this.notificationColor,
    this.customTitleWhenTeamNameEmpty,
    this.vibrate = true,
    this.ring = true,
    this.ledOnMs = -1,
    this.ledARGB = -1,
    this.showBadge = true,
    this.notificationFolded = true,
    this.titleOnlyShowAppName = false,
    this.downTimeEnableNotification = true,
    this.downTimeToggle = false,
    this.hideContent = false,
    this.ledOffMs = -1,
  });

  //不同的类使用不同的mixin即可
  factory StatusBarNotificationConfig.fromJson(Map<String, dynamic> json) =>
      _$StatusBarNotificationConfigFromJson(json);

  Map<String, dynamic> toJson() => _$StatusBarNotificationConfigToJson(this);
}

@JsonSerializable()
class UserInfoProvider {
  UserInfoProvider();

  //不同的类使用不同的mixin即可
  factory UserInfoProvider.fromJson(Map<String, dynamic> json) =>
      _$UserInfoProviderFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoProviderToJson(this);
}

@JsonSerializable()
class MessageNotifierCustomization {
  MessageNotifierCustomization();

  //不同的类使用不同的mixin即可
  factory MessageNotifierCustomization.fromJson(Map<String, dynamic> json) =>
      _$MessageNotifierCustomizationFromJson(json);

  Map<String, dynamic> toJson() => _$MessageNotifierCustomizationToJson(this);
}

@JsonSerializable()
class ServerAddresses {
  ServerAddresses(
      {this.publicKey,
      this.lbs,
      this.defaultLink,
      this.nosUploadLbs,
      this.nosUploadDefaultLink,
      this.nosUpload,
      this.nosDownloadUrlFormat,
      this.nosDownload,
      this.nosAccess,
      this.ntServerAddress,
      this.bdServerAddress,
      this.test = false,
      this.nosSupportHttps = true});

  final String publicKey;
  final int publicKeyVersion = 0;
  final String lbs;
  final String defaultLink;
  final String nosUploadLbs;
  final String nosUploadDefaultLink;
  final String nosUpload;
  final bool nosSupportHttps;
  final String nosDownloadUrlFormat;
  final String nosDownload;
  final String nosAccess;
  final String ntServerAddress;
  final String bdServerAddress;
  final bool test;

  //不同的类使用不同的mixin即可
  factory ServerAddresses.fromJson(Map<String, dynamic> json) =>
      _$ServerAddressesFromJson(json);

  Map<String, dynamic> toJson() => _$ServerAddressesToJson(this);
}

@JsonSerializable()
class MixPushConfig {
  MixPushConfig({
    this.xmAppId,
    this.xmAppKey,
    this.xmCertificateName,
    this.hwCertificateName,
    this.mzAppId,
    this.mzAppKey,
    this.mzCertificateName,
    this.fcmCertificateName,
    this.vivoCertificateName,
    this.apnsCername,
    this.pkCername,
  });

  ///小米推送 appId
  final String xmAppId;

  ///小米推送 appKey
  final String xmAppKey;

  ///小米推送证书，请在云信管理后台申请
  final String xmCertificateName;

  ///华为推送 appId 请在 AndroidManifest.xml 文件中配置 华为推送证书，请在云信管理后台申请
  final String hwCertificateName;

  ///魅族推送 appId
  final String mzAppId;

  ///魅族推送 appKey
  final String mzAppKey;

  ///魅族推送证书，请在云信管理后台申请
  final String mzCertificateName;

  ///FCM 推送证书，请在云信管理后台申请 海外客户使用
  final String fcmCertificateName;

  ///VIVO推送 appId apiKey请在 AndroidManifest.xml 文件中配置 VIVO推送证书，请在云信管理后台申请
  final String vivoCertificateName;

  ///APNs 证书(iOS专用)
  final String apnsCername;

  ///Voip 证书(iOS专用)
  final String pkCername;

  //不同的类使用不同的mixin即可
  factory MixPushConfig.fromJson(Map<String, dynamic> json) =>
      _$MixPushConfigFromJson(json);

  Map<String, dynamic> toJson() => _$MixPushConfigToJson(this);
}

@JsonSerializable()
class NosTokenSceneConfig {
  NosTokenSceneConfig();

  //不同的类使用不同的mixin即可
  factory NosTokenSceneConfig.fromJson(Map<String, dynamic> json) =>
      _$NosTokenSceneConfigFromJson(json);

  Map<String, dynamic> toJson() => _$NosTokenSceneConfigToJson(this);
}

@JsonSerializable()
class LoginInfo {
  final String account;
  final String token;
  final String appKey;
  final bool forcedMode;

  LoginInfo({this.account, this.token, this.appKey, this.forcedMode});

  //不同的类使用不同的mixin即可
  factory LoginInfo.fromJson(Map<String, dynamic> json) =>
      _$LoginInfoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginInfoToJson(this);
}

@JsonSerializable()
class NIMNetCallOption {
  final String extendMessage;
  final String apnsContent;
  final String apnsSound;

  NIMNetCallOption({this.extendMessage, this.apnsContent, this.apnsSound});

  factory NIMNetCallOption.fromJson(Map<String, dynamic> json) =>
      _$NIMNetCallOptionFromJson(json);
  Map<String, dynamic> toJson() => _$NIMNetCallOptionToJson(this);
}

@JsonSerializable()
class NIMResponse {
  final String callID;
  final bool accept;

  NIMResponse({this.callID, this.accept});

  factory NIMResponse.fromJson(Map<String, dynamic> json) =>
      _$NIMResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NIMResponseToJson(this);
}

@JsonSerializable()
class NIMSession {
  final String sessionId;
  final int sessionType;

  NIMSession({this.sessionId, this.sessionType});

  factory NIMSession.fromJson(Map<String, dynamic> json) =>
      _$NIMSessionFromJson(json);
  Map<String, dynamic> toJson() => _$NIMSessionToJson(this);
}

@JsonSerializable()
class NIMLocationObject {
  final double latitude;
  final double longitude;
  final String title;

  NIMLocationObject({this.latitude, this.longitude, this.title});

  factory NIMLocationObject.fromJson(Map<String, dynamic> json) =>
      _$NIMLocationObjectFromJson(json);
  Map<String, dynamic> toJson() => _$NIMLocationObjectToJson(this);
}
