//
//  FlutterViewFactory.h
//  flutter_nimsdk
//
//  Created by HyBoard on 2019/11/15.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "DisplayView.h"


@interface FlutterNimViewFactory : NSObject<FlutterPlatformViewFactory>


- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager displayView:(UIView *)displayView;
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager;


@end

