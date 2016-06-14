//
//  VCPlayer.m
//  AVPlayerDemo
//
//  Created by Victor Chee on 16/5/19.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import "VCPlayer.h"
@import AVFoundation;

typedef NS_ENUM(NSUInteger, PanDirection) {
    PanDirectionNone,
    PanDirectionHorizon,
    PanDirectionVertical,
};

@interface VCPlayer() {
    CGPoint gesturePoint;
    PanDirection panDirection;
}

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *playedTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation VCPlayer

- (instancetype)initWithFrame:(CGRect)frame andVideoURL:(NSURL *)url {
    if (self = [super initWithFrame:frame]) {
        self.videoURL = url;
    }
    return self;
}

- (void)dealloc {
    [self.player removeTimeObserver:self];
    
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferFull"];
    [self.player.currentItem removeObserver:self forKeyPath:@"presentationSize"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (AVPlayerItem *)getPlayItemWithURL:(NSURL *)url {
    if (url.isFileURL) {
        AVAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        return [AVPlayerItem playerItemWithAsset:asset];
    } else {
        return [AVPlayerItem playerItemWithURL:url];
    }
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    
    AVPlayerItem *playerItem = [self getPlayItemWithURL:videoURL];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
    self.volumeLabel.text = [NSString stringWithFormat:@"%ld%%", (NSInteger)(self.player.volume*100.0)];
    
    __weak VCPlayer *weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong VCPlayer *strongSelf = weakSelf;
        strongSelf.playedTimeLabel.text = [NSString stringWithFormat:@"%.0f", CMTimeGetSeconds(strongSelf.player.currentTime)];
        strongSelf.progressSlider.value = CMTimeGetSeconds(strongSelf.player.currentTime);
        strongSelf.progressLabel.text = [NSString stringWithFormat:@"%.0f/%.0f", strongSelf.progressSlider.value, strongSelf.progressSlider.maximumValue];
    }];
    
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.player.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.player.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.player.currentItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.player.currentItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.layer.bounds;
}

- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (IBAction)switchPlayOrPause:(UIButton *)sender {
    if (sender.isSelected) {
        [self play];
    } else {
        [self pause];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)switchFullScreen:(UIButton *)sender {
    if (sender.isSelected) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        [UIApplication sharedApplication].statusBarHidden = NO;
        [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
    } else {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
        [UIApplication sharedApplication].statusBarHidden = NO;
        [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)progressSliderValueChanged:(UISlider *)sender {
    [self.player seekToTime:CMTimeMakeWithSeconds(sender.value, 1)];
    [self play];
}

- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            gesturePoint = [sender translationInView:self];
            self.volumeLabel.superview.hidden = YES;
            self.progressLabel.superview.hidden = YES;
            panDirection = PanDirectionNone;
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint point = [sender translationInView:self];
            CGFloat deltaX = point.x - gesturePoint.x;
            CGFloat deltaY = point.y - gesturePoint.y;
            if (panDirection == PanDirectionNone) {
                // 确定滑动方向
                if (fabs(deltaX) > 5) {
                    panDirection = PanDirectionHorizon;
                    self.progressLabel.superview.hidden = NO;
                } else if (fabs(deltaY) > 5) {
                    panDirection = PanDirectionVertical;
                    self.volumeLabel.superview.hidden = NO;
                }
            }
            if (panDirection == PanDirectionHorizon) {
                // 调节进度
                CGFloat threshold = CGRectGetWidth(self.frame)/2;
                CGFloat time = self.progressSlider.value + deltaX/threshold * self.progressSlider.maximumValue;
                if (time > self.progressSlider.maximumValue) {
                    time = self.progressSlider.maximumValue;
                } else if (time < self.progressSlider.minimumValue) {
                    time = self.progressSlider.minimumValue;
                }
                NSLog(@"deltaX:%f", time);
                [self.player seekToTime:CMTimeMakeWithSeconds(time, 1)];
            } else if (panDirection == PanDirectionVertical) {
                // 调节音量
                CGFloat threshold = CGRectGetHeight(self.frame)/2;
                CGFloat volume = self.player.volume - deltaY/threshold;
                if (volume > 1.0) {
                    volume = 1.0;
                } else if (volume < 0) {
                    volume = 0;
                }
                self.player.volume = volume;
                self.volumeLabel.text = [NSString stringWithFormat:@"%ld%%", (NSInteger)(volume*100.0)];
            }
            
            if (panDirection != PanDirectionNone) {
                gesturePoint = point;
            }
        }
            break;
        case UIGestureRecognizerStateEnded: {
            self.volumeLabel.superview.hidden = YES;
            self.progressLabel.superview.hidden = YES;
            gesturePoint = CGPointZero;
            panDirection = PanDirectionNone;
        }
            break;
            
        default:
            break;
    }
}

- (void)playFinished:(NSNotification *)sender {
    self.progressSlider.value = 0;
    self.playedTimeLabel.text = @"0";
    self.progressLabel.text = @"0%";
    [self.player seekToTime:kCMTimeZero];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusUnknown: {
                
            }
                break;
                
            case AVPlayerStatusReadyToPlay: {
                if (CMTimeGetSeconds(self.player.currentItem.duration)) {
                    CGFloat duration = CMTimeGetSeconds(self.player.currentItem.duration);
                    if (duration > self.progressSlider.minimumValue) {
                        self.progressSlider.maximumValue = CMTimeGetSeconds(self.player.currentItem.duration);
                        self.durationLabel.text = [NSString stringWithFormat:@"%.0f", self.progressSlider.maximumValue];
                    }
                }
                [self.indicator stopAnimating];
            }
                break;
                
            case AVPlayerStatusFailed: {
                [self.indicator stopAnimating];
            }
                break;
                
            default:
                break;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        // 更新缓冲进度
        NSArray * loadedTimeRanges = self.player.currentItem.loadedTimeRanges;
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval result = startSeconds + durationSeconds;
        self.progressSlider.value = result/CMTimeGetSeconds(self.player.currentItem.duration);
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        // 当视频播放因为各种状态播放停止的时候, 这个属性会发生变化
    } else if([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        // 当没有任何缓冲部分可以播放的时候
        [self.indicator startAnimating];
    } else if ([keyPath isEqualToString:@"playbackBufferFull"]) {
        NSLog(@"playbackBufferFull: change : %@", change);
    } else if([keyPath isEqualToString:@"presentationSize"]) {
        // 获取到视频的尺寸大小的时候调用
//        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

@end
