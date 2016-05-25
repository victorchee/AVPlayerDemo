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
    NSString *http = @"http://video.cmgame.com/videos/ybcp/qmqzmeiziduomaomaoweinisi4.mp4";
    NSString *hls = @"http://liveplay.cmgame.com/27871/stream.m3u8";
    self.palyerView.videoURL = [NSURL URLWithString:hls];
    [self.palyerView play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
