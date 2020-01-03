//
//  NTESGuardAttachment.h
//  flutter_nimsdk
//
//  Created by HyBoard on 2020/1/3.
//

#import <Foundation/Foundation.h>
#import "NTESCustomAttachmentDefines.h"


NS_ASSUME_NONNULL_BEGIN

@interface NTESGuardAttachment : NSObject<NIMCustomAttachment,NTESCustomAttachmentInfo>


@property (nonatomic,copy)  NSString    *md5;
@property (nonatomic,copy)  NSString    *url;
@property (nonatomic, copy) NSString    *gift_id;
@property (nonatomic, copy) NSString    *gift_img;
@property (nonatomic, copy) NSString    *gift_name;
@property (nonatomic, copy) NSString    *price;


@end

NS_ASSUME_NONNULL_END
