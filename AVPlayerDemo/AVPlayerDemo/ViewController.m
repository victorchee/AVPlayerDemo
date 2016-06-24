//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by Victor Chee on 16/5/19.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import "ViewController.h"
#import "VCPlayer.h"

@interface ViewController () {
    NSArray *originalConstraints;
}

@property (weak, nonatomic) IBOutlet UIButton *fullscreenButton;
@property (weak, nonatomic) IBOutlet VCPlayer *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *http = @"http://video.cmgame.com/videos/415/4151a6b1c77f531d5974911a88290dff.mp4";
    NSString *hls = @"http://liveplay.cmgame.com/27871/stream.m3u8";
    self.playerView.videoURL = [NSURL URLWithString:http];
    [self.playerView play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"FullscreenSegue"]) {
//        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
//        [UIApplication sharedApplication].statusBarHidden = NO;
//        [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
        
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        [UIApplication sharedApplication].statusBarHidden = NO;
        [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
        
        NSMutableArray *temp = [NSMutableArray array];
        for (NSLayoutConstraint *constraint in self.view.constraints) {
            if ([constraint.identifier isEqualToString:@"VCPlayerConstraint"]) {
                [temp addObject:constraint];
                [self.view removeConstraint:constraint];
            }
        }
        originalConstraints = [temp copy];
        
        [segue.destinationViewController setValue:self.playerView forKey:@"playerView"];
    }
}

- (IBAction)unwindFromFullscreen:(UIStoryboardSegue *)unwindSegue {
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
    
    self.playerView = [unwindSegue.sourceViewController valueForKey:@"playerView"];
    [self.view addSubview:self.playerView];
    self.playerView.translatesAutoresizingMaskIntoConstraints = NO;
    for (NSLayoutConstraint *constraint in originalConstraints) {
        [self.view addConstraint:constraint];
    }
    NSLayoutConstraint *ratioConstraint = [NSLayoutConstraint constraintWithItem:self.playerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeHeight multiplier:1.77778 constant:0];
    ratioConstraint.identifier = @"VCPlayerConstraint";
    [self.playerView addConstraint:ratioConstraint];
}

- (void)orientationChanged:(NSNotification *)sender {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
    } else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        [self.fullscreenButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

@end
