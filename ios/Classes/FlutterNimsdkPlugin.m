#import "FlutterNimsdkPlugin.h"
#import <NIMSDK/NIMSDK.h>
#import <NIMAVChat/NIMAVChat.h>
#import <MJExtension/MJExtension.h>
#import "NimDataManager.h"
#import "FlutterNimViewFactory.h"
#import "IMCustomAttachment.h"
#import "IMCustomMessageAttachmentDecoder.h"
#import "NimSessionParser.h"
#import "Attach/NTESSnapchatAttachment.h"
//#import "FaceunityManager/FUManager.h"

typedef enum : NSUInteger {
    NIMDelegateTypeOnLogin = 0,
    NIMDelegateTypeOnReceive = 1,
    NIMDelegateTypeOnResponse = 2,
    NIMDelegateTypeOnCallEstablished = 3,
    NIMDelegateTypeOnHangup = 4,
    NIMDelegateTypeOnCallDisconnected = 5,
    NIMDelegateTypeDidAddRecentSession = 6,
    NIMDelegateTypeDidUpdateRecentSession = 7,
    NIMDelegateTypeDidRemoveRecentSession = 8,
    NIMDelegateTypeRecordAudioComplete = 9,
    NIMDelegateTypeOnRecvMessageReceipts = 10,
    NIMDelegateTypeOnControl = 11,

    NIMDelegateTypeWillSendMessage = 12,
    NIMDelegateTypeUploadAttachmentSuccess = 13,
    NIMDelegateTypeSendMessageProcess = 14,
    NIMDelegateTypeSendMessageComplete = 15,
    NIMDelegateTypeOnRecvMessages = 16,
    NIMDelegateTypeOnRecvRevokeMessageNotification = 17,
    NIMDelegateTypeFetchMessageAttachmentProcess = 18,
    NIMDelegateTypeFetchMessageAttachmentComplete = 19,
} NIMDelegateType;

@interface FlutterNimsdkPlugin ()<NIMLoginManagerDelegate,
                                  FlutterStreamHandler,
                                  NIMNetCallManagerDelegate,
                                  NIMConversationManagerDelegate,
                                  NIMChatManagerDelegate,
                                  NIMMediaManagerDelegate>
{
    NSObject<FlutterPluginRegistrar> *_registrar;
}
@property (nonatomic) FlutterEventSink eventSink;
@property (nonatomic, strong) FlutterMethodChannel *methodChannel;
@property (nonatomic, strong) NSMutableArray *sessions;
@property (nonatomic, strong) NSMutableArray *messages;

/// 录音时长
@property (nonatomic, assign) NSTimeInterval recordTime;

/// sessionID
@property (nonatomic, copy) NSString *sessionID;

@property (nonatomic, assign) NIMNetCallMediaType mediaType;

@property (nonatomic, copy) NSString *currentTimeStamp;

@end

static NSString *const kEventChannelName = @"flutter_nimsdk/Event/Channel";
static NSString *const kMethodChannelName = @"flutter_nimsdk/Method/Channel";

@implementation FlutterNimsdkPlugin
//+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
//  [SwiftFlutterNimsdkPlugin registerWithRegistrar:registrar];
//}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
{
    FlutterMethodChannel *channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_nimsdk"
                                           binaryMessenger:[registrar messenger]];
    FlutterNimsdkPlugin *instance = [[FlutterNimsdkPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];

    // 初始化FlutterEventChannel对象
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:kEventChannelName binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:instance];

    [[[NIMSDK sharedSDK] loginManager] addDelegate:instance];
    [[[NIMSDK sharedSDK] mediaManager] addDelegate:instance];
    [[[NIMSDK sharedSDK] chatManager] addDelegate:instance];
    [[[NIMSDK sharedSDK] conversationManager] addDelegate:instance];
    [[[NIMAVChatSDK sharedSDK] netCallManager] addDelegate:instance];

    [instance initChannel:registrar];
}

