//
//  NTESSnapchatVideoAttachment.m
//  flutter_nimsdk
//
//  Created by HyBoard on 2020/1/3.
//

#import "NTESSnapchatVideoAttachment.h"
#import "NTESFileLocationHelper.h"
#import "NSData+NTES.h"
//#import "NTESSessionUtil.h"

@interface NTESSnapchatVideoAttachment()

@property (nonatomic,assign) BOOL isFromMe;

@end

@implementation NTESSnapchatVideoAttachment


- (void)setImage:(UIImage *)image
{
    NSData *data = UIImageJPEGRepresentation(image, 0.7);
    NSString *md5= [data MD5String];
    self.md5 = md5;
    
    [data writeToFile:[self filepath] atomically:YES];
}

- (void)setImageFilePath:(NSString *)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSData *jpgData = nil;
        if ([path.pathExtension.uppercaseString isEqualToString:@"HEIC"]) {
            CIImage *ciImage = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:path]];
                                CIContext *context = [CIContext context];
            jpgData = [context JPEGRepresentationOfImage:ciImage colorSpace:ciImage.colorSpace options:@{}];
        } else {
            jpgData = [NSData dataWithContentsOfFile:path];
        }
 
        self.md5 =  [jpgData MD5String];

        [jpgData writeToFile:[self filepath]
               atomically:YES];
     }
}

- (void)setIsFired:(BOOL)isFired{
    if (_isFired != isFired) {
        _isFired = isFired;
        [self updateCover];
    }
}


- (NSString *)filepath
{
    NSString *filename = [_md5 stringByAppendingFormat:@".%@",ImageExt];
    return [NTESFileLocationHelper filepathForImage:filename];
}


- (NSString *)cellContent:(NIMMessage *)message{
    return @"NTESSessionSnapchatContentView";
}

- (CGSize)contentSize:(NIMMessage *)message cellWidth:(CGFloat)width{
    self.isFromMe = message.isOutgoingMsg;
    CGSize size = self.showCoverImage.size;
    CGFloat customSnapMessageImageRightToText = 5;
    return CGSizeMake(size.width + customSnapMessageImageRightToText, size.height);
}

- (UIEdgeInsets)contentViewInsets:(NIMMessage *)message
{
    CGFloat bubblePaddingForImage    = 3.f;
    CGFloat bubbleArrowWidthForImage = -4.f;
    if (message.isOutgoingMsg) {
        return  UIEdgeInsetsMake(bubblePaddingForImage,bubblePaddingForImage,bubblePaddingForImage,bubblePaddingForImage + bubbleArrowWidthForImage);
    }else{
        return  UIEdgeInsetsMake(bubblePaddingForImage,bubblePaddingForImage + bubbleArrowWidthForImage, bubblePaddingForImage,bubblePaddingForImage);
    }
}

- (void)setIsFromMe:(BOOL)isFromMe{
    if (_isFromMe != isFromMe) {
        _isFromMe = isFromMe;
        [self updateCover];
    }
}

- (BOOL)canBeForwarded
{
    return NO;
}

- (BOOL)canBeRevoked
{
    return YES;
}



#pragma NIMCustomAttachment
- (NSString *)encodeAttachment
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [dict setObject:@(CustomMessageTypeSnapchatVideo) forKey:CMType];
    [data setObject:_md5?_md5:@"" forKey:CMMD5];
    [data setObject:@(_isFired) forKey:CMFIRE];
    [data setObject:_displayName ? _displayName : @"" forKey:CMDisplayName];
    [data setObject:_path ? _path : @"" forKey:CMPath];
    [data setObject:_size ? _size : @"0" forKey:CMSize];
    [data setObject:_duration ? _duration : @"0" forKey:CMDuration];
    [data setObject:_width ? _width : @"0" forKey:CMWidth];
    [data setObject:_height ? _height : @"0" forKey:CMHeight];
    [data setObject:_extension ? _extension : @"" forKey:CMExtension];
    if ([_url length])
    {
        [data setObject:_url forKey:CMURL];
    }
    [dict setObject:data forKey:CMData];

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:nil];
    
    return [[NSString alloc] initWithData:jsonData
                                 encoding:NSUTF8StringEncoding];
}


#pragma mark - 实现文件上传需要接口
- (BOOL)attachmentNeedsUpload
{
    return [_url length] == 0;
}

- (NSString *)attachmentPathForUploading
{
    return [self filepath];
}

- (void)updateAttachmentURL:(NSString *)urlString
{
    self.url = urlString;
}


#pragma mark - Private
- (void)updateCover{
    UIImage *image;
    if (!self.isFromMe) {
        if (self.isFired) {
            image = [UIImage imageNamed:@"session_snapchat_other_readed"];
        }else{
            image = [UIImage imageNamed:@"session_snapchat_other_unread"];
        }
    }else{
        if (self.isFired) {
            image = [UIImage imageNamed:@"session_snapchat_self_readed"];
        }else{
            image = [UIImage imageNamed:@"session_snapchat_self_unread"];
        }
    }
    self.showCoverImage = image;
}

- (UIImage *)showCoverImage
{
    if (_showCoverImage == nil)
    {
        [self updateCover];
    }
    return _showCoverImage;
}

#pragma mark - https
- (NSString *)url
{
    return [_url length] ?
    [[[NIMSDK sharedSDK] resourceManager] normalizeURLString:_url] : nil;
}



@end
