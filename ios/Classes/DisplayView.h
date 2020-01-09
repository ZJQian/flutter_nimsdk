//
//  DisplayView.h
//  flutter_nimsdk
//
//  Created by HyBoard on 2019/11/15.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>


@interface DisplayView : NSObject<FlutterPlatformView>

- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger view:(UIView *)displayView;

@end