///处理 flutter 向 native 发送的一些消息
- (void)initChannel:(NSObject<FlutterPluginRegistrar> *)registrar
{
    _registrar = registrar;

//    __weak typeof(self) weakSelf = self;
    self.methodChannel = [FlutterMethodChannel methodChannelWithName:kMethodChannelName binaryMessenger:[registrar messenger]];
    [self.methodChannel setMethodCallHandler:^(FlutterMethodCall *_Nonnull call, FlutterResult _Nonnull result) {
        if ([call.method isEqualToString:@"response"]) {//调用哪个方法
            NSLog(@"%@------%@", call.method, call.arguments);

            //初始化option
            NIMNetCallOption *option = [[NIMNetCallOption alloc] init];

            //指定 option 中的 videoCaptureParam 参数
            NIMNetCallVideoCaptureParam *param = [[NIMNetCallVideoCaptureParam alloc] init];
            option.videoCaptureParam = param;

            NSDictionary *args = call.arguments;
            NSString *callidStr = args[@"response"][@"callID"];

            UInt64 callid = [callidStr longLongValue];
            BOOL accept = [NSString stringWithFormat:@"%@", args[@"response"][@"accept"]].boolValue;

//            int mediaType = [NSString stringWithFormat:@"%@",args[@"mediaType"]].intValue;
            [[NIMAVChatSDK sharedSDK].netCallManager response:callid accept:accept option:option completion:^(NSError *_Nullable error, UInt64 callID) {
                //链接成功
                if (!error) {
                    result(nil);
                } else {//链接失败
                    NSDictionary *dic = @{ @"callID": [NSString stringWithFormat:@"%llu", callID],
                                           @"errorCode": [NSNumber numberWithInteger:error.code],
                                           @"msg": error.description };
                    result([[NimDataManager shared] dictionaryToJson:dic]);
                }
            }];
//            result([NSString stringWithFormat:@"MethodChannel:收到Dart消息：%@",call.arguments]);
        }
    }];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result
{
    NSLog(@"\n**************************************************************\n \n  call.method ===> %@  \n call.arguments ==> %@ \n \n**************************************************************\n", call.method, call.arguments);

    if ([@"initSDK" isEqualToString:call.method]) {// 初始化
        NSDictionary *dict = call.arguments;

        NSDictionary *optionDict = dict[@"options"];
        NSString *appKey = optionDict[@"appKey"];
        if (appKey == nil || [appKey isEqual:[NSNull null]] || [appKey isEqualToString:@""]) {
            result([FlutterError errorWithCode:@"ERROR"
                                       message:@"appKey is null"
                                       details:nil]);
            return;
        }
        NIMSDKOption *option = [NIMSDKOption optionWithAppKey:appKey];

        id pushConfigDict = optionDict[@"mixPushConfig"];
        //CerName 为开发者为推送证书在云信管理后台定义的名字，在使用中，云信服务器会寻找同名推送证书发起苹果推送服务。
        //目前 CerName 可传 APNs 证书 和 Voip 证书两种，分别对应了参数中 apnsCername 和 pkCername 两个字段。
        if (pushConfigDict != nil && [pushConfigDict isEqual:[NSNull null]] && [pushConfigDict isKindOfClass:[NSDictionary class]]) {
            option.apnsCername = pushConfigDict[@"apnsCername"];
            option.pkCername = pushConfigDict[@"pkCername"];
        }

        [[NIMSDK sharedSDK] registerWithOption:option];
        [NIMCustomObject registerCustomDecoder:[[IMCustomMessageAttachmentDecoder alloc] init]];

        //为了更好的应用体验，SDK 需要对应用数据做一些本地持久，比如消息，用户信息等等。在默认情况下，所有数据将放置于 $Document/NIMSDK 目录下。
        //设置该值后 SDK 产生的数据(包括聊天记录，但不包括临时文件)都将放置在这个目录下

        [self getValue:optionDict key:@"sdkStorageRootPath":^(id result) {
            [[NIMSDKConfig sharedConfig] setupSDKDir:result];
        }];

        //是否在收到消息后自动下载附件
        BOOL preloadAttach = [optionDict[@"preloadAttach"] boolValue];
        [NIMSDKConfig sharedConfig].fetchAttachmentAutomaticallyAfterReceiving = preloadAttach;
        [NIMSDKConfig sharedConfig].fetchAttachmentAutomaticallyAfterReceivingInChatroom = preloadAttach;

        //是否需要将被撤回的消息计入未读计算考虑
        [self getValue:optionDict key:@"shouldConsiderRevokedMessageUnreadCount":^(id result) {
            [NIMSDKConfig sharedConfig].shouldConsiderRevokedMessageUnreadCount = [result boolValue];
        }];

        //是否需要多端同步未读数
        BOOL shouldSyncUnreadCount = [optionDict[@"sessionReadAck"] boolValue];
        [NIMSDKConfig sharedConfig].shouldSyncUnreadCount = shouldSyncUnreadCount;

        //是否将群通知计入未读
        BOOL shouldCountTeamNotification = [optionDict[@"teamNotificationMessageMarkUnread"] boolValue];
        [NIMSDKConfig sharedConfig].shouldCountTeamNotification = shouldCountTeamNotification;

        //是否支持动图缩略
        BOOL animatedImageThumbnailEnabled = [optionDict[@"animatedImageThumbnailEnabled"] boolValue];
        [NIMSDKConfig sharedConfig].animatedImageThumbnailEnabled = animatedImageThumbnailEnabled;

        //客户端自定义信息，用于多端登录时同步该信息
        [self getValue:optionDict key:@"customTag":^(id result) {
            [NIMSDKConfig sharedConfig].customTag = result;
        }];

        result(nil);
    } else if ([@"login" isEqualToString:call.method]) {
        // MARK: - 登陆

        NSDictionary *args = call.arguments;
        NSString *account = args[@"account"];
        NSString *token = args[@"token"];
        [[[NIMSDK sharedSDK] loginManager]login:account token:token completion:^(NSError *_Nullable error) {
            NSLog(@"请求结果：%@", error);
            if (error == nil) {
                result(nil);
            } else {
                NSString *msg = error.userInfo[@"NSLocalizedDescription"] == nil ? @"" : error.userInfo[@"NSLocalizedDescription"];
                NSDictionary *dic = @{ @"code": [NSNumber numberWithInteger:error.code], @"msg": [NSString stringWithFormat:@"%@", msg] };
                result([[NimDataManager shared] dictionaryToJson:dic]);
            }
        }];
    } else if ([@"autoLogin" isEqualToString:call.method]) {
        // MARK: -  自动登陆

        NSDictionary *args = call.arguments;
        NSString *account = args[@"account"];
        NSString *token = args[@"token"];

        NIMAutoLoginData *loginData = [[NIMAutoLoginData alloc] init];
        loginData.account = account;
        loginData.token = token;
        [[[NIMSDK sharedSDK] loginManager] autoLogin:loginData];
    } else if ([@"logout" isEqualToString:call.method]) {
        // MARK: - 登出

        [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error) {
        }];
    } else if ([@"start" isEqualToString:call.method]) {
        // MARK: - 发起通话

        NSDictionary *args = call.arguments;
        self.currentTimeStamp = args[@"timeStamp"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *callees = args[@"callees"];

            int type = [NSString stringWithFormat:@"%@", args[@"type"]].intValue;
            NIMNetCallOption *option = [[NIMNetCallOption alloc] init];
            option.extendMessage = args[@"options"][@"extendMessage"];
            option.apnsContent = args[@"options"][@"apnsContent"];
            option.apnsSound = args[@"options"][@"apnsSound"] == nil ? @"video_chat_tip_receiver.aac" : args[@"options"][@"apnsSound"];

            //指定 option 中的 videoCaptureParam 参数
            NIMNetCallVideoCaptureParam *param = [[NIMNetCallVideoCaptureParam alloc] init];
            //清晰度480P
            param.preferredVideoQuality = NIMNetCallVideoQuality480pLevel;
            //裁剪类型 16:9
            param.videoCrop = NIMNetCallVideoCrop16x9;
            //打开初始为前置摄像头
            param.startWithBackCamera = NO;

            //若需要开启前处理指定 videoProcessorParam
            NIMNetCallVideoProcessorParam *videoProcessorParam = [[NIMNetCallVideoProcessorParam alloc] init];
            //若需要通话开始时就带有前处理效果（如美颜自然模式）
            videoProcessorParam.filterType = NIMNetCallFilterTypeZiran;
            param.videoProcessorParam = videoProcessorParam;

            option.videoCaptureParam = param;
            option.videoCaptureParam.videoHandler = ^(CMSampleBufferRef _Nonnull sampleBuffer) {
                [self processVideoCallWithBuffer:sampleBuffer];
            };

            self.mediaType = type + 1;

            //开始通话
            [[NIMAVChatSDK sharedSDK].netCallManager start:@[callees] type:(type + 1) option:option completion:^(NSError *error, UInt64 callID) {
                if (!error) {
                    //通话发起成功

                    NSDictionary *dic = @{ @"callID": [NSString stringWithFormat:@"%llu", callID], @"msg": @"通话发起成功" };
                    result([[NimDataManager shared] dictionaryToJson:dic]);
                } else {
                    //通话发起失败
                    NSString *msg = error.userInfo[@"NSLocalizedDescription"] == nil ? @"通话发起失败" : error.userInfo[@"NSLocalizedDescription"];
                    NSDictionary *dic = @{ @"error": msg, @"errorCode": [NSNumber numberWithInteger:error.code], @"callID": [NSString stringWithFormat:@"%llu", callID] };
                    result([[NimDataManager shared] dictionaryToJson:dic]);
                }
            }];
        });
    } else if ([@"hangup" isEqualToString:call.method]) {
        // MARK: - 挂断

        NSDictionary *args = call.arguments;
        NSString *callID_str = args[@"callID"];
        UInt64 callID = callID_str == nil ? 0 : callID_str.longLongValue;
        //挂断电话
        [[NIMAVChatSDK sharedSDK].netCallManager hangup:callID];
    } else if ([@"records" isEqualToString:call.method]) { // 获取话单
        NIMNetCallRecordsSearchOption *searchOption = [[NIMNetCallRecordsSearchOption alloc] init];
        searchOption.timestamp = [[NSDate date] timeIntervalSince1970];

        [[NIMAVChatSDK sharedSDK].netCallManager recordsWithOption:nil completion:^(NSArray<NIMMessage *> *_Nullable records, NSError *_Nullable error) {
            if (!error) {
                NSMutableArray *recordArray = [NSMutableArray array];
                for (NIMMessage *msg in records) {
                    NSDictionary *dict = [[NimDataManager shared] handleNIMMessage:msg];
                    [recordArray addObject:dict];
                }
                NSDictionary *dic = @{ @"records": recordArray };
                result([[NimDataManager shared] dictionaryToJson:dic]);
            } else {
                NSString *msg = error.userInfo[@"NSLocalizedDescription"] == nil ? @"获取话单失败" : error.userInfo[@"NSLocalizedDescription"];
                NSDictionary *dic = @{ @"error": msg, @"errorCode": [NSNumber numberWithInteger:error.code] };
                result([[NimDataManager shared] dictionaryToJson:dic]);
            }
        }];
    } else if ([@"deleteAllRecords" isEqualToString:call.method]) {//清空点对点通话记录
        [[NIMAVChatSDK sharedSDK].netCallManager deleteAllRecords];
    } else if ([@"setCameraDisable" isEqualToString:call.method]) {//动态设置摄像头开关
        NSDictionary *args = call.arguments;
        BOOL isDisable = [NSString stringWithFormat:@"%@", args[@"disable"]].boolValue;
        //打开摄像头 false    关闭摄像头  true
        [[NIMAVChatSDK sharedSDK].netCallManager setCameraDisable:isDisable];
    } else if ([@"switchCamera" isEqualToString:call.method]) {
        // MARK: - //动态切换摄像头前后

        NSDictionary *args = call.arguments;
        NSString *camera = args[@"camera"];
        NIMNetCallCamera position = NIMNetCallCameraFront;
        if ([camera isEqualToString:@"front"]) {
            position = NIMNetCallCameraFront;
        } else {
            position = NIMNetCallCameraBack;
        }
        [[NIMAVChatSDK sharedSDK].netCallManager switchCamera:position];
    } else if ([@"setMute" isEqualToString:call.method]) {
        // MARK: - //设置静音

        NSDictionary *args = call.arguments;
        BOOL isMute = [NSString stringWithFormat:@"%@", args[@"mute"]].boolValue;
        //开启静音 YES  关闭静音 No
        [[NIMAVChatSDK sharedSDK].netCallManager setMute:isMute];
    } else if ([@"setSpeaker" isEqualToString:call.method]) {
        // MARK: -//设置扬声器

        NSDictionary *args = call.arguments;
        BOOL isSpeaker = [NSString stringWithFormat:@"%@", args[@"speaker"]].boolValue;
        //开启扬声器  YES
        [[NIMAVChatSDK sharedSDK].netCallManager setSpeaker:isSpeaker];
    } else if ([@"mostRecentSessions" isEqualToString:call.method]) {
        // MARK: - //获取所有最近100条会话

        NSArray *recentSessions = [NIMSDK sharedSDK].conversationManager.mostRecentSessions;
        self.sessions = [NSMutableArray arrayWithArray:recentSessions];
        NSMutableArray *users = [NSMutableArray array];
        for (NIMRecentSession *session in recentSessions) {
            [users addObject:session.session.sessionId];
        }
        [[[NIMSDK sharedSDK] userManager] fetchUserInfos:users completion:^(NSArray<NIMUser *> *_Nullable users, NSError *_Nullable error) {
            NSArray *array = [[NimSessionParser shared] handleRecentSessions:recentSessions users:users];
            NSDictionary *dic = @{ @"mostRecentSessions": array };
            result([[NimDataManager shared] dictionaryToJson:dic]);
        }];
    } else if ([@"allRecentSessions" isEqualToString:call.method]) {
        // MARK: - // 获取所有最近100条会话

        NSArray *recentSessions = [NIMSDK sharedSDK].conversationManager.allRecentSessions;
        self.sessions = [NSMutableArray arrayWithArray:recentSessions];
        NSMutableArray *users = [NSMutableArray array];
        for (NIMRecentSession *session in recentSessions) {
            [users addObject:session.session.sessionId];
        }
        [[[NIMSDK sharedSDK] userManager] fetchUserInfos:users completion:^(NSArray<NIMUser *> *_Nullable users, NSError *_Nullable error) {
            NSArray *array = [[NimSessionParser shared] handleRecentSessions:recentSessions users:users];
            NSDictionary *dic = @{ @"allRecentSessions": array };
            result([[NimDataManager shared] dictionaryToJson:dic]);
        }];
    } else if ([@"deleteRecentSession" isEqualToString:call.method]) {
        // MARK: - //删除某个最近会话

        NSArray *recentSessions = [NIMSDK sharedSDK].conversationManager.mostRecentSessions;
        NSDictionary *args = call.arguments;
        NSString *sessionID = args[@"sessionID"];
        for (NIMRecentSession *session in recentSessions) {
            if ([session.session.sessionId isEqualToString:sessionID]) {
                [[NIMSDK sharedSDK].conversationManager deleteRecentSession:session];
            }
        }
    } else if ([@"deleteAllRecentSession" isEqualToString:call.method]) {
        // MARK: - //删除所有最近会话

        NSArray *recentSessions = [NIMSDK sharedSDK].conversationManager.mostRecentSessions;
        for (NIMRecentSession *session in recentSessions) {
            [[NIMSDK sharedSDK].conversationManager deleteRecentSession:session];
        }
    } else if ([@"messagesInSession" isEqualToString:call.method]) {
        // MARK: - //获取会话所有消息

        NSDictionary *args = call.arguments;
        NIMSession *session = [NIMSession mj_objectWithKeyValues:args[@"session"]];
        NSArray *messageIds = args[@"messageIds"];
        NSArray *messages = [[[NIMSDK sharedSDK] conversationManager] messagesInSession:session messageIds:messageIds];
        self.messages = [NSMutableArray arrayWithArray:messages];
        NSArray *messageDics = [NIMMessage mj_keyValuesArrayWithObjectArray:messages];
        result([[NimDataManager shared] dictionaryToJson:@{ @"messages": messageDics }]);
    } else if ([@"markAudioMessageRead" isEqualToString:call.method]) {
        // MARK: - 语音消息已读
        NSDictionary *args = call.arguments;
        NIMSession *session = [NIMSession mj_objectWithKeyValues:args[@"session"]];
        NSString *messageId = args[@"messageId"];
        NSArray *messages = [[[NIMSDK sharedSDK] conversationManager] messagesInSession:session messageIds:@[messageId]];
        for (NIMMessage *message in messages) {
            if ([message.messageId isEqualToString:messageId]) {
                message.isPlayed = YES;
            }
        }
    } else if ([@"messagesInSessionMessage" isEqualToString:call.method]) {
        // MARK: - 从本地db读取一个会话里某条消息之前的若干条的消息

        NSDictionary *args = call.arguments;
        NIMSession *session = [NIMSession mj_objectWithKeyValues:args[@"session"]];
        NIMMessage *message = [NIMMessage mj_objectWithKeyValues:args[@"message"]];
        NSInteger limit = [NSString stringWithFormat:@"%@", args[@"limit"]].integerValue;
        NSArray *messages = [[[NIMSDK sharedSDK] conversationManager] messagesInSession:session message:message limit:limit];
        NSMutableArray *array = [NSMutableArray array];
        for (NIMMessage *m in messages) {
            [array addObject:[[NimDataManager shared] handleNIMMessage:m]];
        }
        result([[NimDataManager shared] dictionaryToJson:@{ @"messages": array }]);
    } else if ([@"allUnreadCount" isEqualToString:call.method]) {
        // MARK: - //获取所有未读

        NSInteger count = [[NIMSDK sharedSDK].conversationManager allUnreadCount];
        result([NSString stringWithFormat:@"%ld", (long)count]);
    } else if ([@"sendTextMessage" isEqualToString:call.method]) {//文本
        [self sendMessage:NIMMessageTypeText args:call.arguments];
    } else if ([@"sendTipMessage" isEqualToString:call.method]) {//提示
        [self sendMessage:NIMMessageTypeTip args:call.arguments];
    } else if ([@"sendImageMessage" isEqualToString:call.method]) {//图片
        [self sendMessage:NIMMessageTypeImage args:call.arguments];
    } else if ([@"sendVideoMessage" isEqualToString:call.method]) {//视频
        [self sendMessage:NIMMessageTypeVideo args:call.arguments];
    } else if ([@"sendAudioMessage" isEqualToString:call.method]) {//音频
        [self sendMessage:NIMMessageTypeAudio args:call.arguments];
    } else if ([@"sendFileMessage" isEqualToString:call.method]) {//文件
        [self sendMessage:NIMMessageTypeFile args:call.arguments];
    } else if ([@"sendLocationMessage" isEqualToString:call.method]) {//位置
        [self sendMessage:NIMMessageTypeLocation args:call.arguments];
    } else if ([@"sendCustomMessage" isEqualToString:call.method]) {//自定义消息
        [self sendCustomMessage:call.arguments];
    }
