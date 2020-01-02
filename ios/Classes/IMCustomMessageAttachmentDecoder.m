//
//  IMCustomMessageAttachmentDecoder.m
//  flutter_nimsdk
//
//  Created by HyBoard on 2019/12/18.
//

#import "IMCustomMessageAttachmentDecoder.h"
#import "IMCustomAttachment.h"
#import "Category/NSDictionary+NTESJson.h"
#import "Attach/NTESCustomAttachmentDefines.h"
#import "Attach/NTESSnapchatAttachment.h"

@implementation IMCustomMessageAttachmentDecoder

- (id<NIMCustomAttachment>)decodeAttachment:(NSString *)content
{
    id<NIMCustomAttachment> attachment = nil;

    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            NSInteger type = [dict jsonInteger:CMType];
            NSDictionary *data = [dict jsonDict:CMData];
            switch (type) {
                case CustomMessageTypeSnapchat: {
                    attachment = [[NTESSnapchatAttachment alloc] init];
                    ((NTESSnapchatAttachment *)attachment).md5 = [data jsonString:CMMD5];
                    ((NTESSnapchatAttachment *)attachment).url = [data jsonString:CMURL];
                    ((NTESSnapchatAttachment *)attachment).displayName = [data jsonString:CMDisplayName];
                    ((NTESSnapchatAttachment *)attachment).isFired = [data jsonBool:CMFIRE];
                }
                break;

                case CustomMessageTypeSnapchatVideo: {
                    attachment = [[NTESSnapchatAttachment alloc] init];
                    ((NTESSnapchatAttachment *)attachment).md5 = [data jsonString:CMMD5];
                    ((NTESSnapchatAttachment *)attachment).url = [data jsonString:CMURL];
                    ((NTESSnapchatAttachment *)attachment).displayName = [data jsonString:CMDisplayName];
                    ((NTESSnapchatAttachment *)attachment).path = [data jsonString:CMPath];
                    ((NTESSnapchatAttachment *)attachment).size = [data jsonString:CMSize];
                    ((NTESSnapchatAttachment *)attachment).duration = [data jsonString:CMDuration];
                    ((NTESSnapchatAttachment *)attachment).width = [data jsonString:CMWidth];
                    ((NTESSnapchatAttachment *)attachment).height = [data jsonString:CMHeight];
                    ((NTESSnapchatAttachment *)attachment).extension = [data jsonString:CMExtension];
                    ((NTESSnapchatAttachment *)attachment).isFired = [data jsonBool:CMFIRE];
                }
                break;

                case CustomMessageTypeLookSnapchatImage: {
                    attachment = [[NTESSnapchatAttachment alloc] init];
                    ((NTESSnapchatAttachment *)attachment).md5 = [data jsonString:CMMD5];
                    ((NTESSnapchatAttachment *)attachment).url = [data jsonString:CMURL];
                    ((NTESSnapchatAttachment *)attachment).displayName = [data jsonString:CMDisplayName];
                    ((NTESSnapchatAttachment *)attachment).isFired = [data jsonBool:CMFIRE];
                }
                break;

                case CustomMessageTypeLookSnapchatVideo: {
                    attachment = [[NTESSnapchatAttachment alloc] init];
                    ((NTESSnapchatAttachment *)attachment).md5 = [data jsonString:CMMD5];
                    ((NTESSnapchatAttachment *)attachment).url = [data jsonString:CMURL];
                    ((NTESSnapchatAttachment *)attachment).displayName = [data jsonString:CMDisplayName];
                    ((NTESSnapchatAttachment *)attachment).path = [data jsonString:CMPath];
                    ((NTESSnapchatAttachment *)attachment).size = [data jsonString:CMSize];
                    ((NTESSnapchatAttachment *)attachment).duration = [data jsonString:CMDuration];
                    ((NTESSnapchatAttachment *)attachment).width = [data jsonString:CMWidth];
                    ((NTESSnapchatAttachment *)attachment).height = [data jsonString:CMHeight];
                    ((NTESSnapchatAttachment *)attachment).extension = [data jsonString:CMExtension];
                    ((NTESSnapchatAttachment *)attachment).isFired = [data jsonBool:CMFIRE];
                }
                break;

                default: {
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

- (BOOL)checkAttachment:(id<NIMCustomAttachment>)attachment
{
    BOOL check = NO;
    if ([attachment isKindOfClass:[NTESSnapchatAttachment class]]) {
        check = YES;
    }

    return check;
}

@end
