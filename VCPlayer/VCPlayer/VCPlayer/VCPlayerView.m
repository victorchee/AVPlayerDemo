//
//  VCPlayerView.m
//  VCPlayer
//
//  Created by Migu on 2018/4/8.
//  Copyright © 2018年 VIctorChee. All rights reserved.
//

#import "VCPlayerView.h"
@import MediaPlayer;
#import "UIView+VCPlayerControlView.h"

@interface VCPlayerView()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, assign) CGFloat seekTime;
@property (nonatomic, strong) id timeObserver;

@property (nonatomic, assign) BOOL isPausedByUser;
@property (nonatomic, assign) VCPlayerState state;
@property (nonatomic, assign) BOOL fullscreen;
@property (nonatomic, assign) BOOL repeatingPlay;
@property (nonatomic, assign) BOOL playDidEnd;
@property (nonatomic, assign) BOOL didEnterBackground;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL viewDisappear;
@property (nonatomic, assign) BOOL isCellVideo;
@end

@implementation VCPlayerView

+ (instancetype)sharedInstance {
    static VCPlayerView *playerView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerView = [[VCPlayerView alloc] init];
    });
    return playerView;
}

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

- (void)dealloc {
    self.playerItem = nil;
    self.scrollView = nil;
    [self.controlView vcPlayerCancelAutoFadeOutControlView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    
    self.repeatingPlay = NO;
    self.playDidEnd = NO;
    
    [self addNotifications];
    
    self.isPausedByUser = YES;
}

- (void)setAutoPlay:(BOOL)autoPlay {
    _autoPlay = autoPlay;
    if (autoPlay) {
        [self configurePlayer];
    }
}

- (void)setState:(VCPlayerState)state {
    _state = state;
    
    [self.controlView vcPlayerLoadingActivity:state == VCPlayerStateBuffering];
    if (state == VCPlayerStatePlaying || state == VCPlayerStateBuffering) {
        [self.controlView vcPlayerItemPlaying];
    } else if (state == VCPlayerStateFailed) {
        [self.controlView vcPlayerItemStatusFailed:self.player.currentItem.error];
    }
}

- (void)setMute:(BOOL)mute {
    _mute = mute;
    self.player.muted = mute;
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if ([_playerItem isEqual:playerItem]) {
        return;
    }
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    _playerItem = playerItem;
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)setScrollView:(UIScrollView *)scrollView {
    if ([_scrollView isEqual:scrollView]) {
        return;
    }
    if (_scrollView) {
        [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
    _scrollView = scrollView;
    if (scrollView) {
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    _videoGravity = videoGravity;
    self.playerLayer.videoGravity = videoGravity;
}

- (void)setControlView:(UIView *)controlView {
    if (_controlView) {
        return;
    }
    _controlView = controlView;
    controlView.delegate = self;
    [self addSubview:controlView];
    controlView.translatesAutoresizingMaskIntoConstraints = NO;
    [controlView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [controlView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [controlView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [controlView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
}

- (void)play {
    [self.controlView vcPlayerPlayButtonState:YES];
    if (self.state == VCPlayerStatePaused) {
        self.state = VCPlayerStatePlaying;
    }
    self.isPausedByUser = NO;
    [self.player play];
}

- (void)pause {
    [self.controlView vcPlayerPlayButtonState:NO];
    if (self.state == VCPlayerStatePlaying) {
        self.state = VCPlayerStatePaused;
    }
    self.isPausedByUser = YES;
    [self.player pause];
}

- (void)configurePlayer {
    AVURLAsset *asset = [AVURLAsset assetWithURL:self.videoURL];
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem]; // 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = self.videoGravity;
    
    self.autoPlay = YES;
}

- (void)resetPlayer {
    self.playDidEnd = NO;
    self.playerItem = nil;
    self.didEnterBackground = NO;
    
    self.seekTime = 0;
    self.autoPlay = NO;
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self pause];
    [self.playerLayer removeFromSuperlayer];
    self.player = nil;
    
    [self.controlView vcPlayerResetControlView];
    self.controlView = nil;
    
    if (self.repeatingPlay) {
        [self removeFromSuperview];
    }
    
    if (self.isCellVideo && !self.repeatingPlay) {
        self.viewDisappear = YES;
        self.isCellVideo = NO;
        self.scrollView = nil;
        self.indexPath = nil;
    }
    
    [self createTimer];
    
    [self play];
    self.isPausedByUser = NO;
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)createTimer {
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        AVPlayerItem *currentItem = strongSelf.playerItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
            CGFloat currentTime = CMTimeGetSeconds(currentItem.currentTime);
            CGFloat totalTime = currentItem.duration.value / currentItem.duration.timescale;
            CGFloat value = CMTimeGetSeconds(currentItem.currentTime) / totalTime;
            [strongSelf.controlView vcPlayerCurrentTime:currentTime totalTime:totalTime sliderValue:value];
        }
    }];
}

- (void)addPlayerToFatherView:(UIView *)view {
    if (!view) {
        return;
    }
    [self removeFromSuperview];
    [view addSubview:self];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topAnchor constraintEqualToAnchor:view.topAnchor].active = YES;
    [self.leftAnchor constraintEqualToAnchor:view.leftAnchor].active = YES;
    [self.bottomAnchor constraintEqualToAnchor:view.bottomAnchor].active = YES;
    [self.rightAnchor constraintEqualToAnchor:view.rightAnchor].active = YES;
}

- (void)cellVideoWithScrollView:(UIScrollView *)scrollView atIndexPath:(NSIndexPath *)indexPath {
    // 播放其他视频的时候先重置Player
    if (!self.viewDisappear && self.playerItem) {
        [self resetPlayer];
    }
    self.isCellVideo = YES;
    self.viewDisappear = NO;
    self.scrollView = scrollView;
    self.indexPath = indexPath;
    [self.controlView vcPlayerCellPlay];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isEqual:self.player.currentItem]) {
        if ([keyPath isEqualToString:@"status"]) {
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                [self setNeedsLayout];
                [self layoutIfNeeded];
                [self.layer insertSublayer:self.playerLayer atIndex:0];
                self.state = VCPlayerStatePlaying;
                if (self.seekTime) {
                    [self seekToTime:self.seekTime completionHandler:nil];
                }
                self.player.muted = self.mute;
            } else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
                self.state = VCPlayerStateFailed;
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            NSArray *loadedTimeRanges = self.player.currentItem.loadedTimeRanges;
            CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
            CGFloat startSeconds = CMTimeGetSeconds(timeRange.start);
            CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);
            NSTimeInterval availableDuration = startSeconds + durationSeconds;
            
            CMTime duration = self.player.currentItem.duration;
            CGFloat totalDuration = CMTimeGetSeconds(duration);
            [self.controlView vcPlayerLoadingProgress:availableDuration / totalDuration];
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            if (self.player.currentItem.playbackBufferEmpty) {
                self.state = VCPlayerStateBuffering;
                [self bufferingSomeSeconds];
            }
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            if (self.player.currentItem.playbackLikelyToKeepUp && self.state == VCPlayerStateBuffering) {
                self.state = VCPlayerStatePlaying;
            }
        }
    } else if ([object isEqual:self.scrollView]) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            if (self.fullscreen) {
                return;
            }
            [self handleScrollOffset];
        }
    }
}