//    else if ([@"sendSnapChat" isEqualToString:call.method]) {
//        // MARK: - 阅后即焚
//        NSDictionary *args = call.arguments;
//        NSString *path = args[@"imagePath"];
//        NSString *apnsContent = args[@"apnsContent"];
//        NSString *displayName = [NSString stringWithFormat:@"%@",args[@"displayName"]];
//        NSDictionary *sessionDic = args[@"nimSession"];
//        NSString *sessionID = sessionDic[@"sessionId"];
//        int type = [NSString stringWithFormat:@"%@", args == nil ? @"0" : sessionDic[@"sessionType"]].intValue;
//        NIMSessionType sessionType = NIMSessionTypeP2P;
//        if (type == 3) {
//            sessionType = NIMSessionTypeSuperTeam;
//        } else {
//            sessionType = type;
//        }
//
//        // 构造出具体会话
//        NIMSession *session = [NIMSession session:sessionID type:sessionType];
//
//
//        NTESSnapchatAttachment *attachment = [[NTESSnapchatAttachment alloc] init];
//        [attachment setImageFilePath:path];
//        attachment.displayName = displayName;
//        NIMMessage *message               = [[NIMMessage alloc] init];
//        NIMCustomObject *customObject     = [[NIMCustomObject alloc] init];
//        customObject.attachment           = attachment;
//        message.messageObject             = customObject;
//        message.apnsContent = (apnsContent == nil) ? @"阅后即焚消息" : @"";
//
//        NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
//        setting.historyEnabled = NO;
//        setting.roamingEnabled = NO;
//        setting.syncEnabled    = NO;
//        message.setting = setting;
//        NSError *error = nil;
//        [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:&error];
//
//    }
    else if ([@"destorySnapChat" isEqualToString:call.method]) {
        
        NSDictionary *args = call.arguments;
        NIMSession *session = [NIMSession mj_objectWithKeyValues:args[@"session"]];
        NSString *messageId = args[@"messageId"];
        NSArray *messages = [[[NIMSDK sharedSDK] conversationManager] messagesInSession:session messageIds:@[messageId]];
        for (NIMMessage *message in messages) {
            if ([message.messageId isEqualToString:messageId]) {
            
                NIMMessage *tempMessage = message;
                NIMCustomObject *object = (NIMCustomObject *)tempMessage.messageObject;
                NTESSnapchatAttachment *attachment = (NTESSnapchatAttachment *)object.attachment;
                attachment.isFired  = YES;
                attachment.displayName = @"0";
                object.attachment = attachment;
                tempMessage.messageObject = object;
                
                [[[NIMSDK sharedSDK] conversationManager] updateMessage:tempMessage forSession:tempMessage.session completion:^(NSError * _Nullable error) {
                    
                    if (error == nil) {
                        result([[NimDataManager shared] dictionaryToJson:@{ @"message": @"销毁阅后即焚消息成功" }]);
                    } else {
                        NSString *msg = error.userInfo[@"NSLocalizedDescription"] == nil ? @"销毁阅后即焚消息失败" : error.userInfo[@"NSLocalizedDescription"];
                        NSDictionary *dic = @{ @"error": msg, @"errorCode": [NSNumber numberWithInteger:error.code] };

                        result([[NimDataManager shared] dictionaryToJson:dic]);
                    }
                }];
            }
        }
        
        
    } else if ([@"onStartRecording" isEqualToString:call.method]) {//录音
        self.sessionID = call.arguments[@"sessionId"];
        [[[NIMSDK sharedSDK] mediaManager] record:NIMAudioTypeAAC duration:60.0];
    } else if ([@"onStopRecording" isEqualToString:call.method]) {//结束录音
        self.sessionID = call.arguments[@"sessionId"];
        [[[NIMSDK sharedSDK] mediaManager] stopRecord];
    } else if ([@"onCancelRecording" isEqualToString:call.method]) {//取消录音
        self.sessionID = call.arguments[@"sessionId"];
        [[[NIMSDK sharedSDK] mediaManager] cancelRecord];
    } else if ([@"sendMessageReceipt" isEqualToString:call.method]) {//已读回执
        NIMMessage *message = [NIMMessage mj_objectWithKeyValues:call.arguments];
        NIMMessageReceipt *messageReceipt = [[NIMMessageReceipt alloc] initWithMessage:message];
        [[[NIMSDK sharedSDK] chatManager] sendMessageReceipt:messageReceipt completion:nil];
    } else if ([@"removeDelegate" isEqualToString:call.method]) {//移除代理
        [[[NIMAVChatSDK sharedSDK] netCallManager] removeDelegate:self];
        [[[NIMSDK sharedSDK] loginManager] removeDelegate:self];
        [[[NIMSDK sharedSDK] mediaManager] removeDelegate:self];
        [[[NIMSDK sharedSDK] chatManager] removeDelegate:self];
    } else if ([@"markAllMessagesRead" isEqualToString:call.method]) {//标记全部已读
        [[[NIMSDK sharedSDK] conversationManager] markAllMessagesRead];
    } else if ([@"markAllMessagesReadInSession" isEqualToString:call.method]) {//设置一个会话里所有消息置为已读
        NSDictionary *args = call.arguments;
        NIMSession *session = [NIMSession mj_objectWithKeyValues:args[@"session"]];
        //只有当消息所属会话时会话页表示的会话时，才标记已读
        [[NIMSDK sharedSDK].conversationManager markAllMessagesReadInSession:session];
    } else if ([@"deleteMessage" isEqualToString:call.method]) {// 删除某条消息
        NIMMessage *message = [NIMMessage mj_objectWithKeyValues:call.arguments];
        [[[NIMSDK sharedSDK] conversationManager] deleteMessage:message];
    } else if ([@"deleteAllmessagesInSession" isEqualToString:call.method]) {// 删除某条消息
        NSDictionary *args = call.arguments;
        NIMSession *session = [NIMSession mj_objectWithKeyValues:args[@"session"]];
        NIMDeleteMessagesOption *option = [NIMDeleteMessagesOption mj_objectWithKeyValues:args[@"option"]];
        [[[NIMSDK sharedSDK] conversationManager] deleteAllmessagesInSession:session option:option];
    } else if ([@"deleteAllMessages" isEqualToString:call.method]) {// 删除所有会话消息
        NIMDeleteMessagesOption *option = [NIMDeleteMessagesOption mj_objectWithKeyValues:call.arguments];
        [[[NIMSDK sharedSDK] conversationManager] deleteAllMessages:option];
    } else if ([@"fetchMessageHistory" isEqualToString:call.method]) {// 从服务器上获取一个会话里某条消息之前的若干条的消息
        NIMSession *session = [NIMSession mj_objectWithKeyValues:call.arguments[@"session"]];
        NIMHistoryMessageSearchOption *option = [NIMHistoryMessageSearchOption mj_objectWithKeyValues:call.arguments[@"option"]];
        [[[NIMSDK sharedSDK] conversationManager] fetchMessageHistory:session option:option result:^(NSError *_Nullable error, NSArray<NIMMessage *> *_Nullable messages) {
            if (error == nil) {
                NSArray *array = [NIMMessage mj_keyValuesArrayWithObjectArray:messages];
                NSDictionary *dic = @{ @"messages": array };
                result([[NimDataManager shared] dictionaryToJson:dic]);
            } else {
                NSString *msg = error.userInfo[@"NSLocalizedDescription"] == nil ? @"获取聊天记录失败" : error.userInfo[@"NSLocalizedDescription"];
                NSDictionary *dic = @{ @"error": msg, @"errorCode": [NSNumber numberWithInteger:error.code] };
                result([[NimDataManager shared] dictionaryToJson:dic]);
            }
        }];
    } else if ([@"netCallControl" isEqualToString:call.method]) {
        // MARK: - 发送网络通话的控制信息，用于方便通话双方沟通信息

        NSDictionary *args = call.arguments;
        UInt64 currentCallID = [[[NIMAVChatSDK sharedSDK] netCallManager] currentCallID];
        NIMNetCallControlType type = [NSString stringWithFormat:@"%@", args[@"netCallControlType"]].integerValue;
        [[[NIMAVChatSDK sharedSDK] netCallManager] control:currentCallID type:type];
    } else if ([@"currentCallID" isEqualToString:call.method]) {
        // MARK: - 获取正在进行中的网络通话call id
        UInt64 currentCallID = [[[NIMAVChatSDK sharedSDK] netCallManager] currentCallID];
        NSString *strCallID = [NSString stringWithFormat:@"%llu", currentCallID];
        result(strCallID);
    }
    // else if ([@"initFaceunity" isEqualToString:call.method]) {// Faceunity初始化
    //     [[FUManager shareManager] loadItems];
    // }else if ([@"filter_name" isEqualToString:call.method]) {// 滤镜
    //     int typeIndex = [NSString stringWithFormat:@"%@",call.arguments[@"filterNameType"]].intValue;
    //     [FUManager shareManager].selectedFilter = @[@"bailiang1",
    //                                                 @"bailiang2",
    //                                                 @"bailiang3",
    //                                                 @"bailiang4",
    //                                                 @"bailiang5",
    //                                                 @"bailiang6",
    //                                                 @"bailiang7",
    //                                                 @"fennen1",
    //                                                 @"fennen2",
    //                                                 @"fennen3",
    //                                                 @"fennen4",
    //                                                 @"fennen5",
    //                                                 @"fennen6",
    //                                                 @"fennen7",
    //                                                 @"fennen8",
    //                                                 @"gexing1",
    //                                                 @"gexing2",
    //                                                 @"gexing3",
    //                                                 @"gexing4",
    //                                                 @"gexing5",
    //                                                 @"gexing6",
    //                                                 @"gexing7",
    //                                                 @"gexing8",
    //                                                 @"gexing9",
    //                                                 @"gexing10",
    //                                                 @"heibai1",
    //                                                 @"heibai2",
    //                                                 @"heibai3",
    //                                                 @"heibai4",
    //                                                 @"heibai5",
    //                                                 @"lengsediao1",
    //                                                 @"lengsediao2",
    //                                                 @"lengsediao3",
    //                                                 @"lengsediao4",
    //                                                 @"lengsediao5",
    //                                                 @"lengsediao6",
    //                                                 @"lengsediao7",
    //                                                 @"lengsediao8",
    //                                                 @"lengsediao9",
    //                                                 @"lengsediao10",
    //                                                 @"lengsediao11",
    //                                                 @"nuansediao1",
    //                                                 @"nuansediao2",
    //                                                 @"nuansediao3",][typeIndex];
    // }else if ([@"filter_level" isEqualToString:call.method]) {// 滤镜level
    //     double level = [NSString stringWithFormat:@"%@",call.arguments[@"filter_level"]].doubleValue;
    //     [FUManager shareManager].selectedFilterLevel = level;
    // }else if ([@"color_level" isEqualToString:call.method]) {// 美白level
    //     double level = [NSString stringWithFormat:@"%@",call.arguments[@"color_level"]].doubleValue;
    //     [FUManager shareManager].whiteLevel = level;
    // }else if ([@"red_level" isEqualToString:call.method]) {// 红润level
    //     double level = [NSString stringWithFormat:@"%@",call.arguments[@"red_level"]].doubleValue;
    //     [FUManager shareManager].redLevel = level;
    // }else if ([@"blur" isEqualToString:call.method]) {// 指定磨皮程度,推荐取值范围为0.0~6.0
    //     int blur_type = [NSString stringWithFormat:@"%@",call.arguments[@"blur_type"]].intValue;
    //     double level = [NSString stringWithFormat:@"%@",call.arguments[@"blur_level"]].doubleValue;
    //     [FUManager shareManager].blurType = blur_type;
    //     if (blur_type == 0) {
    //         [FUManager shareManager].blurLevel_0 = level; //磨皮 (0.0 - 6.0)
    //     }else if (blur_type == 1){
    //         [FUManager shareManager].blurLevel_1 = level; //磨皮 (0.0 - 6.0)
    //     }else if (blur_type == 2){
    //         [FUManager shareManager].blurLevel_2 = level; //磨皮 (0.0 - 6.0)
    //     }
    // }else if ([@"skin_detect" isEqualToString:call.method]) {// 指定是否开启皮肤检测,该参数的推荐取值为0-1，0为无效果，1为开启皮肤检测，
    //     BOOL enable = [NSString stringWithFormat:@"%@",call.arguments[@"skin_detect"]].boolValue;
    //     [FUManager shareManager].skinDetectEnable = enable;
    // }else if ([@"nonshin_blur_scale" isEqualToString:call.method]) {// 指定开启皮肤检测后，非皮肤区域减轻磨皮导致模糊的程度。该参数范围是[0.0,1.0]
    //     double level = [NSString stringWithFormat:@"%@",call.arguments[@"nonshin_blur_scale"]].doubleValue;
    //     [FURenderer itemSetParam:0 withName:@"nonshin_blur_scale" value:@(level)];
    // }else if ([@"heavy_blur" isEqualToString:call.method]) {// 指定是否开启朦胧美肤功能。大于1开启朦胧美肤功能。
    //     double level = [NSString stringWithFormat:@"%@",call.arguments[@"heavy_blur"]].doubleValue;
    //     [FURenderer itemSetParam:0 withName:@"heavy_blur" value:@(level)];
    // }else if ([@"blur_blend_ratio" isEqualToString:call.method]) {// 指定磨皮结果和原图融合率。该参数的推荐取值范围为0-1。
    //     double level = [NSString stringWithFormat:@"%@",call.arguments[@"blur_blend_ratio"]].doubleValue;
    //     [FURenderer itemSetParam:0 withName:@"blur_blend_ratio" value:@(level)];
    // }else if ([@"eye_bright" isEqualToString:call.method]) {// 亮眼
    //     double level = [NSString stringWithFormat:@"%@",call.arguments[@"eye_bright"]].doubleValue;
    //     [FUManager shareManager].eyelightingLevel = level;
    // }else if ([@"tooth_whiten" isEqualToString:call.method]) {// 美牙
    //     double level = [NSString stringWithFormat:@"%@",call.arguments[@"tooth_whiten"]].doubleValue;
    //     [FUManager shareManager].beautyToothLevel = level;
    // }else if ([@"face_shape" isEqualToString:call.method]) {// 美型支持四种基本美型：女神、网红、自然、默认   一种高级美型：自定义。
    //     NSInteger level = [NSString stringWithFormat:@"%@",call.arguments[@"face_shape"]].integerValue;
    //     [FUManager shareManager].faceShape = level;
    // }else if ([@"face_shape_level" isEqualToString:call.method]) {// 用以控制变化到指定基础脸型的程度。
    //     double level = [NSString stringWithFormat:@"%@",call.arguments[@"face_shape_level"]].doubleValue;
    //     [FURenderer itemSetParam:0 withName:@"face_shape_level" value:@(level)];
    // }else if ([@"eye_enlarging" isEqualToString:call.method]) {// 用以控制眼睛大小。此参数受参数 face_shape_level 影响。
    //     double level = [NSString stringWithFormat:@"%@",call.arguments[@"eye_enlarging"]].doubleValue;
    //     [FUManager shareManager].enlargingLevel = level;
    // }else if ([@"cheek_thinning" isEqualToString:call.method]) {// 用以控制脸大小。此参数受参数 face_shape_level 影响。
    //     double level = [NSString stringWithFormat:@"%@",call.arguments[@"cheek_thinning"]].doubleValue;
    //     [FUManager shareManager].thinningLevel = level;
    // }else if ([@"intensity_forehead" isEqualToString:call.method]) {// 额头调整。
    //     double level = [NSString stringWithFormat:@"%@",call.arguments[@"intensity_forehead"]].doubleValue;
    //     [FUManager shareManager].foreheadLevel = level;
    // }else if ([@"intensity_chin" isEqualToString:call.method]) {// 下巴调整。
    //     double level = [NSString stringWithFormat:@"%@",call.arguments[@"intensity_chin"]].doubleValue;
    //     [FUManager shareManager].jewLevel = level;
    // }else if ([@"intensity_nose" isEqualToString:call.method]) {// 瘦鼻。
    //     double level = [NSString stringWithFormat:@"%@",call.arguments[@"intensity_nose"]].doubleValue;
    //     [FUManager shareManager].noseLevel = level;
    // }else if ([@"intensity_mouth" isEqualToString:call.method]) {// 嘴型。
    //     double level = [NSString stringWithFormat:@"%@",call.arguments[@"intensity_mouth"]].doubleValue;
    //     [FUManager shareManager].mouthLevel = level;
    // }else if ([@"destoryItems" isEqualToString:call.method]) {// 销毁道具。
    //     [[FUManager shareManager] destoryItems];
    // }
    else {
        result(FlutterMethodNotImplemented);
    }
}

