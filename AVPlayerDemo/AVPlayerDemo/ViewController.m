//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by Victor Chee on 16/5/19.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import "ViewController.h"
#import "VCPlayerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSURL *assetURL = [[NSBundle mainBundle] URLForResource:@"hubblecast" withExtension:@"m4v"];
    VCPlayerViewController *controller = [[VCPlayerViewController alloc] init];
    controller.url = assetURL;
    [self presentViewController:controller animated:YES completion:^{ }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
