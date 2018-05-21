//
//  VCPlayerView.m
//  VCPlayer
//
//  Created by Migu on 2018/4/8.
//  Copyright © 2018年 VIctorChee. All rights reserved.
//

#import "VCPlayerView.h"

@interface VCPlayerView()
@property (nonatomic, assign) BOOL hasInitializedPlayer;
@property (nonatomic, assign, getter=isDragingSlider) BOOL draggingSlider;
@property (nonatomic, strong) id playbackTimeObserver;
@property (nonatomic, strong) NSTimer *autoFadeControlsTimer;
@end

@implementation VCPlayerView

- (void)awakeFromNib {
    [super awakeFromNib];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    self.seekTime = 0;
    [self.activityIndicator startAnimating];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.currentItem cancelPendingSeeks];
    [self.currentItem.asset cancelLoading];
    [self.player pause];
    [self.player removeTimeObserver:self.playbackTimeObserver];
    
    [self.currentItem removeObserver:self forKeyPath:@"status"];
    [self.currentItem removeObserver:self forKeyPath:@"duration"];
    [self.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    self.currentItem = nil;
    
    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.playbackTimeObserver = nil;
    
    [self.autoFadeControlsTimer invalidate];
    self.autoFadeControlsTimer = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

- (void)setState:(VCPlayerState)state {
    _state = state;
    
    if (state == VCPlayerStateBuffering) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
}

- (IBAction)playButtonTapped:(UIButton *)sender {
    if (self.state == VCPlayerStateStopped || self.state == VCPlayerStateFailed) {
        [self play];
    } else if (self.state == VCPlayerStatePlaying) {
        [self pause];
    } else if (self.state == VCPlayerStateFinished) {
        self.state =  VCPlayerStatePlaying;
        [self.player play];
        sender.selected = NO;
    }
}

- (IBAction)backButtonTapped:(UIButton *)sender {
}

- (IBAction)fullscreenButtonTapped:(UIButton *)sender {
    sender.selected = !sender.isSelected;
}

- (IBAction)timeSliderValueChanged:(UISlider *)sender {
}

- (void)createPlayer {
    self.currentItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.videoLink]];
    self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
    if ([self.player respondsToSelector:@selector(automaticallyWaitsToMinimizeStalling)]) {
        self.player.automaticallyWaitsToMinimizeStalling = YES;
    }
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
    self.state = VCPlayerStateBuffering;
}

- (void)videoPlayDidEnd:(NSNotification *)sender {
    [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            [self showPlayControls];
            self.state = VCPlayerStateFinished;
            self.playButton.selected = YES;
        }
    }];
}

- (void)showPlayControls {
    [UIView animateWithDuration:0.25 animations:^{
        self.topView.alpha = 1;
        self.bottomView.alpha = 1;
    }];
}

- (void)hidePlayControls {
    [UIView animateWithDuration:0.25 animations:^{
        self.topView.alpha = 0;
        self.bottomView.alpha = 0;
    }];
}

- (void)autoFadeControls:(NSTimer *)sender {
    if (self.state == VCPlayerStatePlaying) {
        [self hidePlayControls];
    }
}

- (void)play {
    if (self.hasInitializedPlayer) {
        if (self.state == VCPlayerStateStopped || self.state == VCPlayerStatePaused) {
            self.state = VCPlayerStatePlaying;
            [self.player play];
            self.playButton.selected = NO;
        }
    } else {
        self.hasInitializedPlayer = YES;
        
        [self.player play];
        self.playButton.selected = NO;
    }
}

- (void)pause {
    
}

- (void)resetPlayer {
    self.currentItem = nil;
    self.seekTime = 0;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.autoFadeControlsTimer invalidate];
    self.autoFadeControlsTimer = nil;
    
    [self.player pause];
    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
}

- (void)teardownPlayer {
    [self pause];
    
    [self removeFromSuperview];
    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    self.currentItem = nil;
    
    [self.autoFadeControlsTimer invalidate];
    self.autoFadeControlsTimer = nil;
}

- (void)addTimerObserver {
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSTimeInterval currentTime = CMTimeGetSeconds(strongSelf.currentItem.currentTime);
//        NSTimeInterval duration = CMTimeGetSeconds(strongSelf.currentItem.duration);
        if (!strongSelf.isDragingSlider) {
            [strongSelf.timeSlider setValue:currentTime animated:YES];
        }
    }];
}

- (void)bufferOneSecond {
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusUnknown: {
                [self.loadProgressView setProgress:0 animated:NO];
                self.state = VCPlayerStateBuffering;
            }
                break;
                
            case AVPlayerStatusReadyToPlay: {
                self.state = VCPlayerStatePlaying;
                [self addTimerObserver];
                if (!self.autoFadeControlsTimer) {
                    self.autoFadeControlsTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(autoFadeControls:) userInfo:nil repeats:NO];
                }
                if (self.seekTime) {
                    [self.player seekToTime:CMTimeMakeWithSeconds(self.seekTime, self.currentItem.currentTime.timescale)];
                }
            }
                break;
                
            case AVPlayerStatusFailed: {
                self.state = VCPlayerStateFailed;
                
                NSError *error = self.currentItem.error;
                if (error) {
                    self.loadFailLabel.hidden = NO;
                    [self bringSubviewToFront:self.loadFailLabel];
                    self.loadFailLabel.text = error.localizedDescription;
                }
            }
                break;
                
            default:
                break;
        }
    } else if ([keyPath isEqualToString:@"duration"]) {
        self.state = VCPlayerStatePlaying;
        
        NSTimeInterval duration = CMTimeGetSeconds(self.currentItem.duration);
        self.timeSlider.maximumValue = duration;
        self.durationLabel.text = @(duration).stringValue;
    } else if ([keyPath isEqualToString:@"loadedTimeRange"]) {
        NSArray *loadedTimeRanges = self.currentItem.loadedTimeRanges;
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        NSTimeInterval availableDuration = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        
        NSTimeInterval duration = CMTimeGetSeconds(self.currentItem.duration);
        
        [self.loadProgressView setProgress:availableDuration / duration animated:YES];
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        if (self.currentItem.playbackBufferEmpty) {
            self.state = VCPlayerStateBuffering;
            [self bufferOneSecond];
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        if (self.state == VCPlayerStateBuffering && self.currentItem.playbackLikelyToKeepUp) {
            self.state = VCPlayerStatePlaying;
        }
    }
}

@end