// 发起通话
- (void)processVideoCallWithBuffer:(CMSampleBufferRef)sampleBuffer
{
    // CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    [[NIMAVChatSDK sharedSDK].netCallManager sendVideoSampleBuffer:sampleBuffer];
}

// 接听通话
- (void)responVideoCallWithBuffer:(CMSampleBufferRef)sampleBuffer
{
    // CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    [[NIMAVChatSDK sharedSDK].netCallManager sendVideoSampleBuffer:sampleBuffer];
}

- (void)sendMessage:(NIMMessageType)messageType args:(NSDictionary *)args
{
    NSDictionary *sessionDic = args[@"nimSession"];
    NSString *sessionID = sessionDic[@"sessionId"];
    int type = [NSString stringWithFormat:@"%@", args == nil ? @"0" : sessionDic[@"sessionType"]].intValue;
    NIMSessionType sessionType = NIMSessionTypeP2P;
    if (type == 3) {
        sessionType = NIMSessionTypeSuperTeam;
    } else {
        sessionType = type;
    }

    // 构造出具体会话
    NIMSession *session = [NIMSession session:sessionID type:sessionType];
    // 构造出具体消息
    NIMMessage *message = [[NIMMessage alloc] init];

    if (messageType == NIMMessageTypeText) {
        message.text = args[@"message"];
        NSError *error = nil;
        [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:&error];
    } else if (messageType == NIMMessageTypeImage) {
        // 获得图片附件对象
        NIMImageObject *object = [[NIMImageObject alloc] initWithFilepath:args[@"imagePath"]];
        message.messageObject = object;
        NSError *error = nil;
        [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:&error];
    } else if (messageType == NIMMessageTypeVideo) {
        NSString *path = args[@"videoPath"];
        // 获得视频附件对象
        NIMVideoObject *object = [[NIMVideoObject alloc] initWithSourcePath:path scene:NIMNOSSceneTypeMessage];
        message.messageObject = object;
        NSError *error = nil;
        [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:&error];
    } else if (messageType == NIMMessageTypeAudio) {
        // 获得音附件对象
        NIMAudioObject *object = [[NIMAudioObject alloc] initWithSourcePath:args[@"audioPath"] scene:NIMNOSSceneTypeMessage];
        message.messageObject = object;
        NSError *error = nil;
        [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:&error];
    } else if (messageType == NIMMessageTypeFile) {
        // 获得文件附件对象
        NIMFileObject *object = [[NIMFileObject alloc] initWithSourcePath:args[@"filePath"] scene:NIMNOSSceneTypeMessage];
        message.messageObject = object;
        NSError *error = nil;
        [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:&error];
    } else if (messageType == NIMMessageTypeLocation) {
        // 获得位置附件对象
        NSDictionary *locationDic = args[@"locationObject"];
        double latitude = [NSString stringWithFormat:@"%@", locationDic[@"latitude"]].doubleValue;
        double longitude = [NSString stringWithFormat:@"%@", locationDic[@"longitude"]].doubleValue;
        NSString *title = [NSString stringWithFormat:@"%@", locationDic[@"title"]];
        NIMLocationObject *object = [[NIMLocationObject alloc] initWithLatitude:latitude longitude:longitude title:title];
        message.messageObject = object;
        NSError *error = nil;
        [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:&error];
    } else if (messageType == NIMMessageTypeTip) {
        // 获得文件附件对象
        NIMTipObject *object = [[NIMTipObject alloc] init];
        message.messageObject = object;
        message.text = args[@"message"];
        NSError *error = nil;
        [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:&error];
    }
}