- (void)seekToTime:(CGFloat)dragedSeconds completionHandler:(void (^)(BOOL finished))completionHandler {
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        [self.controlView vcPlayerLoadingActivity:YES];
        [self.player pause];
        CMTime dragedTime = CMTimeMake(dragedSeconds, 1);
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:dragedTime toleranceBefore:CMTimeMake(1, 1) toleranceAfter:CMTimeMake(1, 1) completionHandler:^(BOOL finished) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.controlView vcPlayerLoadingActivity:NO];
            if (completionHandler) {
                completionHandler(finished);
            }
            [strongSelf.player play];
            strongSelf.seekTime = 0;
            [weakSelf.controlView vcPlayerDraggedEnd];
            if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp) {
                weakSelf.state = VCPlayerStateBuffering;
            }
        }];
    }
}

- (void)bufferingSomeSeconds {
    self.state = VCPlayerStateBuffering;
    __block BOOL isBuffering = NO;
    if (isBuffering) {
        return;
    }
    isBuffering = YES;
    
    // 暂停一会再播放，否则网络不好的时候时间在走，声音播放不出来
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isPausedByUser) {
            isBuffering = NO;
            return;
        }
        
        [self play];
        isBuffering = NO;
        if (!self.player.currentItem.isPlaybackLikelyToKeepUp) {
            [self bufferingSomeSeconds];
        }
    });
}

- (void)handleScrollOffset {
    if ([self.scrollView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.scrollView;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.indexPath];
        if ([tableView.visibleCells containsObject:cell]) {
            [self updatePlayerViewForCell];
        } else {
            if (self.stopPlayWhileCellNotVisible) {
                [self resetPlayer];
            }
        }
    } else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self.scrollView;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.indexPath];
        if ([collectionView.visibleCells containsObject:cell]) {
            [self updatePlayerViewForCell];
        } else {
            if (self.stopPlayWhileCellNotVisible) {
                [self resetPlayer];
            }
        }
    }
}

- (void)updatePlayerViewForCell {
    [self.controlView vcPlayerCellPlay];
}

@end
