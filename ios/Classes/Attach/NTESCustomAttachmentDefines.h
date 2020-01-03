//
//  NTESCustomAttachmentDefines.h
//  NIM
//
//  Created by amao on 7/2/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#ifndef NIM_NTESCustomAttachmentTypes_h
#define NIM_NTESCustomAttachmentTypes_h


@class NIMKitBubbleStyleObject;

typedef NS_ENUM(NSInteger,NTESCustomMessageType){
    CustomMessageTypeJanKenPon  = 1, //剪子石头布
    CustomMessageTypeSnapchat   = 2, //阅后即焚
    CustomMessageTypeChartlet   = 3, //贴图表情
    CustomMessageTypeWhiteboard = 4, //白板会话
    CustomMessageTypeRedPacket  = 5, //红包消息
    CustomMessageTypeRedPacketTip = 6, //红包提示消息
    
    //7.求赠礼物8.赠送礼物9.赠送爱豆10.求赠爱豆
    CustomMessageTypeIncomeGift = 7,
    CustomMessageTypeSendGift = 8,
    CustomMessageTypeSendBean = 9,
    CustomMessageTypeIncomeBean = 10,

    
    
    CustomMessageTypeSnapchatVideo   = 13, //阅后即焚视频
    CustomMessageTypeLookSnapchatImage   = 20, //查看阅后即焚图片
    CustomMessageTypeLookSnapchatVideo   = 21, //查看阅后即焚视频

    CustomMessageTypeMultiRetweet = 15,//多条消息合并转发
};


#define CMType             @"type"
#define CMData             @"data"
#define CMValue            @"value"
#define CMFlag             @"flag"
#define CMURL              @"url"
#define CMMD5              @"md5"
#define CMDisplayName      @"displayName"
#define CMPath             @"path"
#define CMSize             @"size"
#define CMDuration         @"duration"
#define CMHeight           @"height"
#define CMWidth            @"width"
#define CMExtension        @"extension"
#define CMGiftId           @"giftId"
#define CMGiftImg          @"giftImg"
#define CMGiftName         @"giftName"
#define CMPrice            @"price"

#define CMFIRE             @"fired"        //阅后即焚消息是否被焚毁
#define CMCatalog          @"catalog"      //贴图类别
#define CMChartlet         @"chartlet"     //贴图表情ID
//红包
#define CMRedPacketTitle   @"title"        //红包标题
#define CMRedPacketContent @"content"      //红包内容
#define CMRedPacketId      @"redPacketId"  //红包ID
//红包详情
#define CMRedPacketSendId     @"sendPacketId"
#define CMRedPacketOpenId     @"openPacketId"
#define CMRedPacketDone       @"isGetDone"

//合并转发
#define CMCompressed       @"compressed" //合并转发文件是否压缩
#define CMEncrypted        @"encrypted"  //合并转发文件是否加密
#define CMPassword         @"password"   //合并转发文件解密密钥
#define CMMessageAbstract  @"messageAbstract" //合并转发消息
#define CMMessageAbstractSender   @"sender" //合并转发消息-发送者
#define CMMessageAbstractContent  @"message" //合并转发消息-信息
#define CMSessionName   @"sessionName" //会话名称
#define CMSessionId   @"sessionId" //会话名称

#endif


#import <NIMSDK/NIMSDK.h>

@protocol NTESCustomAttachmentInfo <NSObject>

@optional

- (NSString *)cellContent:(NIMMessage *)message;

- (CGSize)contentSize:(NIMMessage *)message cellWidth:(CGFloat)width;

- (UIEdgeInsets)contentViewInsets:(NIMMessage *)message;

- (NSString *)formatedMessage;

- (UIImage *)showCoverImage;

- (BOOL)shouldShowAvatar;

- (void)setShowCoverImage:(UIImage *)image;

- (BOOL)canBeRevoked;

- (BOOL)canBeForwarded;

@end