- (void)sendCustomMessage:(NSDictionary *)args
{
    NSString *sessionId = args[@"nimSession"][@"sessionId"];
    NSString *customEncodeString = args[@"customEncodeString"];
    NSString *apnsContent = args[@"apnsContent"];
    NIMMessage *message = [[NIMMessage alloc] init];
    NIMSession *session = [NIMSession session:sessionId type:NIMSessionTypeP2P];

    IMCustomAttachment *attachment = [[IMCustomAttachment alloc] init];
    attachment.customEncodeString = customEncodeString;
    // 获得自定义附件对象
    NIMCustomObject *object = [[NIMCustomObject alloc] init];
    object.attachment = attachment;
    message.messageObject = object;
    message.apnsContent = apnsContent;
    NSError *error = nil;
    [[[NIMSDK sharedSDK] chatManager] sendMessage:message toSession:session error:&error];
//    [[[NIMSDK sharedSDK] chatManager] sendMessage:message toSession:session completion:^(NSError * _Nullable error) {
//        NSLog(@"%@",error);
//    }];
}

/// 发送音频消息
/// @param filePath 文件地址
- (void)sendAudioMessage:(NSString *)filePath
{
    // 构造出具体会话
    NIMSession *session = [NIMSession session:self.sessionID type:NIMSessionTypeP2P];
    // 构造出具体消息
    NIMMessage *message = [[NIMMessage alloc] init];
    NIMAudioObject *object = [[NIMAudioObject alloc] initWithSourcePath:filePath];
    message.messageObject = object;
    NSError *error = nil;
    [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:&error];
}

