//
//  VCPlayerViewController.m
//  AVPlayerDemo
//
//  Created by Victor Chee on 2017/2/28.
//  Copyright © 2017年 VictorChee. All rights reserved.
//

#import "VCPlayerViewController.h"
#import "VCPlayerController.h"

@interface VCPlayerViewController ()

@property (nonatomic, strong) VCPlayerController *controller;

@end

@implementation VCPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.controller = [[VCPlayerController alloc] initWithURL:self.url];
    UIView *playerView = self.controller.view;
    playerView.frame = self.view.frame;
    [self.view addSubview:playerView];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
