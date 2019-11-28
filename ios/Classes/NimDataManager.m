//
//  NimDataManager.m
//  flutter_nimsdk
//
//  Created by HyBoard on 2019/11/4.
//

#import "NimDataManager.h"
#import <MJExtension/MJExtension.h>

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
    if (session.session.sessionType == NIMSessionTypeTeam) {
        
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:session.session.sessionId];
        avatarUrl = team.avatarUrl;
        thumbAvatarUrl = team.thumbAvatarUrl;
    } else if (session.session.sessionType == NIMSessionTypeSuperTeam) {
        
        NIMTeam *team = [[NIMSDK sharedSDK].superTeamManager teamById:session.session.sessionId];
        avatarUrl = team.avatarUrl;
        thumbAvatarUrl = team.thumbAvatarUrl;
    } else {
        
        NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:session.session.sessionId];
        NIMUserInfo *userInfo = user.userInfo;
        avatarUrl = userInfo.avatarUrl;
        thumbAvatarUrl = userInfo.thumbAvatarUrl;
        
    }
    tempDic[@"avatarUrl"] = avatarUrl == nil ? @"" : avatarUrl;
    tempDic[@"thumbAvatarUrl"] = thumbAvatarUrl == nil ? @"" : thumbAvatarUrl;
    
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
        return nil;
    }
    return dic;
}

- (NSString *)getCurrentTimeStamp {
    
    NSDate *date = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([date timeIntervalSince1970]*1000)];
    return timeSp;
}


@end