// MARK: - NIMLoginManagerDelegate
- (void)onLogin:(NIMLoginStep)step
{
    if (self.eventSink) {
        NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInteger:NIMDelegateTypeOnLogin],
                               @"step": [NSNumber numberWithInteger:step] };
        self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
    }
}

// MARK: - FlutterStreamHandler
- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)eventSink
{
    self.eventSink = eventSink;
    return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments
{
    return nil;
}

// MARK: - NIMNetCallManagerDelegate
//被叫收到呼叫
- (void)onReceive:(UInt64)callID from:(NSString *)caller type:(NIMNetCallMediaType)type message:(NSString *)extendMessage
{
    NSDictionary *tempDic = [[NimDataManager shared] dictionaryWithJsonString:extendMessage];
    self.currentTimeStamp = tempDic[@"currentTimeStamp"];
    if (self.eventSink) {
        if (self.currentTimeStamp == nil) {
            
            NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeOnReceive],
                                   @"error": @"currentTimeStamp 不能为空"};
            self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
        } else {
            NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeOnReceive],
                                   @"callID": [NSString stringWithFormat:@"%llu", callID],
                                   @"caller": caller,
                                   @"currentTimeStamp": tempDic[@"currentTimeStamp"],
                                   @"type": [NSNumber numberWithInteger:type],
                                   @"extendMessage": extendMessage == nil ? @"" : extendMessage };
            self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
        }
        
    }
}

