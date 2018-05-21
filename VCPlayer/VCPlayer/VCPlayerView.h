//
//  VCPlayerView.h
//  VCPlayer
//
//  Created by Migu on 2018/4/8.
//  Copyright © 2018年 VIctorChee. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;
@import MediaPlayer;

typedef enum : NSUInteger {
    VCPlayerStateFailed,
    VCPlayerStateBuffering,
    VCPlayerStatePlaying,
    VCPlayerStateStopped,
    VCPlayerStatePaused,
    VCPlayerStateFinished,
} VCPlayerState;

@interface VCPlayerView : UIView
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayerItem *currentItem;
@property (nonatomic, copy) NSString *videoLink;
@property (nonatomic, assign) VCPlayerState state;
@property (nonatomic, assign, getter=isFullscreen) BOOL fullscreen;
@property (nonatomic, assign) NSTimeInterval seekTime;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadFailLabel;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIProgressView *loadProgressView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (weak, nonatomic) IBOutlet UIButton *fullscreenButton;

- (void)resetPlayer;
- (void)teardownPlayer;
- (void)play;
- (void)pause;

@end
