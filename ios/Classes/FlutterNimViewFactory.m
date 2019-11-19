//
//  FlutterViewFactory.m
//  flutter_nimsdk
//
//  Created by HyBoard on 2019/11/15.
//

#import "FlutterNimViewFactory.h"

@implementation FlutterNimViewFactory{
    NSObject<FlutterBinaryMessenger>*    _messenger;
    UIView *_displayView;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager displayView:(UIView *)displayView{
    self = [super init];
    if (self) {
        _messenger = messager;
        _displayView = displayView;
    }
    return self;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager {
    self = [super init];
    if (self) {
        _messenger = messager;
    }
    return self;
}


-(NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}

-(NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args{
    
    DisplayView *v = [[DisplayView alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger view: _displayView];
    
    return v;
    
}

@end
