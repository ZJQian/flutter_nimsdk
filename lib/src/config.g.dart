// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SDKOptions _$SDKOptionsFromJson(Map<String, dynamic> json) {
  return SDKOptions(
      appKey: json['appKey'] as String,
      statusBarNotificationConfig: json['statusBarNotificationConfig'] == null
          ? null
          : StatusBarNotificationConfig.fromJson(
              json['statusBarNotificationConfig'] as Map<String, dynamic>),
      userInfoProvider: json['userInfoProvider'] == null
          ? null
          : UserInfoProvider.fromJson(
              json['userInfoProvider'] as Map<String, dynamic>),
      messageNotifierCustomization: json['messageNotifierCustomization'] == null
          ? null
          : MessageNotifierCustomization.fromJson(
              json['messageNotifierCustomization'] as Map<String, dynamic>),
      sdkStorageRootPath: json['sdkStorageRootPath'] as String,
      serverConfig: json['serverConfig'] == null
          ? null
          : ServerAddresses.fromJson(
              json['serverConfig'] as Map<String, dynamic>),
      mixPushConfig: json['mixPushConfig'] == null
          ? null
          : MixPushConfig.fromJson(
              json['mixPushConfig'] as Map<String, dynamic>),
      shouldConsiderRevokedMessageUnreadCount:
          json['shouldConsiderRevokedMessageUnreadCount'] as bool,
      mNosTokenSceneConfig: json['mNosTokenSceneConfig'] == null
          ? null
          : NosTokenSceneConfig.fromJson(
              json['mNosTokenSceneConfig'] as Map<String, dynamic>),
      loginCustomTag: json['loginCustomTag'] as String,
      disableAwake: json['disableAwake'] as bool,
      enableTeamMsgAck: json['enableTeamMsgAck'] as bool,
      enableLBSOptimize: json['enableLBSOptimize'] as bool,
      enableBackOffReconnectStrategy:
          json['enableBackOffReconnectStrategy'] as bool,
      checkManifestConfig: json['checkManifestConfig'] as bool,
      animatedImageThumbnailEnabled: json['animatedImageThumbnailEnabled'] as bool,
      useXLog: json['useXLog'] as bool,
      teamNotificationMessageMarkUnread: json['teamNotificationMessageMarkUnread'] as bool,
      preLoadServers: json['preLoadServers'] as bool,
      improveSDKProcessPriority: json['improveSDKProcessPriority'] as bool,
      sessionReadAck: json['sessionReadAck'] as bool,
      thumbnailSize: json['thumbnailSize'] as int,
      preloadAttach: json['preloadAttach'] as bool,
      useAssetServerAddressConfig: json['useAssetServerAddressConfig'] as bool);
}

Map<String, dynamic> _$SDKOptionsToJson(SDKOptions instance) =>
    <String, dynamic>{
      'appKey': instance.appKey,
      'useAssetServerAddressConfig': instance.useAssetServerAddressConfig,
      'statusBarNotificationConfig': instance.statusBarNotificationConfig,
      'userInfoProvider': instance.userInfoProvider,
      'messageNotifierCustomization': instance.messageNotifierCustomization,
      'sdkStorageRootPath': instance.sdkStorageRootPath,
      'preloadAttach': instance.preloadAttach,
      'thumbnailSize': instance.thumbnailSize,
      'sessionReadAck': instance.sessionReadAck,
      'improveSDKProcessPriority': instance.improveSDKProcessPriority,
      'serverConfig': instance.serverConfig,
      'preLoadServers': instance.preLoadServers,
      'teamNotificationMessageMarkUnread':
          instance.teamNotificationMessageMarkUnread,
      'useXLog': instance.useXLog,
      'animatedImageThumbnailEnabled': instance.animatedImageThumbnailEnabled,
      'checkManifestConfig': instance.checkManifestConfig,
      'mixPushConfig': instance.mixPushConfig,
      'enableBackOffReconnectStrategy': instance.enableBackOffReconnectStrategy,
      'enableLBSOptimize': instance.enableLBSOptimize,
      'enableTeamMsgAck': instance.enableTeamMsgAck,
      'shouldConsiderRevokedMessageUnreadCount':
          instance.shouldConsiderRevokedMessageUnreadCount,
      'mNosTokenSceneConfig': instance.mNosTokenSceneConfig,
      'loginCustomTag': instance.loginCustomTag,
      'disableAwake': instance.disableAwake
    };

