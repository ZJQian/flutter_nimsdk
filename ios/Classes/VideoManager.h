//
//  VideoManager.h
//  flutter_nimsdk
//
//  Created by HyBoard on 2019/12/18.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoManager : NSObject


+ (instancetype)sharedManager;



/// mov格式转换为MP4格式
/// @param movUrl 视频url
- (void)mov2mp4:(NSURL *)movUrl completed:(void(^)(AVAssetExportSessionStatus status, NSString *videoPath))completed;

@end

NS_ASSUME_NONNULL_END
