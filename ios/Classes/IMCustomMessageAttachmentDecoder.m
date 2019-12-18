//
//  IMCustomMessageAttachmentDecoder.m
//  flutter_nimsdk
//
//  Created by HyBoard on 2019/12/18.
//

#import "IMCustomMessageAttachmentDecoder.h"
#import "IMCustomAttachment.h"

@implementation IMCustomMessageAttachmentDecoder


- (id<NIMCustomAttachment>)decodeAttachment:(NSString *)content
{
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (data != nil) {
        
        IMCustomAttachment *attachment = [[IMCustomAttachment alloc] init];
        attachment.customEncodeString = content;
        return attachment;
    }
    return nil;
}

@end