StatusBarNotificationConfig _$StatusBarNotificationConfigFromJson(
    Map<String, dynamic> json) {
  return StatusBarNotificationConfig(
      notificationSmallIconId: json['notificationSmallIconId'] as int,
      notificationSound: json['notificationSound'] as String,
      downTimeBegin: json['downTimeBegin'] as String,
      downTimeEnd: json['downTimeEnd'] as String,
      notificationEntrance: json['notificationEntrance'] as String,
      notificationColor: json['notificationColor'] as int,
      customTitleWhenTeamNameEmpty:
          json['customTitleWhenTeamNameEmpty'] as String,
      vibrate: json['vibrate'] as bool,
      ring: json['ring'] as bool,
      ledOnMs: json['ledOnMs'] as int,
      ledARGB: json['ledARGB'] as int,
      showBadge: json['showBadge'] as bool,
      notificationFolded: json['notificationFolded'] as bool,
      titleOnlyShowAppName: json['titleOnlyShowAppName'] as bool,
      downTimeEnableNotification: json['downTimeEnableNotification'] as bool,
      downTimeToggle: json['downTimeToggle'] as bool,
      hideContent: json['hideContent'] as bool,
      ledOffMs: json['ledOffMs'] as int);
}

Map<String, dynamic> _$StatusBarNotificationConfigToJson(
        StatusBarNotificationConfig instance) =>
    <String, dynamic>{
      'notificationSmallIconId': instance.notificationSmallIconId,
      'ring': instance.ring,
      'notificationSound': instance.notificationSound,
      'vibrate': instance.vibrate,
      'ledARGB': instance.ledARGB,
      'ledOnMs': instance.ledOnMs,
      'ledOffMs': instance.ledOffMs,
      'hideContent': instance.hideContent,
      'downTimeToggle': instance.downTimeToggle,
      'downTimeBegin': instance.downTimeBegin,
      'downTimeEnd': instance.downTimeEnd,
      'downTimeEnableNotification': instance.downTimeEnableNotification,
      'notificationEntrance': instance.notificationEntrance,
      'titleOnlyShowAppName': instance.titleOnlyShowAppName,
      'notificationFolded': instance.notificationFolded,
      'notificationColor': instance.notificationColor,
      'showBadge': instance.showBadge,
      'customTitleWhenTeamNameEmpty': instance.customTitleWhenTeamNameEmpty
    };

UserInfoProvider _$UserInfoProviderFromJson(Map<String, dynamic> json) {
  return UserInfoProvider();
}

Map<String, dynamic> _$UserInfoProviderToJson(UserInfoProvider instance) =>
    <String, dynamic>{};

MessageNotifierCustomization _$MessageNotifierCustomizationFromJson(
    Map<String, dynamic> json) {
  return MessageNotifierCustomization();
}

Map<String, dynamic> _$MessageNotifierCustomizationToJson(
        MessageNotifierCustomization instance) =>
    <String, dynamic>{};

ServerAddresses _$ServerAddressesFromJson(Map<String, dynamic> json) {
  return ServerAddresses(
      publicKey: json['publicKey'] as String,
      lbs: json['lbs'] as String,
      defaultLink: json['defaultLink'] as String,
      nosUploadLbs: json['nosUploadLbs'] as String,
      nosUploadDefaultLink: json['nosUploadDefaultLink'] as String,
      nosUpload: json['nosUpload'] as String,
      nosDownloadUrlFormat: json['nosDownloadUrlFormat'] as String,
      nosDownload: json['nosDownload'] as String,
      nosAccess: json['nosAccess'] as String,
      ntServerAddress: json['ntServerAddress'] as String,
      bdServerAddress: json['bdServerAddress'] as String,
      test: json['test'] as bool,
      nosSupportHttps: json['nosSupportHttps'] as bool);
}

