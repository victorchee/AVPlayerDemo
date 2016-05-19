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

@end

@implementation VCPlayer

- (instancetype)initWithFrame:(CGRect)frame andVideoURL:(NSURL *)url {
    if (self = [super init]) {
        self.videoURL = url;
    }
    return self;
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
}

@end
