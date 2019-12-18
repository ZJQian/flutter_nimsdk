//
//  VideoManager.m
//  flutter_nimsdk
//
//  Created by HyBoard on 2019/12/18.
//

#import "VideoManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "NimDataManager.h"


@implementation VideoManager


+ (instancetype)sharedManager
{
    static VideoManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[VideoManager alloc] init];
    });
    return manager;
}

- (void)mov2mp4:(NSURL *)movUrl completed:(void (^)(AVAssetExportSessionStatus, NSString * _Nonnull))completed
{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    /**
     AVAssetExportPresetMediumQuality 表示视频的转换质量，
     */
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        
        
        NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dataFilePath = [docsdir stringByAppendingPathComponent:@"ml"]; // 在Document目录下创建 "ml" 文件夹

        NSFileManager *fileManager = [NSFileManager defaultManager];

        BOOL isDir = NO;

        // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
        BOOL existed = [fileManager fileExistsAtPath:dataFilePath isDirectory:&isDir];

        if (!(isDir && existed)) {
            // 在Document目录下创建一个ml目录
            [fileManager createDirectoryAtPath:dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        //转换完成保存的文件路径
        NSString * resultPath = [dataFilePath stringByAppendingFormat:@"%@.mp4",[[NimDataManager shared]getCurrentTimeStamp]];

        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        
        //要转换的格式，这里使用 MP4
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        //转换的数据是否对网络使用优化
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        //异步处理开始转换
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         
         {
             //转换状态监控
             switch (exportSession.status) {
                 case AVAssetExportSessionStatusUnknown:
                     completed(exportSession.status,@"");
                     break;
                     
                 case AVAssetExportSessionStatusWaiting:
                     completed(exportSession.status,@"");
                     break;
                     
                 case AVAssetExportSessionStatusExporting:
                     completed(exportSession.status,@"");
                     break;
                 case AVAssetExportSessionStatusFailed:
                     completed(exportSession.status,@"");
                     break;
                 case AVAssetExportSessionStatusCancelled:
                     completed(exportSession.status,@"");
                     break;
                  
                 case AVAssetExportSessionStatusCompleted:
                 {
                     //转换完成
                     completed(exportSession.status,resultPath);
                     break;
                 }
             }
             
         }];
        
    }

}


@end
