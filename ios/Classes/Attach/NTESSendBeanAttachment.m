//
//  NTESSendBeanAttachment.m
//  flutter_nimsdk
//
//  Created by HyBoard on 2020/1/3.
//

#import "NTESSendBeanAttachment.h"

@implementation NTESSendBeanAttachment


- (BOOL)canBeForwarded
{
    return NO;
}

- (BOOL)canBeRevoked
{
    return NO;
}


#pragma NIMCustomAttachment
- (NSString *)encodeAttachment
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [dict setObject:@(CustomMessageTypeSendBean) forKey:CMType];
    [data setObject:_md5?_md5:@"" forKey:CMMD5];
    [data setObject:_gift_id ? _gift_id : @"" forKey:CMGiftId];
    [data setObject:_gift_img ? _gift_img : @"" forKey:CMGiftImg];
    [data setObject:_gift_name ? _gift_name : @"" forKey:CMGiftName];
    [data setObject:_price ? _price : @"0" forKey:CMPrice];
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


- (void)updateAttachmentURL:(NSString *)urlString
{
    self.url = urlString;
}


#pragma mark - Private


#pragma mark - https
- (NSString *)url
{
    return [_url length] ?
    [[[NIMSDK sharedSDK] resourceManager] normalizeURLString:_url] : nil;
}




@end
