//
//  FullScreenViewController.m
//  AVPlayerDemo
//
//  Created by Migu on 16/6/17.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import "FullScreenViewController.h"
#import "VCPlayer.h"

@interface FullScreenViewController () <VCPlayerDelegate>

@end

@implementation FullScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setPlayerView:(VCPlayer *)playerView {
    _playerView = playerView;
    
    if (playerView) {
        playerView.delegate = self;
        [self.view addSubview:playerView];
        playerView.translatesAutoresizingMaskIntoConstraints = NO;
        for (NSLayoutConstraint *constraint in playerView.constraints) {
            if ([constraint.identifier isEqualToString:@"VCPlayerConstraint"]) {
                [playerView removeConstraint:constraint];
            }
        }
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[playerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(playerView)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[playerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(playerView)]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - VCPlayerDelegate
- (void)player:(VCPlayer *)player didTappedFullscreen:(UIButton *)sender {
    [self performSegueWithIdentifier:@"UnwindSegue" sender:sender];
}

@end
