//
//  NimDataManager.h
//  flutter_nimsdk
//
//  Created by HyBoard on 2019/11/4.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface NimDataManager : NSObject

+ (instancetype)shared;


/**
 处理会话信息

 @param session <#session description#>
 @return <#return value description#>
 */
- (NSMutableDictionary *)configSessionWith:(NIMRecentSession *)session;

/**
 字典转字符串

 @param dic <#dic description#>
 @return <#return value description#>
 */
-(NSString*)dictionaryToJson:(NSDictionary *)dic;


/**
 字符串转字典

 @param jsonString <#jsonString description#>
 @return <#return value description#>
 */
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
