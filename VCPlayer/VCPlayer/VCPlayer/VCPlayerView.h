//
//  VCPlayerView.h
//  VCPlayer
//
//  Created by Migu on 2018/4/8.
//  Copyright © 2018年 VIctorChee. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

typedef enum : NSUInteger {
    VCPlayerStateFailed,
    VCPlayerStateBuffering,
    VCPlayerStatePlaying,
    VCPlayerStateStopped,
    VCPlayerStatePaused,
} VCPlayerState;

@protocol VCPlayerDelegate <NSObject>
@end

@interface VCPlayerView : UIView

@property (nonatomic, weak) id<VCPlayerDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isPausedByUser;
@property (nonatomic, assign, readonly) VCPlayerState state;
@property (nonatomic, assign) AVLayerVideoGravity videoGravity;
@property (nonatomic, assign) BOOL mute;
@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic, assign) BOOL stopPlayWhileCellNotVisible;

@property (nonatomic, strong) UIView *controlView;

+ (instancetype)sharedInstance;

- (void)resetPlayer;
- (void)play;
- (void)pause;

@end
