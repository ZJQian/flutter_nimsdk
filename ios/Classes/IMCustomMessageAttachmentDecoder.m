//
//  IMCustomMessageAttachmentDecoder.m
//  flutter_nimsdk
//
//  Created by HyBoard on 2019/12/18.
//

#import "IMCustomMessageAttachmentDecoder.h"
#import "IMCustomAttachment.h"
#import "NSDictionary+NTESJson.h"
#import "NTESCustomAttachmentDefines.h"
#import "NTESSnapchatAttachment.h"

@implementation IMCustomMessageAttachmentDecoder


- (id<NIMCustomAttachment>)decodeAttachment:(NSString *)content
{
    id<NIMCustomAttachment> attachment = nil;

    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            NSInteger type     = [dict jsonInteger:CMType];
            NSDictionary *data = [dict jsonDict:CMData];
            switch (type) {
                
                case CustomMessageTypeSnapchat:
                {
                    attachment = [[NTESSnapchatAttachment alloc] init];
                    ((NTESSnapchatAttachment *)attachment).md5 = [data jsonString:CMMD5];
                    ((NTESSnapchatAttachment *)attachment).url = [data jsonString:CMURL];
                    ((NTESSnapchatAttachment *)attachment).isFired = [data jsonBool:CMFIRE];
                }
                    break;
                
                default:
                {
                    attachment = [[IMCustomAttachment alloc] init];
                    ((IMCustomAttachment *)attachment).customEncodeString = content;
                }
                    break;
            }
            attachment = [self checkAttachment:attachment] ? attachment : nil;
        }
    }
    return attachment;
}

- (BOOL)checkAttachment:(id<NIMCustomAttachment>)attachment{
    BOOL check = NO;
    if ([attachment isKindOfClass:[NTESSnapchatAttachment class]])
    {
        check = YES;
    }
    
    return check;
}


@end