Map<String, dynamic> _$ServerAddressesToJson(ServerAddresses instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'lbs': instance.lbs,
      'defaultLink': instance.defaultLink,
      'nosUploadLbs': instance.nosUploadLbs,
      'nosUploadDefaultLink': instance.nosUploadDefaultLink,
      'nosUpload': instance.nosUpload,
      'nosSupportHttps': instance.nosSupportHttps,
      'nosDownloadUrlFormat': instance.nosDownloadUrlFormat,
      'nosDownload': instance.nosDownload,
      'nosAccess': instance.nosAccess,
      'ntServerAddress': instance.ntServerAddress,
      'bdServerAddress': instance.bdServerAddress,
      'test': instance.test
    };

MixPushConfig _$MixPushConfigFromJson(Map<String, dynamic> json) {
  return MixPushConfig(
      xmAppId: json['xmAppId'] as String,
      xmAppKey: json['xmAppKey'] as String,
      xmCertificateName: json['xmCertificateName'] as String,
      hwCertificateName: json['hwCertificateName'] as String,
      mzAppId: json['mzAppId'] as String,
      mzAppKey: json['mzAppKey'] as String,
      mzCertificateName: json['mzCertificateName'] as String,
      fcmCertificateName: json['fcmCertificateName'] as String,
      vivoCertificateName: json['vivoCertificateName'] as String,
      apnsCername: json['apnsCername'] as String,
      pkCername: json['pkCername'] as String);
}

Map<String, dynamic> _$MixPushConfigToJson(MixPushConfig instance) =>
    <String, dynamic>{
      'xmAppId': instance.xmAppId,
      'xmAppKey': instance.xmAppKey,
      'xmCertificateName': instance.xmCertificateName,
      'hwCertificateName': instance.hwCertificateName,
      'mzAppId': instance.mzAppId,
      'mzAppKey': instance.mzAppKey,
      'mzCertificateName': instance.mzCertificateName,
      'fcmCertificateName': instance.fcmCertificateName,
      'vivoCertificateName': instance.vivoCertificateName,
      'apnsCername': instance.apnsCername,
      'pkCername': instance.pkCername
    };

NosTokenSceneConfig _$NosTokenSceneConfigFromJson(Map<String, dynamic> json) {
  return NosTokenSceneConfig();
}

Map<String, dynamic> _$NosTokenSceneConfigToJson(
        NosTokenSceneConfig instance) =>
    <String, dynamic>{};

LoginInfo _$LoginInfoFromJson(Map<String, dynamic> json) {
  return LoginInfo(
      account: json['account'] as String,
      token: json['token'] as String,
      appKey: json['appKey'] as String,
      forcedMode: json['forcedMode'] as bool);
}

Map<String, dynamic> _$LoginInfoToJson(LoginInfo instance) => <String, dynamic>{
      'account': instance.account,
      'token': instance.token,
      'appKey': instance.appKey,
      'forcedMode': instance.forcedMode
    };

NIMNetCallOption _$NIMNetCallOptionFromJson(Map<String, dynamic> json) {
  return NIMNetCallOption(
    extendMessage: json['extendMessage'] as String,
    apnsContent: json['apnsContent'] as String,
    apnsSound: json['apnsSound'] as String
  );
}

Map<String, dynamic> _$NIMNetCallOptionToJson(NIMNetCallOption instance) => <String, dynamic>{
      'extendMessage': instance.extendMessage,
      'apnsContent': instance.apnsContent,
      'apnsSound': instance.apnsSound
    };


NIMResponse _$NIMResponseFromJson(Map<String, dynamic> json) {
  return NIMResponse(
    callID: json['callID'] as String,
    accept: json['accept'] as bool
  );
}

Map<String, dynamic> _$NIMResponseToJson(NIMResponse instance) => <String, dynamic>{
      'callID': instance.callID,
      'accept': instance.accept
    };

NIMSession _$NIMSessionFromJson(Map<String, dynamic> json) {
  return NIMSession(
    sessionId: json['sessionId'] as String,
    sessionType: json['sessionType'] as int
  );
}

Map<String, dynamic> _$NIMSessionToJson(NIMSession instance) => <String, dynamic>{
      'sessionId': instance.sessionId,
      'sessionType': instance.sessionType
    };

NIMLocationObject _$NIMLocationObjectFromJson(Map<String, dynamic> json) {
  return NIMLocationObject(
    latitude: json['latitude'] as double,
    longitude: json['longitude'] as double,
    title: json['title'] as String,
  );
}

Map<String, dynamic> _$NIMLocationObjectToJson(NIMLocationObject instance) => <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'title': instance.title
    };
