//
//  VCPlayerController.m
//  AVPlayerDemo
//
//  Created by Victor Chee on 2017/2/27.
//  Copyright © 2017年 VictorChee. All rights reserved.
//

#import "VCPlayerController.h"
#import "VCTransport.h"
#import "VCPlayerView.h"

static const NSString *PlayerItemStatusContext;

@interface VCPlayerController () <VCTransportDelegate>

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) VCPlayerView *playerView;
@property (nonatomic, weak) id<VCTransport> transport;
@property (nonatomic, strong) id timeOberver;
@property (nonatomic, strong) id itemEndObserver;
@property (nonatomic, assign) float lastPlaybackRate;

@end

@implementation VCPlayerController

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _asset = [AVAsset assetWithURL:url];
        [self prepareToPlay];
    }
    return self;
}

- (UIView *)view {
    return self.playerView;
}

- (void)dealloc {
    if (self.itemEndObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        self.itemEndObserver = nil;
    }
}

- (void)prepareToPlay {
    NSArray *keys = @[@"tracks", @"duration", @"commonMetadata", @"availableMediaCharacteristicsWithMediaSelectionOptions"];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset automaticallyLoadedAssetKeys:keys];
    [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:&PlayerItemStatusContext];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerView = [[VCPlayerView alloc] initWithPlayer:self.player];
    self.transport = self.playerView.transport;
    self.transport.delegate = self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == &PlayerItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playerItem removeObserver:self forKeyPath:@"status"];
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                [self addPlayerItemTimeObserver];
                [self addItemEndObserverForPlayerItem];
                
                CMTime duration = self.playerItem.duration;
                
                [self.transport setCurrentTime:CMTimeGetSeconds(kCMTimeZero) duration:CMTimeGetSeconds(duration)];
                
                [self.player play];
            } else {
                NSLog(@"Failed to load video");
            }
        });
    }
}

- (void)addPlayerItemTimeObserver {
    CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
    dispatch_queue_t queue = dispatch_get_main_queue();
    __weak VCPlayerController *weakSelf = self;
    self.timeOberver = [self.player addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:^(CMTime time) {
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(weakSelf.playerItem.duration);
        [weakSelf.transport setCurrentTime:currentTime duration:duration];
    }];
}

- (void)addItemEndObserverForPlayerItem {
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    __weak VCPlayerController *weakSelf = self;
    self.itemEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem queue:queue usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [weakSelf.transport playbackComplete];
        }];
    }];
}

#pragma mark <VCTransportDelegate>
- (void)play {
    [self.player play];
}

- (void)pause {
    self.lastPlaybackRate = self.player.rate;
    [self.player pause];
}

- (void)stop {
    [self.player setRate:0.0];
    [self.transport playbackComplete];
}

- (void)jumpedToTime:(NSTimeInterval)time {
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
}

- (void)dragDidStart {
    self.lastPlaybackRate = self.player.rate;
    [self.player pause];
    [self.player removeTimeObserver:self.timeOberver];
    self.timeOberver = nil;
}

- (void)dragToTime:(NSTimeInterval)time {
    [self.playerItem cancelPendingSeeks];
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)dragDidEnd {
    [self addPlayerItemTimeObserver];
    if (self.lastPlaybackRate > 0) {
        [self.player play];
    }
}

@end
