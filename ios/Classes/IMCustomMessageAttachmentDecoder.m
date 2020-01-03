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
#import "Attach/NTESIncomeBeanAttachment.h"
#import "Attach/NTESIncomeGiftAttachment.h"
#import "Attach/NTESSendBeanAttachment.h"
#import "Attach/NTESSendGiftAttachment.h"
#import "Attach/NTESSnapchatVideoAttachment.h"
#import "Attach/NTESSnapchatLookImageAttachment.h"
#import "Attach/NTESSnapchatLookVideoAttachment.h"
#import "Attach/NTESGuardAttachment.h"

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
                    ((NTESSnapchatAttachment *)attachment).path = [data jsonString:CMPath];
                    ((NTESSnapchatAttachment *)attachment).isFired = [data jsonBool:CMFIRE];
                }
                break;
                    
                case CustomMessageTypeIncomeBean: {
                    
                    attachment = [[NTESIncomeBeanAttachment alloc] init];
                    ((NTESIncomeBeanAttachment *)attachment).md5 = [data jsonString:CMMD5];
                    ((NTESIncomeBeanAttachment *)attachment).url = [data jsonString:CMURL];
                    ((NTESIncomeBeanAttachment *)attachment).gift_id = [data jsonString:CMGiftId];
                    ((NTESIncomeBeanAttachment *)attachment).gift_img = [data jsonString:CMGiftImg];
                    ((NTESIncomeBeanAttachment *)attachment).gift_name = [data jsonString:CMGiftName];
                    ((NTESIncomeBeanAttachment *)attachment).price = [data jsonString:CMPrice];
                }
                    break;
                case CustomMessageTypeIncomeGift: {
                    
                    attachment = [[NTESIncomeGiftAttachment alloc] init];
                    ((NTESIncomeGiftAttachment *)attachment).md5 = [data jsonString:CMMD5];
                    ((NTESIncomeGiftAttachment *)attachment).url = [data jsonString:CMURL];
                    ((NTESIncomeGiftAttachment *)attachment).gift_id = [data jsonString:CMGiftId];
                    ((NTESIncomeGiftAttachment *)attachment).gift_img = [data jsonString:CMGiftImg];
                    ((NTESIncomeGiftAttachment *)attachment).gift_name = [data jsonString:CMGiftName];
                    ((NTESIncomeGiftAttachment *)attachment).price = [data jsonString:CMPrice];
                }
                    break;
                case CustomMessageTypeSendGift: {
                    
                    attachment = [[NTESSendGiftAttachment alloc] init];
                    ((NTESSendGiftAttachment *)attachment).md5 = [data jsonString:CMMD5];
                    ((NTESSendGiftAttachment *)attachment).url = [data jsonString:CMURL];
                    ((NTESSendGiftAttachment *)attachment).gift_id = [data jsonString:CMGiftId];
                    ((NTESSendGiftAttachment *)attachment).gift_img = [data jsonString:CMGiftImg];
                    ((NTESSendGiftAttachment *)attachment).gift_name = [data jsonString:CMGiftName];
                    ((NTESSendGiftAttachment *)attachment).gift_svga = [data jsonString:CMGiftSvga];
                    ((NTESSendGiftAttachment *)attachment).price = [data jsonString:CMPrice];
                }
                    break;
                case CustomMessageTypeSendBean: {
                    
                    attachment = [[NTESSendBeanAttachment alloc] init];
                    ((NTESSendBeanAttachment *)attachment).md5 = [data jsonString:CMMD5];
                    ((NTESSendBeanAttachment *)attachment).url = [data jsonString:CMURL];
                    ((NTESSendBeanAttachment *)attachment).gift_id = [data jsonString:CMGiftId];
                    ((NTESSendBeanAttachment *)attachment).gift_img = [data jsonString:CMGiftImg];
                    ((NTESSendBeanAttachment *)attachment).gift_name = [data jsonString:CMGiftName];
                    ((NTESSendBeanAttachment *)attachment).price = [data jsonString:CMPrice];
                }
                    break;
                    
                case CustomMessageTypeGuard: {
                    attachment = [[NTESGuardAttachment alloc] init];
                    ((NTESGuardAttachment *)attachment).md5 = [data jsonString:CMMD5];
                    ((NTESGuardAttachment *)attachment).url = [data jsonString:CMURL];
                    ((NTESGuardAttachment *)attachment).gift_id = [data jsonString:CMGiftId];
                    ((NTESGuardAttachment *)attachment).gift_img = [data jsonString:CMGiftImg];
                    ((NTESGuardAttachment *)attachment).gift_name = [data jsonString:CMGiftName];
                    ((NTESGuardAttachment *)attachment).price = [data jsonString:CMPrice];
                }
                    break;

                case CustomMessageTypeSnapchatVideo: {
                    attachment = [[NTESSnapchatVideoAttachment alloc] init];
                    ((NTESSnapchatVideoAttachment *)attachment).md5 = [data jsonString:CMMD5];
                    ((NTESSnapchatVideoAttachment *)attachment).url = [data jsonString:CMURL];
                    ((NTESSnapchatVideoAttachment *)attachment).displayName = [data jsonString:CMDisplayName];
                    ((NTESSnapchatVideoAttachment *)attachment).path = [data jsonString:CMPath];
                    ((NTESSnapchatVideoAttachment *)attachment).size = [data jsonString:CMSize];
                    ((NTESSnapchatVideoAttachment *)attachment).duration = [data jsonString:CMDuration];
                    ((NTESSnapchatVideoAttachment *)attachment).width = [data jsonString:CMWidth];
                    ((NTESSnapchatVideoAttachment *)attachment).height = [data jsonString:CMHeight];
                    ((NTESSnapchatVideoAttachment *)attachment).extension = [data jsonString:CMExtension];
                    ((NTESSnapchatVideoAttachment *)attachment).isFired = [data jsonBool:CMFIRE];
                }
                break;

                case CustomMessageTypeLookSnapchatImage: {
                    attachment = [[NTESSnapchatLookImageAttachment alloc] init];
                    ((NTESSnapchatLookImageAttachment *)attachment).md5 = [data jsonString:CMMD5];
                    ((NTESSnapchatLookImageAttachment *)attachment).url = [data jsonString:CMURL];
                    ((NTESSnapchatLookImageAttachment *)attachment).path = [data jsonString:CMPath];
                    ((NTESSnapchatLookImageAttachment *)attachment).displayName = [data jsonString:CMDisplayName];
                    ((NTESSnapchatLookImageAttachment *)attachment).isFired = [data jsonBool:CMFIRE];
                }
                break;

                case CustomMessageTypeLookSnapchatVideo: {
                    attachment = [[NTESSnapchatLookVideoAttachment alloc] init];
                    ((NTESSnapchatLookVideoAttachment *)attachment).md5 = [data jsonString:CMMD5];
                    ((NTESSnapchatLookVideoAttachment *)attachment).url = [data jsonString:CMURL];
                    ((NTESSnapchatLookVideoAttachment *)attachment).displayName = [data jsonString:CMDisplayName];
                    ((NTESSnapchatLookVideoAttachment *)attachment).path = [data jsonString:CMPath];
                    ((NTESSnapchatLookVideoAttachment *)attachment).size = [data jsonString:CMSize];
                    ((NTESSnapchatLookVideoAttachment *)attachment).duration = [data jsonString:CMDuration];
                    ((NTESSnapchatLookVideoAttachment *)attachment).width = [data jsonString:CMWidth];
                    ((NTESSnapchatLookVideoAttachment *)attachment).height = [data jsonString:CMHeight];
                    ((NTESSnapchatLookVideoAttachment *)attachment).extension = [data jsonString:CMExtension];
                    ((NTESSnapchatLookVideoAttachment *)attachment).isFired = [data jsonBool:CMFIRE];
                }
                break;

                default: {
                    attachment = [[IMCustomAttachment alloc] init];
                    ((IMCustomAttachment *)attachment).customEncodeString = content;
                }
                break;
            }
//            attachment = [self checkAttachment:attachment] ? attachment : nil;
        }
    }
    return attachment;
}

- (BOOL)checkAttachment:(id<NIMCustomAttachment>)attachment
{
    BOOL check = NO;
    if ([attachment isKindOfClass:[NTESSnapchatAttachment class]]) {
        check = YES;
    }else if ([attachment isKindOfClass:[NTESSnapchatVideoAttachment class]]) {
        check = YES;
    }else if ([attachment isKindOfClass:[NTESSnapchatLookVideoAttachment class]]) {
        check = YES;
    }else if ([attachment isKindOfClass:[NTESSnapchatLookImageAttachment class]]) {
        check = YES;
    }

    return check;
}

@end
