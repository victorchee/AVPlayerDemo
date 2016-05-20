//
//  VCPlayer.m
//  AVPlayerDemo
//
//  Created by Victor Chee on 16/5/19.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import "VCPlayer.h"
@import AVFoundation;

@interface VCPlayer()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *playedTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;

@end

@implementation VCPlayer

- (instancetype)initWithFrame:(CGRect)frame andVideoURL:(NSURL *)url {
    if (self = [super init]) {
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
    
    AVPlayerItem *payerItem = [self getPlayItemWithURL:videoURL];
    self.player = [AVPlayer playerWithPlayerItem:payerItem];
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
    __weak VCPlayer *weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong VCPlayer *strongSelf = weakSelf;
        strongSelf.playedTimeLabel.text = [NSString stringWithFormat:@"%.0f", CMTimeGetSeconds(strongSelf.player.currentTime)];
        strongSelf.progressSlider.value = CMTimeGetSeconds(strongSelf.player.currentTime);
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
}

- (void)playFinished:(NSNotification *)sender {
    self.progressSlider.value = 0;
    self.playedTimeLabel.text = @"0";
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
                    self.progressSlider.maximumValue = CMTimeGetSeconds(self.player.currentItem.duration);
                    self.leftTimeLabel.text = [NSString stringWithFormat:@"%.0f", self.progressSlider.maximumValue];
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
