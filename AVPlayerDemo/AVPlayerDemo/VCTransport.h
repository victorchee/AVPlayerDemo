//
//  VCTransport.h
//  AVPlayerDemo
//
//  Created by Victor Chee on 2017/2/27.
//  Copyright © 2017年 VictorChee. All rights reserved.
//

@import AVFoundation;

@protocol VCTransportDelegate <NSObject>

- (void)play;
- (void)pause;
- (void)stop;

- (void)dragDidStart;
- (void)dragToTime:(NSTimeInterval)time;
- (void)dragDidEnd;

- (void)jumpedToTime:(NSTimeInterval)time;

@end

@protocol VCTransport <NSObject>

@property (nonatomic, weak) id<VCTransportDelegate> delegate;

- (void)setCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration;
- (void)setDragTime:(NSTimeInterval)time;
- (void)playbackComplete;

@end
