//
//  NimDataManager.m
//  flutter_nimsdk
//
//  Created by HyBoard on 2019/11/4.
//

#import "NimDataManager.h"
#import <MJExtension/MJExtension.h>
#import "IMCustomAttachment.h"

@implementation NimDataManager

+ (instancetype)shared {
    
    static NimDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NimDataManager alloc] init];
    });
    return manager;
}

- (NSMutableDictionary<NSString *, id> *)configSessionWith:(NIMRecentSession *)session {
    
    NSMutableDictionary *tempDic = [session mj_keyValues];
    
    NSString *avatarUrl = nil;
    NSString *thumbAvatarUrl = nil;
    NSString *nickname = nil;
    if (session.session.sessionType == NIMSessionTypeTeam) {
        
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:session.session.sessionId];
        avatarUrl = team.avatarUrl;
        thumbAvatarUrl = team.thumbAvatarUrl;
        nickname = team.teamName;
    } else if (session.session.sessionType == NIMSessionTypeSuperTeam) {
        
        NIMTeam *team = [[NIMSDK sharedSDK].superTeamManager teamById:session.session.sessionId];
        avatarUrl = team.avatarUrl;
        thumbAvatarUrl = team.thumbAvatarUrl;
        nickname = team.teamName;
    } else {
    
        NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:session.session.sessionId];
        NIMUserInfo *userInfo = user.userInfo;
        avatarUrl = userInfo.avatarUrl;
        thumbAvatarUrl = userInfo.thumbAvatarUrl;
        nickname = userInfo.nickName;
        
        
    }
    tempDic[@"avatarUrl"] = avatarUrl == nil ? @"" : avatarUrl;
    tempDic[@"thumbAvatarUrl"] = thumbAvatarUrl == nil ? @"" : thumbAvatarUrl;
    tempDic[@"nickName"] = nickname == nil ? @"" : nickname;
    
    return tempDic;
}

-(NSString*)dictionaryToJson:(NSDictionary *)dic {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return @{};
    }
    return dic;
}

- (NSString *)getCurrentTimeStamp {
    
    NSDate *date = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([date timeIntervalSince1970]*1000)];
    return timeSp;
}


- (NSDictionary *)handleNIMMessage:(NIMMessage *)message {
    
    NSMutableDictionary *tempDic = [message mj_keyValuesWithIgnoredKeys:@[@"messageObject"]];
    if (message.messageType == NIMMessageTypeText) {
        
    }else if (message.messageType == NIMMessageTypeImage) {
        
        NIMImageObject *imgObj = (NIMImageObject *)message.messageObject;
        NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
        contentDic[@"url"] = imgObj.url == nil ? @"" : imgObj.url;
        contentDic[@"thumbUrl"] = imgObj.thumbUrl == nil ? @"" : imgObj.thumbUrl;
        contentDic[@"thumbPath"] = imgObj.thumbPath == nil ? @"" : imgObj.thumbPath;
        contentDic[@"path"] = imgObj.path == nil ? @"" : imgObj.path;
        contentDic[@"width"] = [NSNumber numberWithFloat:imgObj.size.width];
        contentDic[@"height"] = [NSNumber numberWithFloat:imgObj.size.height];
        tempDic[@"messageObject"] = contentDic;
    
    }else if (message.messageType == NIMMessageTypeNotification) {
        
        NIMNotificationObject *noti = (NIMNotificationObject *)message.messageObject;
        NIMNetCallNotificationContent *content = (NIMNetCallNotificationContent *)noti.content;
        
        NSMutableDictionary *contentDic = content.mj_keyValues;
        contentDic[@"messageObject"] = @"";
        contentDic[@"notificationType"] = [NSNumber numberWithInteger:noti.notificationType];
        
        tempDic[@"messageObject"] = contentDic;
        
    }else if (message.messageType == NIMMessageTypeAudio) {
        
        NIMAudioObject *audio = (NIMAudioObject *)message.messageObject;
        NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
        contentDic[@"url"] = audio.url == nil ? @"" : audio.url;
        contentDic[@"path"] = audio.path == nil ? @"" : audio.path;
        contentDic[@"duration"] = [NSNumber numberWithInteger:audio.duration];
        contentDic[@"isPlayed"] = [NSNumber numberWithBool:message.isPlayed];
        tempDic[@"messageObject"] = contentDic;

    }else if (message.messageType == NIMMessageTypeVideo) {
        
        NIMVideoObject *video = (NIMVideoObject *)message.messageObject;
        NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
        contentDic[@"url"] = video.url == nil ? @"" : video.url;
        contentDic[@"coverUrl"] = video.coverUrl == nil ? @"" : video.coverUrl;
        contentDic[@"path"] = video.path == nil ? @"" : video.path;
        contentDic[@"duration"] = [NSNumber numberWithInteger:video.duration];
        contentDic[@"width"] = [NSNumber numberWithFloat:video.coverSize.width];
        contentDic[@"height"] = [NSNumber numberWithFloat:video.coverSize.height];
        tempDic[@"messageObject"] = contentDic;
        
    }else if (message.messageType == NIMMessageTypeLocation) {
        
        NIMLocationObject *location = (NIMLocationObject *)message.messageObject;
        location.message.messageObject = nil;
        NSMutableDictionary *contentDic = [location mj_keyValues];
        
        tempDic[@"messageObject"] = contentDic;

    }else if (message.messageType == NIMMessageTypeFile) {
        
        NIMFileObject *file = (NIMFileObject *)message.messageObject;
        file.message.messageObject = nil;
        NSMutableDictionary *contentDic = [file mj_keyValues];
        
        tempDic[@"messageObject"] = contentDic;

    }else if (message.messageType == NIMMessageTypeTip) {
        
        NIMTipObject *tip = (NIMTipObject *)message.messageObject;
        tip.message.messageObject = nil;
        NSMutableDictionary *contentDic = [tip mj_keyValues];
        
        tempDic[@"messageObject"] = contentDic;

    }else if (message.messageType == NIMMessageTypeRobot) {
        
        NIMRobotObject *robot = (NIMRobotObject *)message.messageObject;
        robot.message.messageObject = nil;
        NSMutableDictionary *contentDic = [robot mj_keyValues];
        
        tempDic[@"messageObject"] = contentDic;

    }else if (message.messageType == NIMMessageTypeCustom) {
        
        NIMCustomObject *custom = (NIMCustomObject *)message.messageObject;
        IMCustomAttachment *attachment = (IMCustomAttachment *)custom.attachment;
//        custom.attachment = nil;
        NSMutableDictionary *contentDic = [custom.message mj_keyValuesWithIgnoredKeys:@[@"messageObject"]];
        tempDic[@"messageObject"] = contentDic;
        tempDic[@"attachment"] = [attachment encodeAttachment];
        
    }
    
    if (tempDic == nil) {
        tempDic = [NSMutableDictionary dictionaryWithDictionary:@{}];
    }
    
    return tempDic;
}


@end
