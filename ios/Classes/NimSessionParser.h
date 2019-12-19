//
//  NimSessionParser.h
//  flutter_nimsdk
//
//  Created by HyBoard on 2019/12/18.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>


NS_ASSUME_NONNULL_BEGIN

@interface NimSessionParser : NSObject

+ (instancetype)shared;

- (NSArray *)handleRecentSessions:(NSArray <NIMRecentSession *>*)recentSessions users:(NSArray <NIMUser *>*)users;

@end

NS_ASSUME_NONNULL_END