//主叫收到被叫响应
- (void)onResponse:(UInt64)callID from:(NSString *)callee accepted:(BOOL)accepted
{
    if (self.eventSink) {
        NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeOnResponse],
                               @"callID": [NSString stringWithFormat:@"%llu", callID],
                               @"callee": callee == nil ? @"" : callee,
                               @"accepted": [NSNumber numberWithBool:accepted] };
        self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
    }
}

//通话建立成功回调
- (void)onCallEstablished:(UInt64)callID
{
    //通话建立成功 开始计时 刷新UI

    if (self.eventSink) {
        NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeOnCallEstablished],
                               @"callID": [NSString stringWithFormat:@"%llu", callID] };
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
        });
    }
}

//收到对方挂断电话
- (void)onHangup:(UInt64)callID by:(NSString *)user
{
    if (self.eventSink) {
        NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeOnHangup],
                               @"callID": [NSString stringWithFormat:@"%llu", callID],
                               @"user": user == nil ? @"" : user };
        self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
    }
}

//通话异常断开回调
/**
 通话异常断开

 @param callID call id
 @param error 断开的原因，如果是 nil 表示正常退出
 */
- (void)onCallDisconnected:(UInt64)callID withError:(NSError *)error
{
    if (self.eventSink) {
        NSString *msg = error.userInfo[@"NSLocalizedDescription"] == nil ? @"通话异常" : error.userInfo[@"NSLocalizedDescription"];
        NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeOnCallDisconnected],
                               @"callID": [NSString stringWithFormat:@"%llu", callID],
                               @"error": msg };
        self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
    }
}

- (void)onLocalDisplayviewReady:(UIView *)displayView
{
    NSLog(@"onLocalDisplayviewReady == %@", displayView);
    NSLog(@"onLocalDisplayviewReady  currentTimeStamp == %@",self.currentTimeStamp);
    if (displayView.bounds.size.width == 0) {
        [_registrar registerViewFactory:[[FlutterNimViewFactory alloc] initWithMessenger:[_registrar messenger] displayView:displayView] withId:[NSString stringWithFormat:@"LocalDisplayView-%@", self.currentTimeStamp]];
    }
}

- (void)onRemoteDisplayviewReady:(UIView *)displayView user:(NSString *)user
{
    NSLog(@"onRemoteDisplayviewReady == %@, user == %@", displayView, user);
    NSLog(@"onRemoteDisplayviewReady  currentTimeStamp == %@",self.currentTimeStamp);

    if (displayView.bounds.size.width == 0) {
        [_registrar registerViewFactory:[[FlutterNimViewFactory alloc] initWithMessenger:[_registrar messenger] displayView:displayView] withId:[NSString stringWithFormat:@"RemoteDisplayView-%@", self.currentTimeStamp]];
    }
}

- (void)onControl:(UInt64)callID from:(NSString *)user type:(NIMNetCallControlType)control
{
    if (self.eventSink) {
        NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeOnControl],
                               @"callID": [NSString stringWithFormat:@"%llu", callID],
                               @"formUser": user,
                               @"controlType": [NSNumber numberWithInteger:control] };
        self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
    }
}

// MARK: - NIMConversationManagerDelegate

/**
 *  增加最近会话的回调
 *
 *  @param recentSession    最近会话
 *  @param totalUnreadCount 目前总未读数
 *  @discussion 当新增一条消息，并且本地不存在该消息所属的会话时，会触发此回调。
 */
- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount
{
    if (self.eventSink) {
        NSMutableDictionary *tempDic = [recentSession mj_keyValues];
        tempDic[@"lastMessage"] = [[NimDataManager shared] handleNIMMessage:recentSession.lastMessage];
        NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeDidAddRecentSession],
                               @"totalUnreadCount": [NSNumber numberWithInteger:totalUnreadCount],
                               @"recentSession": tempDic };
        self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
    }
}

/**
 *  最近会话修改的回调
 *
 *  @param recentSession    最近会话
 *  @param totalUnreadCount 目前总未读数
 *  @discussion 触发条件包括: 1.当新增一条消息，并且本地存在该消息所属的会话。
 *                          2.所属会话的未读清零。
 *                          3.所属会话的最后一条消息的内容发送变化。(例如成功发送后，修正发送时间为服务器时间)
 *                          4.删除消息，并且删除的消息为当前会话的最后一条消息。
 */
- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount
{
    if (self.eventSink) {
        NSMutableDictionary *tempDic = [recentSession mj_keyValues];
        tempDic[@"lastMessage"] = [[NimDataManager shared] handleNIMMessage:recentSession.lastMessage];
        NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeDidUpdateRecentSession],
                               @"totalUnreadCount": [NSNumber numberWithInteger:totalUnreadCount],
                               @"recentSession": tempDic };
        self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
    }
}

/**
 *  删除最近会话的回调
 *
 *  @param recentSession    最近会话
 *  @param totalUnreadCount 目前总未读数
 */
- (void)didRemoveRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount
{
    if (self.eventSink) {
        NSMutableDictionary *tempDic = [recentSession mj_keyValues];
        tempDic[@"lastMessage"] = [[NimDataManager shared] handleNIMMessage:recentSession.lastMessage];

        NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeDidRemoveRecentSession],
                               @"totalUnreadCount": [NSNumber numberWithInteger:totalUnreadCount],
                               @"recentSession": tempDic };
        self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
    }
}

// MARK: - NIMMediaManagerDelegate

/// 开始录音
/// @param filePath 路径
- (void)recordAudio:(NSString *)filePath didBeganWithError:(NSError *)error
{
    self.recordTime = 0;
}

/// 录音中
/// @param currentTime 录音时长
- (void)recordAudioProgress:(NSTimeInterval)currentTime
{
    self.recordTime = currentTime;
}

/// 取消录音
- (void)recordAudioDidCancelled
{
    self.recordTime = 0;
}

