//
//  NimSessionParser.m
//  flutter_nimsdk
//
//  Created by HyBoard on 2019/12/18.
//

#import "NimSessionParser.h"
#import "NimDataManager.h"

@implementation NimSessionParser


+ (instancetype)shared
{
    static NimSessionParser *parser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parser = [[NimSessionParser alloc] init];
    });
    return parser;
}

- (NSArray *)handleRecentSessions:(NSArray <NIMRecentSession *>*)recentSessions users:(NSArray <NIMUser *>*)users
{

    NSMutableArray *sessionDictArray = [NSMutableArray array];
    for (int i = 0; i<recentSessions.count; i++) {
        
        NIMRecentSession *recentSession = recentSessions[i];
        NIMUser *user = users[i];
        NSMutableDictionary *sessionDict = [[NimDataManager shared] configSessionWith:recentSession];
        sessionDict[@"lastMessage"] = [[NimDataManager shared] handleNIMMessage:recentSession.lastMessage];
        
        sessionDict[@"nickName"] = user.userInfo.nickName;
        sessionDict[@"avatarUrl"] = user.userInfo.avatarUrl;
        sessionDict[@"thumbAvatarUrl"] = user.userInfo.thumbAvatarUrl;
        [sessionDictArray addObject:sessionDict];
    }
    
    return sessionDictArray;
}


//static func handleRecentSessionsData(recentSessions: [NIMRecentSession]) -> String {
//    var result = ""
//
//    var sessionDictArray = [[String: Any]]()
//    for recentSession in recentSessions {
//        var sessionDict = [String: Any]()
//        sessionDict["sessionId"] = recentSession.session!.sessionId
//        sessionDict["unreadCount"] = recentSession.unreadCount
//        sessionDict["timestamp"] = recentSession.timestamp
//
//        if let lastMessage = recentSession.lastMessage {
//            let lastMessageDict = getMessageDict(message: lastMessage)
//            sessionDict["messageContent"] = messageContent(lastMessage: lastMessage)
//            sessionDict["lastMessage"] = lastMessageDict
//        }
//
//        var userInfoDict = [String: Any]()
//        userInfoDict["nickname"] = recentSession.userInfo.nickName
//        userInfoDict["avatarUrl"] = recentSession.userInfo.avatarUrl
//        userInfoDict["userExt"] = recentSession.userInfo.ext
//        sessionDict["userInfo"] = userInfoDict
//
//        sessionDictArray.append(sessionDict)
//    }
//
//    let dict: [String: Any] = ["recentSessions": sessionDictArray]
//
//    if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//        let jsonString = String(data: data, encoding: String.Encoding.utf8) {
//        result = jsonString
//    }
//
//    return result
//}

@end
