//
//  NTESSnapchatVideoAttachment.h
//  flutter_nimsdk
//
//  Created by HyBoard on 2020/1/3.
//

#import <Foundation/Foundation.h>
#import "NTESCustomAttachmentDefines.h"


NS_ASSUME_NONNULL_BEGIN

@interface NTESSnapchatVideoAttachment : NSObject<NIMCustomAttachment,NTESCustomAttachmentInfo>


@property (nonatomic,copy)  NSString    *md5;

@property (nonatomic,copy)  NSString    *url;

@property (nonatomic,assign) BOOL isFired; //是否焚毁

@property (nonatomic,strong) UIImage *showCoverImage;

/**
 *
 */
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *size;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *height;
@property (nonatomic, copy) NSString *width;
@property (nonatomic, copy) NSString *extension;



- (void)setImage:(UIImage *)image;

- (void)setImageFilePath:(NSString *)path;

- (NSString *)filepath;


@end

NS_ASSUME_NONNULL_END
