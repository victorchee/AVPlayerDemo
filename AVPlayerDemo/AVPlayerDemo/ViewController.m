//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by Victor Chee on 16/5/19.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import "ViewController.h"
#import "VCPlayer.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet VCPlayer *palyerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.palyerView.videoURL = [NSURL URLWithString:@"http://video.cmgame.com/videos/ybcp/qmqzmeiziduomaomaoweinisi4.mp4"];
    [self.palyerView play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
