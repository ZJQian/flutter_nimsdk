//
//  VideoChatViewController.m
//  flutter_nimsdk
//
//  Created by HyBoard on 2019/11/15.
//

#import "VideoChatViewController.h"
#import <NIMSDK/NIMSDK.h>
#import <NIMAVChat/NIMAVChat.h>

@interface VideoChatViewController ()

@end

@implementation VideoChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.localDisplayView.frame = self.view.bounds;
    [self.view addSubview:self.localDisplayView];
    
    self.remoteDisplayView.frame = CGRectMake(0, 0, 100, 100);
    [self.view addSubview:self.remoteDisplayView];
}

@end
