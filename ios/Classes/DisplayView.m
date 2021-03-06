//
//  DisplayView.m
//  flutter_nimsdk
//
//  Created by HyBoard on 2019/11/15.
//

#import "DisplayView.h"
#import "NimDataManager.h"

@implementation DisplayView{
    int64_t _viewId;
    FlutterMethodChannel* _channel;
    UIView * _displayView;
}

- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger view:(nonnull UIView *)displayView{
    if ([super init]) {
                
        _displayView = displayView;
        _viewId = viewId;
        NSString* channelName = [NSString stringWithFormat:@"plugins/display_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall *  call, FlutterResult  result) {
            [weakSelf onMethodCall:call result:result];
        }];
        
    }
    
    return self;
}

-(UIView *)view{
    return _displayView;
}

-(void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    
}


@end