- (void)recordAudio:(NSString *)filePath didCompletedWithError:(NSError *)error
{
    if (error == nil && filePath != nil) {
        if (self.recordTime > 1) {
            [self sendAudioMessage:filePath];
        } else {
            NSLog(@"说话时间太短");
            if (self.eventSink) {
                NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeRecordAudioComplete],
                                       @"msg": @"说话时间太短" };
                self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
            }
        }
    }
}

- (void)recordAudioInterruptionBegin
{
    [[[NIMSDK sharedSDK] mediaManager] cancelRecord];
}

// MARK: - NIMChatManagerDelegate

/**
 *  收到消息回执
 *
 *  @param receipts 消息回执数组
 *  @discussion 当上层收到此消息时所有的存储和 model 层业务都已经更新，只需要更新 UI 即可。
 */
- (void)onRecvMessageReceipts:(NSArray<NIMMessageReceipt *> *)receipts
{
    if (self.eventSink) {
        NSMutableArray *receiptsArray = [NSObject mj_keyValuesArrayWithObjectArray:receipts];
        NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeOnRecvMessageReceipts],
                               @"receipts": receiptsArray };
        self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
    }
}

/**
*  即将发送消息回调
*  @discussion 因为发消息之前可能会有个准备过程,所以需要在收到这个回调时才将消息加入到 Datasource 中
*  @param message 当前发送的消息
*/
- (void)willSendMessage:(NIMMessage *)message
{
    if (self.eventSink) {
        
        NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeWillSendMessage],
                               @"message": [[NimDataManager shared] handleNIMMessage:message] };
        self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
    }
}

/**
 *  上传资源文件成功的回调
 *  @discussion 对于需要上传资源的消息(图片，视频，音频等)，SDK 将在上传资源成功后通过这个接口进行回调，上层可以在收到该回调后进行推送信息的重新配置 (APNS payload)
 *  @param urlString 当前消息资源获得的 url 地址
 *  @param message 当前发送的消息
 */
- (void)uploadAttachmentSuccess:(NSString *)urlString
                     forMessage:(NIMMessage *)message
{
    if (self.eventSink) {
        NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeUploadAttachmentSuccess],
                               @"urlString": urlString,
                               @"message": [[NimDataManager shared] handleNIMMessage:message] };
        self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
    }
}

/**
 *  发送消息进度回调
 *
 *  @param message  当前发送的消息
 *  @param progress 进度
 */
- (void)sendMessage:(NIMMessage *)message
           progress:(float)progress
{
    if (self.eventSink) {
        NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeSendMessageProcess],
                               @"progress": [NSNumber numberWithFloat:progress],
                               @"message": [[NimDataManager shared] handleNIMMessage:message] };
        self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
    }
}

/**
 *  发送消息完成回调
 *
 *  @param message 当前发送的消息
 *  @param error   失败原因,如果发送成功则error为nil
 */
- (void)sendMessage:(NIMMessage *)message
    didCompleteWithError:(nullable NSError *)error
{
    if (self.eventSink) {
        if (error == nil) {
            NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeSendMessageComplete],
                                   @"msg": @"消息发送完成",
                                   @"message": [[NimDataManager shared] handleNIMMessage:message] };
            self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);

            if (message.messageType == NIMMessageTypeVideo || message.messageType == NIMMessageTypeCustom) {
                NSDictionary *dict = [[NimDataManager shared] handleNIMMessage:message];
                NSDictionary *tempDic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeOnRecvMessages],
                                           @"message": @[dict] };
                self.eventSink([[NimDataManager shared] dictionaryToJson:tempDic]);
            }
        } else {
            NSString *msg = error.userInfo[@"NSLocalizedDescription"] == nil ? @"消息发送失败" : error.userInfo[@"NSLocalizedDescription"];

            NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeSendMessageComplete],
                                   @"error": @{ @"msg": msg, @"errCode": [NSNumber numberWithInteger:error.code] },
                                   @"message": [[NimDataManager shared] handleNIMMessage:message] == nil ? @"" : [[NimDataManager shared] handleNIMMessage:message] };
            self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
        }
    }
}

/**
 *  收到消息回调
 *
 *  @param messages 消息列表,内部为NIMMessage
 */
- (void)onRecvMessages:(NSArray<NIMMessage *> *)messages
{
    if (self.eventSink) {
        NSMutableArray *array = [NSMutableArray array];
        for (NIMMessage *message in messages) {
            NSDictionary *dic = [[NimDataManager shared] handleNIMMessage:message];
            [array addObject:dic];
        }
        NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeOnRecvMessages],
                               @"message": array };
        self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
    }
}

/**
 *  收到消息被撤回的通知
 *
 *  @param notification 被撤回的消息信息
 *  @discusssion 云信在收到消息撤回后，会先从本地数据库中找到对应消息并进行删除，之后通知上层消息已删除
 */
- (void)onRecvRevokeMessageNotification:(NIMRevokeMessageNotification *)notification
{
    if (self.eventSink) {
        NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeOnRecvRevokeMessageNotification],
                               @"notification": notification.mj_keyValues };
        self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
    }
}

/**
 *  收取消息附件回调
 *  @param message  当前收取的消息
 *  @param progress 进度
 *  @discussion 附件包括:图片,视频的缩略图,语音文件
 */
- (void)fetchMessageAttachment:(NIMMessage *)message
                      progress:(float)progress
{
    if (self.eventSink) {
        NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeFetchMessageAttachmentProcess],
                               @"progress": [NSNumber numberWithFloat:progress],
                               @"message": [[NimDataManager shared] handleNIMMessage:message] };
        self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
    }
}

/**
 *  收取消息附件完成回调
 *
 *  @param message 当前收取的消息
 *  @param error   错误返回,如果收取成功,error为nil
 */
- (void)fetchMessageAttachment:(NIMMessage *)message
          didCompleteWithError:(nullable NSError *)error
{
    if (self.eventSink) {
        if (error == nil) {
            NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeFetchMessageAttachmentComplete],
                                   @"msg": @"收取消息附件完成",
                                   @"message": [[NimDataManager shared] handleNIMMessage:message] };
            self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
        } else {
            NSString *msg = error.userInfo[@"NSLocalizedDescription"] == nil ? @"收取消息附件失败" : error.userInfo[@"NSLocalizedDescription"];

            NSDictionary *dic = @{ @"delegateType": [NSNumber numberWithInt:NIMDelegateTypeFetchMessageAttachmentComplete],
                                   @"error": @{ @"msg": msg, @"errCode": [NSNumber numberWithInteger:error.code] },
                                   @"message": [[NimDataManager shared] handleNIMMessage:message] };
            self.eventSink([[NimDataManager shared] dictionaryToJson:dic]);
        }
    }
}

// MARK: - custom

- (void)getValue:(NSDictionary *)dict key:(NSString *)key:(void (^)(id result))block
{
    id value = dict[key];
    if (value == nil || [value isEqual:[NSNull null]] || [value isEqualToString:@""]) {
        return;
    }
    block(value);
}

- (NSMutableArray *)sessions
{
    if (!_sessions) {
        _sessions = [NSMutableArray array];
    }
    return _sessions;
}

- (NSMutableArray *)messages
{
    if (!_messages) {
        _messages = [NSMutableArray array];
    }
    return _messages;
}

- (void)dealloc
{
    [[[NIMAVChatSDK sharedSDK] netCallManager] removeDelegate:self];
    [[[NIMSDK sharedSDK] loginManager] removeDelegate:self];
    [[[NIMSDK sharedSDK] mediaManager] removeDelegate:self];
    [[[NIMSDK sharedSDK] chatManager] removeDelegate:self];
}

@end
